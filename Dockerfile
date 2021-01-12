FROM alpine:latest

MAINTAINER Casey Rogers

RUN apk update \ 
    &&  apk upgrade

RUN apk add x11vnc xvfb supervisor \
    && addgroup alpine \
    && adduser  -G alpine -u 1001 -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && apk add --no-cache python3 libstdc++ chromium harfbuzz nss freetype ttf-freefont

COPY etc/supervisord.conf /etc/supervisord.conf
COPY --chown=alpine:alpine startup.sh /home/alpine/startup.sh

RUN chmod u+x /home/alpine/startup.sh

WORKDIR /home/alpine

EXPOSE 5900

USER alpine

CMD ["/home/alpine/startup.sh"]
