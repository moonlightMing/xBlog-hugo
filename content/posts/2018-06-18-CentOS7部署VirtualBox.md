---
title: CentOS7部署VirtualBox
subtitle: 部署小结
date: 2018-06-18
tags: ["运维"]
draft: false
---

kvm和virtualbox在小企业内部使用还是比较广泛的，这里做一下部署总结。

<!--more-->

## 使用yum安装

首先准备基础环境

```
yum -y install gcc make glibc kernel-headers kernel-devel dkms
# 更新内核版本
yum -y update kernel
# 重启
reboot
```

从官网上下载yum源

```
cd /etc/yum.repo.d/
wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo

# 安装
yum install VirtualBox-5.2
```

修改基本配置，这一步是为了提供API让后续的web界面调用。

```
vi /etc/vbox/vbox.cfg

# 在配置中添加如下内容
VBOXWEB_USER=root
VBOXWEB_HOST=0.0.0.0
VBOXWEB_PORT=18083
VBOXWEB_TIMEOUT=300
VBOXWEB_CHECK_INTERVAL=5
VBOXWEB_THREADS=100
VBOXWEB_KEEPALIVE=100
VBOXWEB_LOGFILE=/var/log/vboxweb.log
```

开机自启
```
# virtualbox的web接口，后面会用到
systemctl enable vboxweb-service.service
# 核心服务
systemctl enable vboxdrv.service
systemctl enable vboxballoonctrl-service.service
```

之后重启服务器，或者使用systemctl start开启服务。

## phpVirtualBox

virtualBox本身是没有远程客户端的，因此我们使用第三方提供的WEB控制台来进行远程控制。

phpVirtualBox自带Dockerfile和docker-compose.yml，可以使用docker部署。这里不介绍docker及docker-compose的安装。

官网地址：[github](https://github.com/phpvirtualbox/phpvirtualbox)

下载地址：[phpvirtualbox.zip](https://github.com/phpvirtualbox/phpvirtualbox/archive/master.zip)

下载至本地解压后有如下内容：

![](https://images.moonlightming.com/images/20180618143313.png)

首先要将配置文件重命名

```shell
cp config.php-example config.php
```

和控制台有关的配置都在这个文件里，配置内也有详细的说明，有需要可以阅读说明进行修改。

启动界面服务：

```
docker-compose build
docker-compose up -d
```

docker-compose.yml:

```yaml
phpvirtualbox:
  restart: always
  build: .
  ports:
    - "80:80"
  volumes:
    - .:/var/www/html
```

需要注意如下几点：

1. docker-compose.yml中的端口，默认是80。
2. 如果需要开机自启需要添加restart:always
3. 因为是将本地目录映射至容器，需要目录的读写权限，要么关闭SELINUX，要么开启--selinux-enabled选项

之后进入浏览器输入地址检查效果，默认帐号密码皆为admin，有需要可以在配置里修改。基本操作和平常客户端界面内一模一样。

![](https://images.moonlightming.com/images/20180618150312.png)
