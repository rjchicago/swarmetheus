FROM alpine

WORKDIR /swarmetheus
VOLUME /prometheus/files
VOLUME /prometheus/rules

# install docker
RUN apk add --update curl docker openrc bash
RUN rc-update add docker boot

COPY ./env ./env
COPY ./rules ./rules
COPY ./scripts ./scripts
RUN chmod +x scripts/*.sh

ENTRYPOINT "./scripts/entrypoint.sh"