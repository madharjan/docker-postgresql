FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

ARG VCS_REF
ARG POSTGRESQL_VERSION
ARG DEBUG=false

LABEL description="Docker container for PostgreSQL Server" os_version="Ubuntu ${UBUNTU_VERSION}" \
      org.label-schema.vcs-ref=${VCS_REF} org.label-schema.vcs-url="https://github.com/madharjan/docker-postgresql"

ENV POSTGRESQL_VERSION ${POSTGRESQL_VERSION}

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/etc/postgresql/${POSTGRESQL_VERSION}/main", "/var/lib/postgresql/${POSTGRESQL_VERSION}/main", "/var/log/postgresql"]

CMD ["/sbin/my_init"]

EXPOSE 5432
