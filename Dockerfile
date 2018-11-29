FROM alpine:latest

WORKDIR /usr/app/xblog

ENV PATH /usr/app/xblog/bin:$PATH

ENV TIME_ZONE="Asia/Shanghai"

RUN apk add --no-cache tzdata \
     && echo ${TIME_ZONE} > /etc/timezone \
     && ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

EXPOSE 8000

COPY . /usr/app/xblog

CMD ["sh", "entrypoint.sh"]
