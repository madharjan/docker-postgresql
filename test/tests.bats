@test "checking process: postgresql (master enabled by default)" {
  run docker exec postgresql /bin/bash -c "ps aux | grep -v grep | grep '/usr/lib/postgresql/9.5/bin/postgres'"
  [ "$status" -eq 0 ]
}

@test "checking process: postgresql (workers enabled by default)" {
  run docker exec postgresql /bin/bash -c "ps aux | grep -v grep | grep 'postgres:' | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 5 ]
}

@test "checking process: postgresql (master disabled by DISABLE_POSTGRESQL)" {
  run docker exec postgresql_no_postgresql /bin/bash -c "ps aux | grep -v grep | grep '/usr/lib/postgresql/9.5/bin/postgres'"
  [ "$status" -eq 1 ]
}

@test "checking process: postgresql (workers disabled by DISABLE_POSTGRESQL)" {
  run docker exec postgresql_no_postgresql /bin/bash -c "ps aux | grep -v grep | grep 'postgres:'"
  [ "$status" -eq 1 ]
}

@test "checking database: postgres (default)" {
  run docker exec postgresql_default /bin/bash -c "su - postgres -c \"/usr/bin/psql --list | awk -F'|' '{print $1}' | grep postgres\""
  [ "$status" -eq 0 ]
}

@test "checking database: postgres (mydb)" {
  run docker exec postgresql /bin/bash -c "su - postgres -c \"/usr/bin/psql --list | awk -F'|' '{print $1}' | grep mydb\""
  [ "$status" -eq 0 ]
}

@test "checking sql: postgres" {
  
  run docker exec postgresql_default /bin/bash -c "su - postgres -c \" /usr/bin/psql -P 'tuples_only' -c \
    'SELECT datname FROM pg_database WHERE datistemplate = false;' \
    \" | grep postgres | xargs"
  [ "$status" -eq 0 ]
  [ "$output" = "postgres" ]
}

@test "checking process: postgresql - reload (master enabled by default)" {
  docker stop postgresql
  docker rm postgresql
  docker run -d \
    -e POSTGRESQL_DATABASE=mydb \
    -e POSTGRESQL_USERNAME=myuser \
    -e POSTGRESQL_PASSWORD=mypass \
    -v /tmp/postgresql/etc/:/etc/postgresql/9.5/main \
    -v /tmp/postgresql/lib:/var/lib/postgresql/9.5/main \
    -e DEBUG=${DEBUG} \
    --name postgresql madharjan/docker-postgresql:9.5
  sleep 5
  run docker exec postgresql /bin/bash -c "ps aux | grep -v grep | grep '/usr/lib/postgresql/9.5/bin/postgres'"
  [ "$status" -eq 0 ]
}

@test "checking process: postgresql - reload (workers enabled by default)" {
  run docker exec postgresql /bin/bash -c "ps aux | grep -v grep | grep 'postgres:' | wc -l"
  [ "$status" -eq 0 ]
  [ "$output" -eq 5 ]
}

@test "checking database: postgres - reload (default)" {
  run docker exec postgresql_default /bin/bash -c "su - postgres -c \"/usr/bin/psql --list | awk -F'|' '{print $1}' | grep postgres\""
  [ "$status" -eq 0 ]
}

@test "checking database: postgres - reload (mydb)" {
  run docker exec postgresql /bin/bash -c "su - postgres -c \"/usr/bin/psql --list | awk -F'|' '{print $1}' | grep mydb\""
  [ "$status" -eq 0 ]
}
