---
title: 使用GO-Docker-SDK构建简易WebHook
subtitle:
date: 2019-04-17
tags: ["CI/CD", "golang", "docker"]
draft: false
---

为了实现本地编辑的博客内容同步到云主机，一直在使用Jenkins作为持续部署工具。奈何Jenkins作为平台级的工具本身会占用我小机器的大量资源（内存200M+，存储1G+）。还好个人需求比较简单，因此自建一个简易的WebHook工具也比较方便。

因为一开始就考虑到频繁更新部署的需求，因此博客也是用docker进行部署，那么更新博客也是围绕操作docker进行。

<!--more-->

## 实现方法讨论

WebHook简单来讲就是对外的回调HTTP接口，更新事件触发后执行部署或者更新操作。如果WebHook自身部署在Docker宿主机上，大可以用一个shell脚本执行更新操作，毕竟jenkins也是模拟这么做的。

而如果希望将功能组件容器化并部署在Docker上（kubeadm也是这么做的），那么WebHook需要操作宿主机的Docker，目前我知道的有两个方法：

1. Docker-in-Docker,将宿主机Docker挂载进WebHook容器内部，直接在容器内执行docker-update命令就可以完成更新部署，但是官方不推荐这样做，不同系统下实现方式也有诸多问题。
2. 通过远程API调用，前提是Docker开启远程端口。

## 流程解析

有了之前的讨论，持续部署的流程简单概括为以下几步：

1. 代码仓库push事件完成，发送请求容器打包请求给容器仓库。
2. 容器仓库收到请求，从代码仓库拉取代码打成镜像，发送请求通知WebHook。
3. WehHook收到通知，从容器仓库拉取镜像，替换现有运行时容器。本章内容主要在这一步。

## 前置条件

### Docker开启远程访问

可以查看之前的文章：[Docker开启远程访问](https://blog.moonlightming.top/post/2018-11-08-docker开启远程访问/)

### Golang SDK for Docker获取

```
go get -u github.com/docker/docker/client
```

### 要访问的Docker API版本
可以通过docker version命令获取，如图：

![](https://images.moonlightming.top/images/20190416171215.png)

### 注册阿里云容器仓库服务

很多公有云免费提供容器仓库服务，不用自建也可以节省一笔服务器资源，这里使用阿里云。

[Ali容器镜像官方文档](https://help.aliyun.com/product/60716.html?spm=a2c4g.750001.list.6.27f07b13D5LrSM)

## 开始编写

### 接收容器仓库消息

容器仓库打好镜像会给WebHook发送一段消息，我这里给个样本：

```json
{
    "push_data": {
        "digest": "sha256:xxxxxxxxxxxxxxxxxxxxxxx",         // 唯一识别码
        "pushed_at": "2019-04-17 18:29:42",                 // 构建时间
        "tag": "latest"                                     // 容器标签
    },
    "repository": {
        "date_created": "2018-11-16 14:25:21",
        "name": "xblog-hugo",                               // 仓库名
        "namespace": "moonlightming",                       // 仓库命名空间
        "region": "cn-shenzhen",                            // 仓库所属地理位置
        "repo_authentication_type": "NO_CERTIFIED",
        "repo_full_name": "moonlightming/xblog-hugo",       // 仓库全名
        "repo_origin_type": "NO_CERTIFIED",
        "repo_type": "PRIVATE"                              // 私有镜像
    }
}
```

转换为HookRequest对象，更新容器时会用到。

```golang
import "fmt"

const DockerServerHost = "aliyuncs.com"

type HookRequest struct {
    PushData   `json:"push_data"`
    Repository `json:"repository"`
}

type PushData struct {
    Digest   string `json:"digest"`
    PushedAt string `json:"pushed_at"`
    Tag      string `json:"tag"`
}

type Repository struct {
    DateCreated            string `json:"date_created"`
    Name                   string `json:"name"`
    Namespace              string `json:"namespace"`
    Region                 string `json:"region"`
    RepoAuthenticationType string `json:"repo_authentication_type"`
    RepoFullName           string `json:"repo_full_name"`
    RepoOriginType         string `json:"repo_origin_type"`
    RepoType               string `json:"repo_type"`
}

// PublicAddr: 生成下载容器所需的URL，阿里云容器仓库提供了公有网络、专有网络、经典网络三种URL供下载镜像
//             这里是生成公网地址
func (h *HookRequest) PublicAddr() (repositoryAddr string) {
    // like this:
    // 	 registry.cn-shenzhen.aliyuncs.com/moonlightming/xblog-hugo
    return fmt.Sprintf("registry.%s.%s/%s", h.Region, DockerServerHost, h.RepoFullName)
}
```

### 更新容器

生产中服务是以Service形式存在的，而不是单一容器。Service可以更好的享受容器编排的便捷管理，健康监测，故障恢复等好处。
更新简单来说分为两步，下载镜像，更新服务。

直接放代码：

```golang
package dockercli

import (
    "context"
    "encoding/base64"
    "encoding/json"
    "fmt"
    "github.com/docker/docker/api/types"
    "github.com/docker/docker/api/types/filters"
    "github.com/docker/docker/api/types/swarm"
    "github.com/docker/docker/client"
    "github.com/moonlightming/simple-docker-inside-webhook/commons"
    "github.com/moonlightming/simple-docker-inside-webhook/conf"
    "io"
    "log"
    "os"
)

var (
    config     = conf.NewConfig() // Global config
    cli        = newDockerCli()   // single Docker client
    authBase64 = ""
)

func init() {
    // 如果Docker容器仓库使用的是私有镜像，需要转为Docker-SDK的AuthConfig对象，然后base64转码
    if config.DockerRegistryAuth.User != "" && config.DockerRegistryAuth.Password != "" {
        auth := types.AuthConfig{
            Username: config.DockerRegistryAuth.User,
            Password: config.DockerRegistryAuth.Password,
        }
        authBytes, err := json.Marshal(auth)
        if err != nil {
            panic(err)
        }
        authBase64 = base64.URLEncoding.EncodeToString(authBytes)
    }
}

// newDockerCli: 新版的SDK中，docker-cli对象通过各种WithXXX方法设定参数
//               我这里设定了Docker的IP地址和API版本来控制Docker-Server
func newDockerCli() *client.Client {
    cli, err := client.NewClientWithOpts(
        client.WithHost("tcp://" + config.DockerHost),
        client.WithVersion(config.DockerApiVersion),
    )
    if err != nil {
        panic(err)
    }
    return cli
}

// PullImage: 从容器仓库下载镜像，如果是私有镜像，需要authBase64码
//      imageFullDownloadURL: 完整下载地址，上文的hookRequest.PublicAddr()返回值
func PullImage(imageFullDownloadURL string, repoType string) error {
    reader, err := cli.ImagePull(
        context.Background(),
        imageFullDownloadURL,
        types.ImagePullOptions{RegistryAuth: isPrivate(repoType)},
    )
    if err != nil {
        return err
    }
    // 将下载信息输出到屏幕
    io.Copy(os.Stdout, reader)
    return nil
}

// ListServiceWithName: 列出对应名称的Service
func ListServiceWithName(serviceName string) ([]swarm.Service, error) {
    var (
        swarms []swarm.Service
        err    error
    )
    if swarms, err = cli.ServiceList(
        context.Background(),
        types.ServiceListOptions{
            Filters: filters.NewArgs(filters.Arg("name", serviceName)),
        },
    ); err != nil {
        return nil, err
    }
    return swarms, nil
}

// UpdateService: 更新Docker-Service
//      HookRequest: 上文容器仓库的请求对象
//      groupName: Docker-Service名称的前缀，代表Service的分组
func UpdateService(hookRequest commons.HookRequest, groupName string) error {
    var beUpService swarm.Service
    // 过滤出要更新的Service，因为是完整匹配所以取第一个
    if swarms, err := ListServiceWithName(groupName + "_" + hookRequest.Name); err != nil {
        return err
    } else {
        beUpService = swarms[0]
    }
    beUpServiceJ, err := json.Marshal(beUpService)
    log.Printf("BeforeInspectService: %s", beUpServiceJ)
    log.Println("############## Update #####################")

    // 修改要更新的内容，这里更新镜像，因此将所用Image指向刚才下载的容器镜像即可
    // 容器名称的格式：[容器下载地址]@[唯一标识码]
    // 例：registry.cn-shenzhen.aliyuncs.com/moonlightming/xblog-hugo:latest@sha256:xxxxxxxxxx
    beUpService.Spec.TaskTemplate.ContainerSpec.Image = fmt.Sprintf("%s@%s", hookRequest.PublicAddr(), hookRequest.PushData.Digest)

    // 更新服务，私有镜像更新服务也是需要认证的
    warning, err := cli.ServiceUpdate(
        context.Background(),
        beUpService.ID,
        swarm.Version{Index: beUpService.Version.Index},
        beUpService.Spec,
        types.ServiceUpdateOptions{EncodedRegistryAuth: isPrivate(hookRequest.RepoType), QueryRegistry: false},
    )
    log.Printf("Warning: %+v", warning)
    log.Printf("Err: %+v", err)
    return err
}


// if the registry private, return auth code
func isPrivate(repoType string) string {
    if repoType == "PRIVATE" {
        return authBase64
    }
    return ""
}
```

## 问题小结

### 完整示例代码

[Github:simple-docker-inside-webhook](https://github.com/moonlightMing/simple-docker-inside-webhook)

个人使用时添加了邮件通知和定期清理镜像(还不太好用)的功能。

### 如何将该项目容器化部署

上面的示例中附带了Dockerfile，直接build就行。采用分阶段构建，所以第一次会花费较多时间在下载GO编译镜像上。

### 容器内的WebHook怎么访问宿主机的Docker

容器启动时会执行这样一句话，其实Docker-Server的访问地址就是默认路由。改一下容器的hosts文件，代码里就不用动态获取了。

```shell
/sbin/ip route|awk '/default/ { print  $3,"\tdockerhost" }' >> /etc/hosts
```

### 如何保证我的WebHook不被别人乱用

Jenkins的做法是生成一段密码，容器仓库请求更新URL时带上这串密码，我这里也是这么做的。对应项目中config.json的auth_key。