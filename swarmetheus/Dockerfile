FROM alpine

WORKDIR /swarmetheus
VOLUME /swarmetheus_data

# install docker
RUN apk add --update curl docker openrc bash
RUN rc-update add docker boot

COPY ./env ./env
COPY ./rules ./rules
COPY ./scripts ./scripts
COPY ./config ./config
RUN chmod +x scripts/*.sh

ENTRYPOINT "./scripts/entrypoint.sh"