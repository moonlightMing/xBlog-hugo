FROM klakegg/hugo:0.82.0-onbuild as builder

COPY . /src

FROM nginx:1.19.10

COPY --from=builder /target /usr/share/nginx/html