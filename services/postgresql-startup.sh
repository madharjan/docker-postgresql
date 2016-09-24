#!/bin/bash

set -e

if [ "${DEBUG}" == true ]; then
  set -x
fi

pgsql_client()
{
  local cmd="$1"
  sudo su - ${POSTGRESQL_USER} -c "/usr/bin/psql -c \"${cmd}\"" 2>&1
}

DISABLE_POSTGRESQL=${DISABLE_POSTGRESQL:-0}

if [ ! "${DISABLE_POSTGRESQL}" -eq 0 ]; then
  touch /etc/service/postgresql/down
else
  rm -f /etc/service/postgresql/down
fi

POSTGRESQL_VERSION=${POSTGRESQL_VERSION:-9.3}

POSTGRESQL_DATABASE=${POSTGRESQL_DATABASE:-postgres}
POSTGRESQL_USERNAME=${POSTGRESQL_USERNAME:-postgres}
POSTGRESQL_PASSWORD=${POSTGRESQL_PASSWORD:-}
POSTGRESQL_ENCODING=${POSTGRESQL_ENCODING:-UNICODE}

POSTGRESQL_USER=postgres
POSTGRESQL_GROUP=postgres

POSTGRESQL_CONF_DIR=${POSTGRESQL_CONF_DIR:-/etc/postgresql/${POSTGRESQL_VERSION}/main}
POSTGRESQL_DATA_DIR=${POSTGRESQL_DATA_DIR:-/var/lib/postgresql/${POSTGRESQL_VERSION}/main}
POSTGRESQL_BIN_DIR=${POSTGRESQL_BIN_DIR:-/usr/lib/postgresql/${POSTGRESQL_VERSION}/bin}

mkdir -p ${POSTGRESQL_DATA_DIR}
chmod -R 0700 ${POSTGRESQL_DATA_DIR}
chown -R ${POSTGRESQL_USER}:${POSTGRESQL_GROUP} ${POSTGRESQL_DATA_DIR}

cd ${POSTGRESQL_DATA_DIR}

if [ ! -s "$POSTGRESQL_DATA_DIR/PG_VERSION" ]; then
  echo "Initializing database ..."
  pg_createcluster -u ${POSTGRESQL_USER} -g ${POSTGRESQL_GROUP} -d ${POSTGRESQL_DATA_DIR} ${POSTGRESQL_VERSION} main

  if [ "$POSTGRESQL_PASSWORD" ]; then
    { echo; echo "host all all 0.0.0.0/0 md5"; } >> "${POSTGRESQL_CONF_DIR}/pg_hba.conf"
    { echo; echo "listen_addresses='*'"; } >> "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  else
    cat >&2 <<-'EOWARN'
****************************************************
WARNING: No password has been set for the database.
         Use "-e POSTGRESQL_PASSWORD=password" to
         set it in "docker run".
****************************************************
EOWARN
  fi

  pg_ctlcluster ${POSTGRESQL_VERSION} main start

  if [ "$POSTGRESQL_DATABASE" != 'postgres' ]; then
    echo "Creating database ..."
    pgsql_client "CREATE DATABASE ${POSTGRESQL_DATABASE} ENCODING '${POSTGRESQL_ENCODING}';"
  fi

  echo "Granting access to database \"${POSTGRESQL_DATABASE}\" for user \"${POSTGRESQL_USERNAME}\"..."
  if [ "$POSTGRESQL_USERNAME" = 'postgres' ]; then
      OPERATION='ALTER'
  else
      OPERATION='CREATE'
  fi
  pgsql_client "${OPERATION} USER ${POSTGRESQL_USERNAME} WITH SUPERUSER PASSWORD '$POSTGRESQL_PASSWORD';"
  pgsql_client "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRESQL_DATABASE} TO ${POSTGRESQL_USERNAME};"

  pg_ctlcluster ${POSTGRESQL_VERSION} main stop

  echo 'PostgreSQL init process complete; ready for start up.'
fi
