# docker-postgresql

[![Build Status](https://travis-ci.com/madharjan/docker-postgresql.svg?branch=master)](https://travis-ci.com/madharjan/docker-postgresql)
[![Layers](https://images.microbadger.com/badges/image/madharjan/docker-postgresql.svg)](http://microbadger.com/images/madharjan/docker-postgresql)

Docker container for PostgreSQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

## Features

* Environment variables to create database, user and set password
* Bats [bats-core/bats-core](https://github.com/bats-core/bats-core) based test cases

## PostgreSQL Server 9.5 (docker-postgresql)

| Variable             | Default      | Example        |
|----------------------|--------------|----------------|
| DISABLE_POSTGRESQL   | 0            | 1 (to disable) |
| POSTGRESQL_DATABASE  | postgres     | mydb           |
| POSTGRESQL_USERNAME  | postgres     | myuser         |
| POSTGRESQL_PASSWORD  |              | mypass         |

## Build

### Clone this project

```bash
git clone https://github.com/madharjan/docker-postgresql
cd docker-postgresql
```

### Build Containers

```bash
# login to DockerHub
docker login

# build
make

# tests
make run
make tests
make clean

# tag
make tag_latest

# release
make release
```

### Tag and Commit to Git

```bash
git tag 9.5
git push origin 9.5
```

## Run Container

### Prepare folder on host for container volumes

```bash
sudo mkdir -p /opt/docker/postgresql/etc/
sudo mkdir -p /opt/docker/postgresql/lib/
sudo mkdir -p /opt/docker/postgresql/log/
```

### Run `docker-postgresql`

```bash
docker stop postgresql
docker rm postgresql

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

## Run via Systemd

### Systemd Unit File - basic example

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

### Generate Systemd Unit File

| Variable                 | Default          | Example                                                          |
|--------------------------|------------------|------------------------------------------------------------------|
| PORT                     |                  | 5432                                                             |
| VOLUME_HOME              | /opt/docker      | /opt/data                                                        |
| VERSION                  | 9.5              | latest                                                           |
| NAME                     | postgresql       | docker-postgresql                                                |
| POSTGRESQL_DATABASE      | postgres         | mydb                                                             |
| POSTGRESQL_USERNAME      | postgres         | user                                                             |
| POSTGRESQL_PASSWORD      |                  | pass                                                             |

```bash
docker run --rm \
  -e PORT= \
  -e VOLUME_HOME=/opt/docker \
  -e VERSION=9.5 \
  -e NAME=docker-postgresql \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=user \
  -e POSTGRESQL_PASSWORD=pass \
  madharjan/docker-postgresql:9.5 \
  postgresql-systemd-unit | \
  sudo tee /etc/systemd/system/postgresql.service

sudo systemctl enable postgresql
sudo systemctl start postgresql
```
