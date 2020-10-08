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

/usr/bin/supervisord -c /etc/supervisord.conf
