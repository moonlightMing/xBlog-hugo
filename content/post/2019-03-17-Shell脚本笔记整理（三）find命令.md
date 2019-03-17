---
title: Shell脚本笔记整理(三) find、locate、whereis、which命令
subtitle: 
date: 2019-03-17
tags: ["运维", "shell"]
draft: false
---



<!--more-->
## find
### 语法格式

```shell
# path: 查找的起点路径
# option: 查找的过滤条件
# action(可选): 对查找出的结果做哪些操作
find [path] [option] [action]
```

### 选项参数

1. -name，根据文件名查找，大小写严格。忽略大小写用-iname
2. -perm，根据文件权限查找。
3. -prune，排除某些目录后查找。
4. -user，根据文件所属主查找。
5. -group，根据文件所属组查找。
6. -mtime -n|+n，根据文件修改时间查找，单位是天。还有一个-mmin，也是根据时间查找，单位是分钟。
7. -nogroup，查找无有效属组的文件。
8. -nouser，查找无有效属主的文件。
9. -newer file1 ! file2，查找修改时间比file1新但比file2旧的文件。
10. -type，按文件类型查找（目录、文件、链接文件类型，不是根据后缀名）。
11. -size -n +n，按文件大小查找。
12. -mindepth n，从n级子目录开始查找。
13. -maxdepth n，最多查找至n级目录。


### 操作参数

1. -print，打印输出，默认就是这个，不加也行。
2. -exec，对搜索到的文件执行特定操作，格式为"-exec 'command' {}"。
3. -ok，和exec一样，只是每次操作都会给用户提示，如果是删除文件问一个删一个。

我工作中最常见的是根据文件名、修改时间、文件大小来查找过期日志，之后设定
action删除之。
```shell
# 删除五天前的nginx日志文件。
find /var/log/nginx -name '*.log' -mtime +5 -exec rm -f {} \;
```

### 逻辑运算符

上面的例子可以看到-name和-mtime连用，那么连用时也可以拥有与、或、非的逻辑关系。

1. -a，与，默认就这个，不加也没关系。
2. -o，或。
3. not|!，非。

那么上节的例子可以改写成这样：
```shell
# 注意多加了个not，这样匹配log结尾，但排除了修改时间五天内的文件。
find /var/log/nginx -name '*.log' not -mtime -5 -exec rm -f {} \;
```

## locate

locate同样是文件查找命令，不同于find命令的是find是在整块磁盘中搜索，locate是在系统自己维护的数据库文件中查找,数据库文件后台cron默认每天更新一次，因此locate不能查询实时的文件。

如果想立即查找到，需要updatedb命令进行更新数据库操作，updatedb命令同样是遍历磁盘与数据库记录比较，效率较慢，因此<b>有实时查找需求用find就好</b>。数据库文件地址为/var/lib/mlocate/mlocate.db。所使用配置文件路径为/etc/updatedb.conf。

find默认精确匹配，locate这是默认非精确匹配。

虽然locate不能查询实时的文件，但由于是从数据库中查询，效率极高。

## whereis

用于查找二进制文件，但只能查找二进制文件、帮助文档文件、源代码文件。

1. -b，只返回二进制文件。
2. -m，只返回帮助文档文件。
3 -s，只返回源代码文件。

## which

whereis的简化版，只返回二进制文件。