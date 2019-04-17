---
title: 使用GO-Docker-SDK构建简易WebHook
subtitle:
date: 2019-04-17
tags: ["运维", "golang", "docker"]
draft: true
---

为了实现本地编辑的博客内容同步到云主机，一直在使用jenkins作为持续部署工具。奈何jenkins作为平台级的工具本身会占用我小机器的大量资源（内存200M+，存储1G+）。还好个人需求比较简单，因此自建一个简易的WebHook工具也比较方便。

因为一开始就考虑到频繁更新部署的需求，因此博客也是用docker进行部署，那么更新博客也是围绕操作docker进行。

<!--more-->

## 实现方法讨论

WebHook简单来讲就是对外的回调HTTP接口，更新事件触发后执行部署或者更新操作。如果WebHook自身部署在Docker宿主机上，大可以用一个shell脚本执行更新操作，毕竟jenkins也是模拟这么做的。

而如果希望将WebHook同样容器化并部署在Docker上（kubeadm也是这么做的），那么WebHook需要可以操作宿主机的Docker，目前我知道的有两个方法：

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
go get github.com/docker/docker/client
```

### 要访问的Docker API版本
可以通过docker version命令获取，如图：

![](https://images.moonlightming.top/images/20190416171215.png)

### 注册阿里云容器仓库服务

很多公有云免费提供容器仓库服务，不用自建也可以节省一笔服务器资源，这里使用阿里云。

[容器镜像官方文档](https://help.aliyun.com/product/60716.html?spm=a2c4g.750001.list.6.27f07b13D5LrSM)

## 开始编写

更新容器简单来说分为两步，下载镜像，更新服务

## 问题小结

### 容器内的WebHook怎么访问宿主机的Docker

