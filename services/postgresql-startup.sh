#!/bin/bash

set -e

if [ "$DEBUG" == true ]; then
  set -x
fi
POSTGRESQL_VERSION=${POSTGRESQL_VERSION:-9.3}

POSTGRESQL_DB_NAME=${POSTGRESQL_DB_NAME:-postgres}
POSTGRESQL_DB_USERNAME=${POSTGRESQL_DB_USERNAME:-postgres}
POSTGRESQL_DB_PASSWORD=${POSTGRESQL_DB_PASSWORD:-}

POSTGRESQL_USER=${POSTGRESQL_USER:-postgres}
POSTGRESQL_DATA_DIR=${POSTGRESQL_DATA_DIR:-/var/lib/postgresql/data}

mkdir -p ${POSTGRESQL_DATA_DIR}
chmod -R 0700 ${POSTGRESQL_DATA_DIR}
chown -R ${POSTGRESQL_USER}:${POSTGRESQL_USER} ${POSTGRESQL_DATA_DIR}


if [ ! -s "$POSTGRESQL_DATA_DIR/PG_VERSION" ]; then
  echo "Initializing database ..."
  /sbin/setuser postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/initdb -D ${POSTGRESQL_DATA_DIR}

  if [ "$POSTGRESQL_DB_PASSWORD" ]; then
    PASS="PASSWORD '$POSTGRESQL_DB_PASSWORD'"
    AUTHMETHOD=md5

    { echo; echo "host all all 0.0.0.0/0 $AUTHMETHOD"; } >> "$POSTGRESQL_DATA_DIR/pg_hba.conf"

  else
    cat >&2 <<-'EOWARN'
****************************************************
WARNING: No password has been set for the database.
         Use "-e POSTGRESQL_DB_PASSWORD=password" to
         set it in "docker run".
****************************************************
EOWARN

  fi

  echo "Starting PostgreSQL Server ..."
  /sbin/setuser postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/pg_ctl -D "$POSTGRESQL_DATA_DIR" -o "-c listen_addresses='localhost'" -w start

  export POSTGRESQL_DB_NAME POSTGRESQL_DB_USERNAME
  psql=( psql -v ON_ERROR_STOP=1 )

  echo "Creating database ..."
  if [ "$POSTGRESQL_DB_NAME" != 'postgres' ]; then
    "${psql[@]}" --username postgres <<-EOSQL
        CREATE DATABASE "$POSTGRESQL_DB_NAME" ;
EOSQL
      echo
  fi

  echo "Granting access to database \"${POSTGRESQL_DB_NAME}\" for user \"${POSTGRESQL_DB_USERNAME}\"..."

  if [ "$POSTGRESQL_DB_USERNAME" = 'postgres' ]; then
      OPERATION='ALTER'
  else
      OPERATION='CREATE'
  fi

  "${psql[@]}" --username postgres <<-EOSQL
      $OPERATION USER "$POSTGRESQL_DB_USERNAME" WITH SUPERUSER $PASS ;
EOSQL
  echo

  /sbin/setuser postgres /usr/lib/postgresql/${POSTGRESQL_VERSION}/bin/pg_ctl -D "$POSTGRESQL_DATA_DIR" -m fast -w stop


  echo 'PostgreSQL init process complete; ready for start up.'
fi
