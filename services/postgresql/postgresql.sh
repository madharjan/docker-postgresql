#!/bin/bash
set -e
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

if [ "${DEBUG}" = true ]; then
  set -x
fi

POSTGRESQL_BUILD_PATH=/build/services/postgresql

## Install PostgreSQL Server
apt-get install -y --no-install-recommends postgresql-common
sed -ri 's/#(create_main_cluster) .*$/\1 = false/' /etc/postgresql-common/createcluster.conf
apt-get install -y --no-install-recommends \
  postgresql \
  postgresql-contrib


mkdir -p /var/run/postgresql/9.5-main.pg_stat_tmp
chown postgres:postgres /var/run/postgresql/9.5-main.pg_stat_tmp -R

mkdir -p /etc/service/postgresql
cp ${POSTGRESQL_BUILD_PATH}/postgresql.runit /etc/service/postgresql/run
chmod 750 /etc/service/postgresql/run

## Configure logrotate
