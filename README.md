# docker-headless-chrome
Dataworks Hardened Headless Chrome container

This repo contains the docker image used to provide the Chrome frontend onto the analytical environment.
The desktop is hosted by a VNC server.

In addition, the docker images contains an embedded SFTP server to allow upload/download via Guacamole's [SFTP integration](https://guacamole.apache.org/doc/gug/configuring-guacamole.html#ssh).

The container accepts the following environment variables:

| Name | Description |
-------|-------------
HTTP_PROXY | sites to use the internet proxy to connect to.
HTTPS_PROXY | as above.
NO_PROXY | sites to connect to directly
SFTP_PUBLIC_KEY | A public key used to connect to the SFTP service.
DOWNLOADS_LOCATION | A directory to store Chrome downloads in, usually points to a mounted S3 location.
VNC_SCREEN_SIZE | The screen size for the VNC desktop
VNC_OPTS | VNC specific options
CONTAINER_INFO | A list of URLs to open by default in the Chrome app

The docker image is published to dockerhub under dwpdigital/headless-chrome
