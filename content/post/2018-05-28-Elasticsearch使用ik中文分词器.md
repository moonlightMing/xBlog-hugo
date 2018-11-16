---
title: Elasticsearch之使用ik中文分词器
date: 2018-05-28
tags: ["elk", "运维开发"]
draft: false
---

分词器是全文检索引擎非常重要的一部分，用于将一段话拆分为一系列词语，进行文本分析用以维护内部倒排索引。
之前一直使用默认分词器，博客上线后实测对中文的检索效果非常差，因此了解了下这块内容。

<!--more-->

目前了解到比较著名的分词器有两种：

- IK分词器
- jieba分词器

这两款分词器都有很高的热度，之前在做django全文检索功能时接触过jieba，因此这次尝试IK分词器。由于我的博客环境已经使用docker进行部署，因此es也会使用容器进行编排管理。

## 部署

首先看看常规部署方式，这个在github主页上已经详细说明了：[elasticsearch-analysis-ik](https://github.com/medcl/elasticsearch-analysis-ik)

分为两种方式，自动化安装是使用elasticsearch-plugin工具进行自解压安装。手动则是将插件解压至es-root/plugins目录下。既然要容器化那就要选择手动的方式进行镜像打包，我使用的ES版本是目前最新的6.2.4。

修改配置elasticsearch.yml，设定默认分词器：
```yaml
cluster.name: "docker-cluster"
network.host: 0.0.0.0

# minimum_master_nodes need to be explicitly set when bound on a public IP
# set to 1 to allow single node clusters
# Details: https://github.com/elastic/elasticsearch/pull/17288
discovery.zen.minimum_master_nodes: 1
xpack.license.self_generated.type: basic

# 新增如下这条,用于指定默认分词器
index.analysis.analyzer.default.type: ik
```

然后在建立数据模型时设定分词粒度，IK有两种：

- ik_max_word 
    用来做最大限度的拆分，穷尽各种组合。
- ik_smart
    反之，最粗粒度的拆分。

```shell
curl -XPOST http://localhost:9200/index/fulltext/_mapping -H 'Content-Type:application/json' -d'
{
    "properties": {
        "content": {
            "type": "text",
            "analyzer": "ik_max_word",          //指定拆分粒度
            "search_analyzer": "ik_max_word"
        }
    }
}'
```

重建索引，之后的搜索结果会发现有明显的中文语义化分词，案例可以参考官网自己进行试验。

## 容器化打包
```
FROM docker.elastic.co/elasticsearch/elasticsearch:6.2.4 

COPY --chown=elasticsearch:elasticsearch elasticsearch.yml /usr/share/elasticsearch/config/

COPY elasticsearch_ik_plugins /usr/share/elasticsearch/plugins/ik
```

和部署文件docker-compose.yml
```yaml
version: "3.3"
services:
  elasticsearch:
    deploy:
      resources:
        limits:
          cpus: "0.2"
          memory: "1024M"
    image: docker.elastic.co/elasticsearch/elasticsearch:6.2.4
    environment:
      - "cluster.name=docker-cluster"
      - "bootstrap.memory_lock=true"
      - "ES_JAVA_OPTS=-Xms256m -Xmx1024m"
      - "ELASTIC_PASSWORD=MagicWord"
      - "discovery.type=single-node"
    ports:
      - 9200:9200
    networks:
      - elk-network
    volumes:
      - /opt/esdata:/usr/share/elasticsearch/data
    user: "1001" #elastic用户的uid
```
