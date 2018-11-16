#!/bin/bash
#
# @Author: moonlightming
# @Date:   2018-11-05 11:38:26
# @Last Modified by:   moonlightming
# @Last Modified time: 2018-11-05 11:40:16
BIND_ADDR='0.0.0.0'
PORT=80
./bin/hugo server -v                                \
    -p ${PORT}                                      \
    --bind=${BIND_ADDR}                             \
    --baseURL="https://blog.moonlightming.top/" \
    --appendPort=false
