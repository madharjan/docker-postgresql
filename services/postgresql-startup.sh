#!/bin/bash

set -e

if [ "$DEBUG" == true ]; then
  set -x
fi

pgsql_client()
{
  local cmd="$1"
  sudo su - postgres -c "/usr/bin/psql -c \"${cmd}\"" 2>&1
}

POSTGRESQL_VERSION=${POSTGRESQL_VERSION:-9.3}

POSTGRESQL_DB_NAME=${POSTGRESQL_DB_NAME:-postgres}
POSTGRESQL_DB_USERNAME=${POSTGRESQL_DB_USERNAME:-postgres}
POSTGRESQL_DB_PASSWORD=${POSTGRESQL_DB_PASSWORD:-}
POSTGRESQL_DB_ENCODING=${POSTGRESQL_DB_ENCODING:-UNICODE}

POSTGRESQL_USER=${POSTGRESQL_USER:-postgres}

POSTGRESQL_CONF_DIR=${POSTGRESQL_CONF_DIR:-/etc/postgresql/${POSTGRESQL_VERSION}/main}
POSTGRESQL_DATA_DIR=${POSTGRESQL_DATA_DIR:-/var/lib/postgresql/${POSTGRESQL_VERSION}/main}
POSTGRESQL_BIN_DIR=${POSTGRESQL_BIN_DIR:-/usr/lib/postgresql/${POSTGRESQL_VERSION}/bin}

mkdir -p ${POSTGRESQL_DATA_DIR}
chmod -R 0700 ${POSTGRESQL_DATA_DIR}
chown -R ${POSTGRESQL_USER}:${POSTGRESQL_USER} ${POSTGRESQL_DATA_DIR}

cd ${POSTGRESQL_DATA_DIR}

if [ ! -s "$POSTGRESQL_DATA_DIR/PG_VERSION" ]; then
  echo "Initializing database ..."
  pg_createcluster -d ${POSTGRESQL_DATA_DIR} ${POSTGRESQL_VERSION} main

  if [ "$POSTGRESQL_DB_PASSWORD" ]; then
    { echo; echo "host all all 0.0.0.0/0 md5"; } >> "${POSTGRESQL_CONF_DIR}/pg_hba.conf"
    { echo; echo "listen_addresses='*'"; } >> "${POSTGRESQL_CONF_DIR}/postgresql.conf"
  else
    cat >&2 <<-'EOWARN'
****************************************************
WARNING: No password has been set for the database.
         Use "-e POSTGRESQL_DB_PASSWORD=password" to
         set it in "docker run".
****************************************************
EOWARN
  fi

  pg_ctlcluster ${POSTGRESQL_VERSION} main start

  if [ "$POSTGRESQL_DB_NAME" != 'postgres' ]; then
    echo "Creating database ..."
    pgsql_client "CREATE DATABASE ${POSTGRESQL_DB_NAME} ENCODING '${POSTGRESQL_DB_ENCODING}';"
  fi

  echo "Granting access to database \"${POSTGRESQL_DB_NAME}\" for user \"${POSTGRESQL_DB_USERNAME}\"..."
  if [ "$POSTGRESQL_DB_USERNAME" = 'postgres' ]; then
      OPERATION='ALTER'
  else
      OPERATION='CREATE'
  fi
  pgsql_client "${OPERATION} USER ${POSTGRESQL_DB_USERNAME} WITH SUPERUSER PASSWORD '$POSTGRESQL_DB_PASSWORD';"
  pgsql_client "GRANT ALL PRIVILEGES ON DATABASE ${POSTGRESQL_DB_NAME} TO ${POSTGRESQL_DB_USERNAME};"

  pg_ctlcluster ${POSTGRESQL_VERSION} main stop

  echo 'PostgreSQL init process complete; ready for start up.'
fi
