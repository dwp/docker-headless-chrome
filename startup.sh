#!/bin/sh

if [ -z "$HTTP_PROXY" ]; then
    export HTTP_PROXY="";
fi;
if [ -z "$HTTPS_PROXY" ]; then
    export HTTPS_PROXY="";
fi;
if [ -z "$NO_PROXY" ]; then
    export NO_PROXY="";
fi;

# Generate unique ssh keys for this container, if needed
if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
    ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
fi

chmod 600 /etc/ssh/ssh_host_ed25519_key || true
chmod 600 /etc/ssh/ssh_host_rsa_key || true

if [ ! -z "$SFTP_PUBLIC_KEY" ]; then
    echo "Adding authorized SFTP public key"
    mkdir -p "$HOME/.ssh"
    echo "$SFTP_PUBLIC_KEY" >> $HOME/.ssh/authorized_keys
fi;

if [ ! -z "$DOWNLOADS_LOCATION" ]; then
    if [ ! -d "$DOWNLOADS_LOCATION" ]; then
        echo "Can't link downloads directory to $DOWNLOADS_LOCATION. Location does not exist"
    else
        echo "Linking downloads directory to $DOWNLOADS_LOCATION"
        mkdir -p "$DOWNLOADS_LOCATION/Downloads"
        ln -s "$DOWNLOADS_LOCATION/Downloads" "/home/alpine/Downloads"
    fi;
fi;

/usr/bin/supervisord -c /etc/supervisord.conf
