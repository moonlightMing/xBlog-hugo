---
title: Shell脚本笔记整理(四) grep命令
subtitle: 
date: 2019-03-17
tags: ["运维", "shell"]
draft: true
---

除了grep还有它的拓展egrep。

<!--more-->

## grep
### 语法格式

一般有两种，直接使用和通过管道进行过滤。

```shell
# option: 选项参数
# pattern: 要过滤的关键字
# file: 要在哪个文件中查找，可写多个
grep [option] [pattern] [file1, file2...]
```
