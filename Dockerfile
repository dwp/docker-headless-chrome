FROM alpine:latest

LABEL MAINTAINER "Casey Rogers"

RUN apk update \ 
    &&  apk upgrade

RUN apk add x11vnc xvfb supervisor \
    && addgroup alpine \
    && adduser  -G alpine -u 1001 -s /bin/sh -D alpine \
    && echo "alpine:alpine" | /usr/sbin/chpasswd \
    && apk add --no-cache python3 libstdc++ chromium harfbuzz nss freetype ttf-freefont \
    && mkdir -p /var/log/supervisord \
    && chown -R alpine:alpine /var/log/supervisord

RUN apk add openssh openssh-sftp-server openssh-server-pam \
    && mkdir -p /var/run/sshd  \
    && rm -f /etc/ssh/ssh_host_*key* \
    && chown -R alpine:alpine /etc/ssh \
    && mkdir -p /var/run/sftp \
    && chown -R alpine:alpine /var/run/sftp \
    && echo "alpine" > "/var/run/sftp/users.conf"

COPY etc/supervisord.conf /etc/supervisord.conf
COPY etc/sshd_config /etc/ssh/sshd_config
COPY --chown=alpine:alpine startup.sh /home/alpine/startup.sh

RUN chmod u+x /home/alpine/startup.sh

WORKDIR /home/alpine

EXPOSE 5900
EXPOSE 22

USER alpine

CMD ["/home/alpine/startup.sh"]
