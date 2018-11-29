---
title: 使用hugo构建个人博客
subtitle: 简洁 方便 省事儿
date: 2018-11-14
tags: ["golang"]
draft: false
---

Hugo是一款由go语言编写的个人博客系统，最大的特点就是开箱即用，样式丰富，使用者只需关注内容。可以快速搭建一套静态展示类型的网站。并且自带高性能服务器，热部署等特性，是不想多花精力又想构建个人博客的极佳选择。

<!--more-->

## 部署

Hugo开源在github上，进入对应项目页面下载对应版本。[下载页面](https://github.com/gohugoio/hugo/releases)

下载完成后扔进系统bin目录下即可。

## 新建一个空白项目

```shell
hugo new site myblog
```

目录结构如下：
```
cd myblog && tree
.
├── archetypes
│   └── default.md
├── config.toml
├── content
├── data
├── layouts
├── static
└── themes
```

各目录的作用可以查看官方文档，实际使用过程中只用到少数几个。

## 给博客添加一个主题样式

Hugo最吸引人的特点就是hugo拥有丰富的主题样式可以自由挑选更换。[Hugo Themes](https://themes.gohugo.io/)

举个栗子，比如我比较喜欢[Beautifulhugo主题](https://github.com/halogenica/beautifulhugo)，我要应用这个主题。

首先这类主题都是独立的项目在进行维护，要应用该项目到自己的博客中需要使用git的子项目管理模块:

```shell
cd myblog
git init
git submodule add https://github.com/halogenica/beautifulhugo.git themes/beautifulhugo
```

该操作会将主题样式加入到thems目录下，hugo的主题样式都存放在这个目录。

样式已经下载到本地，接下来是应用主题，hugo的全局配置文件是项目根目录下的config.toml，一般来说每个主题样式都有自己独特的配置项及功能，因此config.toml我推荐使用所选主题自带的来覆盖本地。每个主题一般会在自己项目的exampleSite目录中留有最佳实践，该主题的配置模板也在里面。

```shell
# 进入exampleSite目录
cd myblog/thems/beautifulhugo/exampleSite && ls

# 拷贝config.toml文件覆盖自己项目
cp config.toml ../../../
```

覆盖完后查看config.toml文件，内容非常多，但只需修改其中通用的几项，详情可以查看项目文档。

我这里修改带有注释的项即可。

```toml
# 由于hugo是静态博客，需要自己指定博客的url，hugo会渲染进博客页面
baseurl = "https://blog.moonlightming.top"
DefaultContentLanguage = "en"

# 博客标题
title = "标题"
# 博客的样式
theme = "beautifulhugo"

metaDataFormat = "yaml"
pygmentsStyle = "trac"
pygmentsUseClasses = true
pygmentsCodeFences = true
pygmentsCodefencesGuessSyntax = true
#pygmentsUseClassic = true
#pygmentOptions = "linenos=inline"
#disqusShortname = "XXX"
#googleAnalytics = "XXX"

[Params]
#  homeTitle = "Beautiful Hugo Theme" # Set a different text for the header on the home page
  subtitle = "副标题"

  # 作者头像
  logo = "img/avatar-icon.png" # Expecting square dimensions

  # favicon.ico 位置
  favicon = "img/favicon.ico"
  dateFormat = "January 2, 2006"
  commit = false
  rss = true
  comments = true
  readingTime = true
  wordCount = true
  useHLJS = true
  socialShare = true
  delayDisqus = true
  showRelatedPosts = true

# 博客作者信息
[Author]
  name = "Bubble"
  email = "youremail@domain.com"
  github = "Moonlightming"

# 右侧标签内容，按需修改，语法参考官方文档。
[[menu.main]]
    name = "Blog"
    url = ""
    weight = 1

[[menu.main]]
    name = "Tags"
    url = "tags"
    weight = 2

[[menu.main]]
    name = "About"
    url = "page/about/"
    weight = 3
```

可以看到配置项非常多，如果想修改一项后立即查看效果，Hugo自带一个有热部署功能的服务器。

```
[root@localhost myblog]# hugo server -D

                   | EN
+------------------+----+
  Pages            |  7
  Paginator pages  |  0
  Non-page files   |  0
  Static files     | 34
  Processed images |  0
  Aliases          |  1
  Sitemaps         |  1
  Cleaned          |  0

Total in 67 ms
Watching for changes in /root/myblog/{content,data,layouts,static,themes}
Watching for config changes in /root/myblog/config.toml
Serving pages from memory
Running in Fast Render Mode. For full rebuilds on change: hugo server --disableFastRender
Web Server is available at http://localhost:1313/ (bind address 127.0.0.1)
Press Ctrl+C to stop
```

访问[http://localhost:1313/](http://localhost:1313/)就可以查看修改效果。

## 为自己的博客添加内容

新建一篇文章

```
cd myblog
hugo new post/第一篇文章.md
```

该命令会在myblog/content/post目录下新建一篇文章，该文章初始只有如下内容：

```
[root@localhost myblog]# cat content/post/第一篇文章.md

# 文章头信息 使用toml格式书写
---
# 文章标题
title: "第一篇文章"
# 文章日期
date: 2018-11-29T14:00:50+08:00
# 草稿标识，true代表正式环境下不显示
draft: true
---

# 下面就可以填写文章主题内容了，使用markdown格式
```

new命令不是强制的，自行拷贝md文件进去效果一样，只要格式正确即可。

往里面添加一些内容：

```
---
# 文章标题
title: "第一篇文章"
# 文章日期
date: 2018-11-29T14:00:50+08:00
# 草稿选项，true代表正式环境下不显示
draft: true
---

这是第一段，可以作为全文索引开头。

# more标签可选，在首页只显示more标签前面的内容，没有的话在英文环境显示第一段，中文会显示全文，这应该与对语言分段的支持不好有关。
<!--more-->

文章主题内容填写到这里。

```

在首页看到的效果是这样的

![](https://images.moonlightming.top/images/20181129141321.png)

点进去看是这样的

![](https://images.moonlightming.top/images/20181129141400.png)

## 修改主题样式

官方的样式由于地域不同的原因，我们需要剔除一些元素（比如推特谷歌youtube啦啦啦），需要在样式本身上做一些修改的话。可以fork一下主题项目，然后加入自己的博客中。

主题样式采用的是golang自己的模板语法，需要有该语法基础，接下来我们修改一下样式，把下面这一排图标去掉

![](https://images.moonlightming.top/images/20181129150650.png)

```
# 我在github上fork一下beautifulhugo项目到自己的仓库，然后拉到本地
git clone https://github.com/moonlightMing/beautifulhugo

# 所有的布局文件都放在layouts之下，略微读了下代码，布局还是很清晰的，很快就定位到了元素位置
# 上图中的分享链接就是layouts/partials/share-links.html中的内容，我把这个文件置空
echo '' > layouts/partials/share-links.html
```

提交一下代码，然后回到博客项目中，替换样式项目为我自己fork的项目

```
# 因为子项目的删除比较麻烦，请自行百度，我这里是假设第一次添加样式的情景
# 此时添加的子项目经是我自己修改过的了
git submodule add https://github.com/moonlightMing/beautifulhugo.git themes/beautifulhugo
```

再看下效果就已经没有分享链接了

![](https://images.moonlightming.top/images/20181129152351.png)

大多数情况下，不爱折腾的都可以忽略掉这些小问题啦，这里只是演示。

## 部署到线上

### 原生部署

由于Hugo本身就是一个高性能服务器，因此可以直接部署到线上。

启动脚本示例：

```shell
#!/bin/bash
BIND_ADDR='0.0.0.0'
PORT=80
hugo server -v                                  \
    -p ${PORT}                                  \
    --bind=${BIND_ADDR}                         \
    --baseURL="https://blog.moonlightming.top/" \
    --appendPort=false
```

### 使用自己的服务器

如果不想使用Hugo自带的服务器，想使用Apache或者Nginx，则需要执行hugo命令生成静态文件，之后用服务器软件代理。

```
[root@localhost myblog]# cd myblog && hugo && ls public

                   | EN
+------------------+----+
  Pages            | 10
  Paginator pages  |  0
  Non-page files   |  0
  Static files     | 34
  Processed images |  0
  Aliases          |  2
  Sitemaps         |  1
  Cleaned          |  0

Total in 33 ms

# 静态文件都生成在public目录中了 使用Nginx代理一下静态资源就好
404.html  categories  css  img  index.html  index.xml  js  page  post  sitemap.xml  tags
```

### 使用Docker部署

日常更新博客自然力求便捷，Hugo也可以配合Travis进行CI/CD集成。我直接使用之前我已有的Docker方式实现CI/CD。后期会放实践记录。

这里把Dockerfile贴一下：

```yaml
FROM alpine:latest

WORKDIR /usr/app/xblog

# 我这里直接将hugo的二进制文件放在项目里，并且将bin目录置入环境变量
# 如果力求构建速度，可以将hugo二进制单独拎出来做一个镜像（多阶段构建），减少大文件拷贝时间及方便Docker直接命中缓存
ENV PATH /usr/app/xblog/bin:$PATH

ENV TIME_ZONE="Asia/Shanghai"

RUN apk add --no-cache tzdata \
     && echo ${TIME_ZONE} > /etc/timezone \
     && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

COPY . /usr/app/xblog

EXPOSE 8000

# entrypoint.sh自然就是上文的博客启动脚本
CMD ["sh", "entrypoint.sh"]
```

打好镜像后，使用自己的CI/CD方式更新容器就好。