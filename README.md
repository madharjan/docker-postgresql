# docker-postgresql

[![Build Status](https://travis-ci.com/madharjan/docker-postgresql.svg?branch=master)](https://travis-ci.com/madharjan/docker-postgresql)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-postgresql.svg)](http://microbadger.com/images/madharjan/docker-postgresql)

Docker container for PostgreSQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to create database, user and set password
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## PostgreSQL Server 9.5 (docker-postgresql)

### Environment

| Variable             | Default      | Example        |
|----------------------|--------------|----------------|
| DISABLE_POSTGRESQL   | 0            | 1 (to disable) |
| POSTGRESQL_DATABASE  | postgres     | mydb           |
| POSTGRESQL_USERNAME  | postgres     | myuser         |
| POSTGRESQL_PASSWORD  |              | mypass         |

## Build

```bash
# clone project
git clone https://github.com/madharjan/docker-postgresql
cd docker-postgresql

# login to DockerHub
docker login

# build
make

# tests
make run
make test

# clean
make clean
```

## Run

**Note**: update environment variables below as necessary

```bash
# prepare foldor on host for container volumes
sudo mkdir -p /opt/docker/postgresql/etc/
sudo mkdir -p /opt/docker/postgresql/lib/
sudo mkdir -p /opt/docker/postgresql/log/

# stop & remove previous instances
docker stop postgresql
docker rm postgresql

# run container
docker run -d \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypass \
  -p 5432:5432 \
  -v /opt/docker/postgresql/etc:/etc/postgresql/9.5/main \
  -v /opt/docker/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/postgresql/log:/var/log/postgresql \
  --name postgresql \
  madharjan/docker-postgresql:9.5
```

## Systemd Unit File

**Note**: update environment variables below as necessary

```txt
[Unit]
Description=PostgreSQL Server

After=docker.service

[Service]
TimeoutStartSec=0

ExecStartPre=-/bin/mkdir -p /opt/docker/postgresql/etc
ExecStartPre=-/bin/mkdir -p /opt/docker/postgresql/lib
ExecStartPre=-/bin/mkdir -p /opt/docker/postgresql/log
ExecStartPre=-/usr/bin/docker stop postgresql
ExecStartPre=-/usr/bin/docker rm postgresql
ExecStartPre=-/usr/bin/docker pull madharjan/docker-postgresql:9.5

ExecStart=/usr/bin/docker run \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypass \
  -p 5432:5432 \
  -v /opt/docker/postgresql/etc:/etc/postgresql/etc/9.5/main \
  -v /opt/docker/postgresql/lib:/var/lib/postgresql/9.5/main \
  -v /opt/docker/postgresql/log:/var/log/postgresql \
  --name postgresql \
  madharjan/docker-postgresql:9.5

ExecStop=/usr/bin/docker stop -t 2 postgresql

[Install]
WantedBy=multi-user.target
```

## Generate Systemd Unit File

| Variable                 | Default          | Example                                                          |
|--------------------------|------------------|------------------------------------------------------------------|
| PORT                     |                  | 5432                                                             |
| VOLUME_HOME              | /opt/docker      | /opt/data                                                        |
| NAME                     | postgresql       | docker-postgresql                                                |
| POSTGRESQL_DATABASE      | postgres         | mydb                                                             |
| POSTGRESQL_USERNAME      | postgres         | user                                                             |
| POSTGRESQL_PASSWORD      |                  | pass                                                             |

```bash
# generate postgresql.service
docker run --rm \
  -e PORT=5432 \
  -e NAME=docker-postgresql \
  -e POSTGRESQL_PASSWORD=pass \
  madharjan/docker-postgresql:9.5 \
  postgresql-systemd-unit | \
  sudo tee /etc/systemd/system/postgresql.service

sudo systemctl enable postgresql
sudo systemctl start postgresql
```
