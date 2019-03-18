---
title: Shell脚本笔记整理(四) sed命令
subtitle: 
date: 2019-03-18
tags: ["运维", "shell"]
draft: true
---

本节记录流编辑器sed的用法，流编辑器即对标准输出或文件进行<b>逐行</b>处理。

<!--more-->

## 语法格式

1. 从输出流中读入

```shell
# option: 工具选项
# pattern: 匹配模式
# command: 匹配内容
stdout | sed [option] "pattern command"
```

2. 从文件中读入

```shell
sed [option] "pattern command" file
```
