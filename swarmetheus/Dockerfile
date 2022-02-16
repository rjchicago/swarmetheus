FROM alpine

WORKDIR /swarmetheus
VOLUME /swarmetheus/env

# install docker
RUN apk add --update curl docker openrc bash
RUN rc-update add docker boot

COPY ./src ./src
RUN chmod +x src/*.sh

ENTRYPOINT "./src/entrypoint.sh"