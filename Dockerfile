FROM alpine:latest

WORKDIR /usr/app/xblog

COPY . /usr/app/xblog

ENV PATH /usr/app/xblog/bin:$PATH

EXPOSE 8000

CMD ["sh", "entrypoint.sh"]
