---
title: MySQL备份工具 Xtrabackup
subtitle: 
date: 2018-11-14
tags: ["运维", "mysql"]
draft: false
---

虽然现在云数据库流行，但是总有特殊情况需要自行搭建MySQL服务。那么备份就是重中之重，谁也不会想使用到备份，但生产环境上不可能没有备份。

<!--more-->

## 部署
这里只讲RH/CentOS系列

```shell
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noarch.rpm
# 部分系统有出现过没有epel无法正常yum安装的情况
yum install epel-release
rpm -ivh percona-release-0.1-6.noarch.rpm
# 推荐安装最新的稳定版本
yum install -y percona-xtrabackup-24
```

## 使用前准备
### 权限
由于备份脚本里数据库帐号都是明文，因此对备份帐号的权限需要最小化设置

最小权限示例：

```mysql
mysql> CREATE USER 'bkpuser'@'localhost' IDENTIFIED BY 'EyBwsS';
mysql> GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'bkpuser'@'localhost';
mysql> FLUSH PRIVILEGES;
```

### 配置
支持配置文件形式，不过用的更多的是命令行参数。

另外，/etc/my.cnf文件中必须要有如下选项
```shell
# 数据目录，作为工具还原时的目录依据
datadir=/var/lib/mysql

# 因为Xtrabackup属于物理备份，需要开启独立表空间选项，用于单库恢复使用,MySQL5.6及以后版本默认开启
innodb_file_per_table=1
```

## 做一次全备

### 遇见的一些问题

使用时遇见了一些错误：

```shell
2018-07-25 19:27:35 7fdf3baa37e0  InnoDB: Operating system error number 24 in a file operation.
InnoDB: Error number 24 means 'Too many open files'.
```

开放文件打开数限制

```shell
vim /etc/security/limits.conf

# 添加下面两行
* soft nofile 65535
* hard nofile 65535

# 重启后生效，不重启的可以先临时打开
ulimit -n 65535
```

### 开始全备

```shell
innobackupex --user=bkpuser --password=123456 /data/backups/
```

直接将全库备份至该目录，会留有一个带有备份时间戳的目录，里面放置的是MySQL备份文件。

#### 流式备份

支持将备份转化为数据流，好处是可以边备份边发送至远端机器，直接备份至远程目录。或者进行压缩处理，需要添加_--stream_参数支持，该参数也有诸多选择，用于指明压缩格式。

```shell
# /tmp目录只是做占位用，实际不输出到该目录
innobackupex --user=bkpuser --password=123456 --stream=tar /tmp | gzip > /data/backups/`date +%Y-%m-%d`.tar.gz
```

#### 日志重定向

备份操作一般是放在后台进行，因此有必要将每次备份产生的日志重定向至磁盘目录，该方法适用于所有使用场景。

```shell
# 2>>中间不能有空格
innobackupex --user=bkpuser --password=123456 /data/backups 2>> /data/stdout.log
```

生产环境使用实例

```shell
innobackupex                             \
        --user=bkpuser                   \  # 备份所需帐号
        --password=123456                \  # 帐号密码 
        --no-timestamp                   \  # 
        --stream=tar                     \  # 流格式
        /tmp                             \  # 导出目录,最终并不存放在此
        2>> /data/backups/stdout.log     \  # 日志目录
        | gzip > /data/backups/`date +%Y-%m-%d`.tar.gz # 备份文件存放点
```

### 还原

#### 检查阶段

务必确认以下几点：
- MySQL处于停止状态
- 预先备份好/var/lib/mysql，即mysql存储目录的内容
- 承接上一条，恢复时/var/lib/mysql目录必为空
- 预先准备binlog日志，补足备份后这段空档期的数据

#### 数据准备阶段

xtrabackup备份类型为物理备份，为了不影响数据库引擎，备份时是将磁盘上的数据库文件及正在进行的事务日志（redo-log）共同备份下来。因此恢复时需要将事务日志恢复到备份文件中（此时会确认当时未完事务的commit和rollback操作）。恢复完成后既可以将数据拷回mysql目录。

```shell
innobackupex            \
        --apply-log     \
        /data/backups   # 指定备份文件目录路径
```

#### 数据拷回
```shell
innobackupex        \
        --copy-back     \
        /data/backups   # 恢复完成后的备份文件路径，会根据/etc/my.cnf配置找到mysql的datadir进行拷回操作。此时datadir必须为空。也可使用参数忽略为空条件。
```

拷回后正常启动MySQL，检查读写及是否有报错情况。
```shell
/etc/init.d/mysqld start
```

## 单库备份

### 
```shell
innobackupex --user=dpkuser --password=123456 --include='^xn_(\d)*' /data/backups/
```


## 增量备份

增量备份需要先进行一次全备，然后在此基础上进行定时增量备份，实际使用过程中感觉特别繁琐，因为恢复也是按照备份文件倒序进行还原。如果数量大的话恢复起来效率不比binlog日志快，因此在公司里实际使用还是全量+binlog的方式进行。
