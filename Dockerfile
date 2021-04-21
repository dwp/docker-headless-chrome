FROM quay.io/centos/centos:stream8

RUN dnf -y update && dnf -y install epel-release
RUN dnf -y install x11vnc chromium supervisor openssh-server \
           xorg-x11-fonts-100dpi.noarch \
           xorg-x11-fonts-75dpi.noarch \
           xorg-x11-fonts-ISO8859-1-100dpi.noarch \
           xorg-x11-fonts-ISO8859-1-75dpi.noarch \
           xorg-x11-fonts-ISO8859-14-100dpi.noarch \
           xorg-x11-fonts-ISO8859-14-75dpi.noarch \
           xorg-x11-fonts-ISO8859-15-100dpi.noarch \
           xorg-x11-fonts-ISO8859-15-75dpi.noarch \
           xorg-x11-fonts-ISO8859-2-100dpi.noarch \
           xorg-x11-fonts-ISO8859-2-75dpi.noarch \
           xorg-x11-fonts-ISO8859-9-100dpi.noarch \
           xorg-x11-fonts-ISO8859-9-75dpi.noarch \
           xorg-x11-fonts-Type1.noarch \
           xorg-x11-fonts-cyrillic.noarch \
           xorg-x11-fonts-ethiopic.noarch \
           xorg-x11-fonts-misc.noarch

RUN groupadd user \
    && useradd -g user -u 1001 -s /bin/sh user \
    && echo "user:user" | /usr/sbin/chpasswd \
    && mkdir -p /var/log/supervisord \
    && chown -R user:user /var/log/supervisord

RUN mkdir -p /var/run/sshd  \
    && rm -f /etc/ssh/ssh_host_*key* \
    && chown -R user:user /etc/ssh \
    && mkdir -p /var/run/sftp \
    && chown -R user:user /var/run/sftp \
    && echo "user" > "/var/run/sftp/users.conf"

COPY etc/supervisord.conf /etc/supervisord.conf
COPY etc/sshd_config /etc/ssh/sshd_config
COPY --chown=user:user startup.sh /home/user/startup.sh

ENV TEMPLATE_PATH "/opt/dataworks/tooling_status_check.html"
COPY tooling_status_check.* /opt/dataworks/

RUN chmod u+x /home/user/startup.sh

WORKDIR /home/user

EXPOSE 5900
EXPOSE 22

USER user

CMD ["/home/user/startup.sh"]
