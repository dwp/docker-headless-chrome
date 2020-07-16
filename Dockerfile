FROM alpine:latest

MAINTAINER Casey Rogers

RUN apk update \ 
    &&  apk upgrade

RUN apk add x11vnc xvfb supervisor \
    && addgroup alpine \
    && adduser  -G alpine -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && apk add --no-cache python3 libstdc++ chromium harfbuzz nss freetype ttf-freefont

COPY etc/supervisord.conf /etc/supervisord.conf

WORKDIR /home/alpine

EXPOSE 5900

USER alpine

CMD ["/usr/bin/supervisord","-c","/etc/supervisord.conf"]
