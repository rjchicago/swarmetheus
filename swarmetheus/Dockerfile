FROM alpine

WORKDIR /swarmetheus
VOLUME /swarmetheus/env
VOLUME /swarmetheus/files

# install docker
RUN apk add --update curl docker openrc bash
RUN rc-update add docker boot

COPY ./env ./env
COPY ./scripts ./scripts
RUN chmod +x scripts/*.sh

ENTRYPOINT "./scripts/entrypoint.sh"