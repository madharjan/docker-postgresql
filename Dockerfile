FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for PostgreSQL Server" os_version="Ubuntu 14.04"

ARG POSTGRESQL_VERSION
ARG DEBUG=false

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/postgresql/${VERSION}/main", "/var/lib/postgresql/${VERSION}/main", "/var/log/postgresql"]

CMD ["/sbin/my_init"]

EXPOSE 5432
