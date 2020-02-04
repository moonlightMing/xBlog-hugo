---
title: Shell脚本笔记整理(四) grep命令
subtitle: 
date: 2019-03-18
tags: ["运维", "shell"]
draft: false
---

除了grep还有它的拓展egrep。

<!--more-->

## 语法格式

一般有两种，直接使用和通过管道进行过滤。

```shell
# option:   选项参数
# pattern:  要过滤的关键字
# file:     要在哪个文件中查找，可写多个

grep [option] [pattern] [file1, file2...]

# 或

stdout | grep [option] [pattern]
```

## 选项参数

1. -v，不显示匹配行信息，就是反向匹配。
2. -i，忽略大小写。
3. -n，显示行号。
4. -r，递归搜索。
5. -E，支持<b>扩展</b>正则表达式(正则表达式分为基本表达式与扩展表达式，主要区别是支持的符号，例如或'|')，与egrep等价。
6. -F，不使用正则匹配，仅按照表达式字面意思进行匹配。
7. -c，只输出匹配行的数量，不显示具体内容，与grep xxx xxx | wc -l类似。
8. -w，匹配整词。
9. -x，匹配整行。
10. -l，只列出匹配的文件名，不显示具体匹配行内容。