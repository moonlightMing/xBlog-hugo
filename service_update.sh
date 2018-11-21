#!/bin/bash

docker pull registry.cn-shenzhen.aliyuncs.com/moonlightming/xblog-hugo:latest

docker service update --image registry.cn-shenzhen.aliyuncs.com/moonlightming/xblog-hugo:latest hugo_xblog-hugo --with-registry-auth