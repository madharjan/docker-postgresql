#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

POSTGRESQL_CONFIG_PATH=/build/config/postgresql

apt-get update

## Install PostgreSQL and runit service
/build/services/postgresql/postgresql.sh

mkdir -p /etc/my_init.d
cp /build/services/20-postgresql.sh /etc/my_init.d
chmod 750 /etc/my_init.d/20-postgresql.sh

cp /build/bin/postgresql-systemd-unit /usr/local/bin
chmod 750 /usr/local/bin/postgresql-systemd-unit
