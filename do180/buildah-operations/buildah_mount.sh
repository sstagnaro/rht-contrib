#!/usr/bin/env bash

set -e
source /usr/local/etc/ocp4.config

# create a working container
newcontainer=$(buildah from ubi7/ubi:7.7)

# mount the container overlay on the host
containermnt=$(buildah mount $newcontainer)

# install packages with the host yum instance
yum install -y --installroot $containermnt httpd
yum clean all -y --installroot $containermnt

# run commands
buildah run $newcontainer bash -c 'echo "Hello from Dockerfile" > /var/www/html/index.html'

# image configuration
buildah config --label maintainer="Your Name <youremail>" \
               --label description="A custom Apache container based on UBI 7" \
               --port 80 \
               --cmd "httpd -D FOREGROUND" \
               $newcontainer

# commit the image to local cache
buildah commit --rm $newcontainer quay.io/${RHT_OCP4_QUAY_USER}/basic-apache:latest

# push the image to quay.io (please login first with buildah login quay.io)
buildah push quay.io/${RHT_OCP4_QUAY_USER}/basic-apache:latest
