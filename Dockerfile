FROM alpine:latest

MAINTAINER Casey Rogers

RUN apk update \ 
    &&  apk upgrade

RUN apk add x11vnc xvfb supervisor \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && addgroup alpine \
    && adduser  -G alpine -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && apk add --no-cache python3 libstdc++ harfbuzz nss freetype ttf-freefont \
    && apk add chromium@edge

COPY etc/supervisord.conf /etc/supervisord.conf

WORKDIR /home/alpine

EXPOSE 5900

USER alpine

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
