FROM amazonlinux:2023

WORKDIR /tmp

RUN yum -y update \
    && yum -y install gcc-c++ findutils tar gzip glibc zip

RUN touch ~/.bashrc && chmod +x ~/.bashrc

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

RUN source ~/.bashrc \
    && nvm install 20

WORKDIR /build

COPY index.js .

RUN source ~/.bashrc && npm init -f -y \
    && npm install aws-sdk --save \
    && npm install querystring --save \
    && npm install request --save \
    && npm install --only=prod \
    && SHARP_IGNORE_GLOBAL_LIBVIPS=1 npm install --arch=x64 --platform=linux sharp \
    && zip -r9q /image_resizer.zip *