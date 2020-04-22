FROM alpine:latest

MAINTAINER Casey Rogers

RUN apk update \ 
    &&  apk upgrade

RUN apk add x11vnc xvfb supervisor \
    && addgroup alpine \
    && adduser  -G alpine -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/community > /etc/apk/repositories \
    && echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories \
    && apk add --no-cache libstdc++@edge chromium@edge harfbuzz@edge nss@edge freetype@edge ttf-freefont@edge

COPY etc/supervisord.conf /etc/supervisord.conf

WORKDIR /home/alpine

EXPOSE 5900

USER alpine

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
