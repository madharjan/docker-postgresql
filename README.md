# docker-postgresql

[![](https://images.microbadger.com/badges/version/madharjan/docker-postgresql.svg)](http://microbadger.com/images/madharjan/docker-postgresql "Get your own version badge on microbadger.com")

Docker container for PostgreSQL Server based on [madharjan/docker-base](https://github.com/madharjan/docker-base/)

* PostgreSQL Server 9.3 (docker-postgresql)

**Environment**

| Variable             | Default      | Example        |
|----------------------|--------------|----------------|
| DISABLE_POSTGRESQL   | 0            | 1 (to disable) |
| POSTGRESQL_DATABASE  | postgres     | mydb           |
| POSTGRESQL_USERNAME  | postgres     | myuser         |
| POSTGRESQL_PASSWORD  |              | mypass         |

## Build

**Clone this project**
```
git clone https://github.com/madharjan/docker-postgresql
cd docker-postgresql
```

**Build Containers**
```
# login to DockerHub
docker login

# build
make

# test
make run
make tests
make clean

# tag
make tag_latest

# update Changelog.md
# release
make release
```

**Tag and Commit to Git**
```
git tag 9.3
git push origin 9.3
```

## Run Container

### PostgreSQL

**Prepare folder on host for container volumes**
```
sudo mkdir -p /opt/docker/postgresql/etc/
sudo mkdir -p /opt/docker/postgresql/lib/
sudo mkdir -p /opt/docker/postgresql/log/
```

**Run `docker-postgresql`**
```
docker stop postgresql
docker rm postgresql

docker run -d \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypass \
  -p 5432:5432 \
  -v /opt/docker/postgresql/etc:/etc/postgresql/9.3/main \
  -v /opt/docker/postgresql/lib:/var/lib/postgresql/9.3/main \
  -v /opt/docker/postgresql/log:/var/log/postgresql \
  --name postgresql \
  madharjan/docker-postgresql:9.3
```

**Systemd Unit File**
```
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
ExecStartPre=-/usr/bin/docker pull madharjan/docker-postgresql:9.3

ExecStart=/usr/bin/docker run \
  -e POSTGRESQL_DATABASE=mydb \
  -e POSTGRESQL_USERNAME=myuser \
  -e POSTGRESQL_PASSWORD=mypass \
  -p 172.17.0.1:5432:5432 \
  -v /opt/docker/postgresql/etc/:/etc/postgresql/etc/9.3/main \
  -v /opt/docker/postgresql/lib/:/var/lib/postgresql/9.3/main \
  -v /opt/docker/postgresql/log:/var/log/postgresql \
  --name postgresql \
  madharjan/docker-postgresql:9.3

ExecStop=/usr/bin/docker stop -t 2 postgresql

[Install]
WantedBy=multi-user.target
```
