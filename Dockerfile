FROM madharjan/docker-base:14.04
MAINTAINER Madhav Raj Maharjan <madhav.maharjan@gmail.com>

LABEL description="Docker container for PostgreSQL Server" os_version="Ubuntu 14.04"

ENV HOME /var/lib/postgresql
ARG DEBUG=false

RUN mkdir -p /build
COPY . /build

RUN /build/scripts/install.sh && /build/scripts/cleanup.sh

VOLUME ["/var/lib/postgresql", "/var/log/postgresql"]

CMD ["/sbin/my_init"]

EXPOSE 5432
