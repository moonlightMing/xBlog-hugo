---
title: Electron实践记录
subtitle: 
date: 2019-02-12
tags: ["前端", "javascript"]
draft: true
---

接触Electron已经快一个月了，当初是为了寻找一个快速构建客户端程序的方法，用于编写一个工具。对于编写过前端的人来说，能用js写客户端来降低学习成本再好不过。

<!--more-->

## 项目初始化

前端项目一般都有脚手架工具，electron为了方便开发者自然也有，我这里使用了目前比较火的[electron-react-boilerplate](https://github.com/electron-react-boilerplate/electron-react-boilerplate)

该脚手架是目前功能比较完善的Electron&React整合项目，热加载功能非常吸引人。并且已经集成了redux、react-router-dom、electron-builder，开箱即用。

```shell
git clone --depth 1 --single-branch --branch master https://github.com/electron-react-boilerplate/electron-react-boilerplate.git your-project-name
cd your-project-name
yarn
```

启动调试

```shell
yarn dev
```

打包
```shell
yarn package
```

## 添加Antd组件库

本意是快速制作一个工具，所以直接使用现成组件库最好。这里使用React国内最著名的Ant Design。

```shell
yarn add antd
```

然后载入全局CSS，在项目的app/app.global.css头部编辑

```
@import "~@fortawesome/fontawesome-free/css/all.css";

# 添加下面这句话
@import '~antd/dist/antd.css';

body {
  /* position: relative; */
  color: white;
  /* background-color: #232c39; */
  /* background-image: linear-gradient(45deg, rgba(0, 216, 255, 0.5) 10%, rgba(0, 1, 127, 0.7)); */
  font-family: Arial, Helvetica, Helvetica Neue, serif;
  /* overflow-y: hidden; */
  font: caption;
}
```

## 静态文件处理

Electron打包时默认不带