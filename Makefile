
NAME = madharjan/docker-postgresql
VERSION = 9.5

DEBUG ?= true

.PHONY: all build run tests stop clean tag_latest release clean_images

all: build

build:
	docker build \
	 --build-arg POSTGRESQL_VERSION=$(VERSION) \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=${DEBUG} \
	 -t $(NAME):$(VERSION) --rm .

run:
	rm -rf /tmp/postgresql
	mkdir -p /tmp/postgresql

	docker run -d \
		-e POSTGRESQL_DATABASE=mydb \
		-e POSTGRESQL_USERNAME=myuser \
		-e POSTGRESQL_PASSWORD=mypass \
		-v /tmp/postgresql/etc/:/etc/postgresql/$(VERSION)/main \
		-v /tmp/postgresql/lib:/var/lib/postgresql/$(VERSION)/main \
		-e DEBUG=${DEBUG} \
		--name postgresql $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DISABLE_POSTGRESQL=1 \
		-e DEBUG=${DEBUG} \
		--name postgresql_no_postgresql $(NAME):$(VERSION)

	sleep 2

	docker run -d \
		-e DEBUG=${DEBUG} \
	  --name postgresql_default $(NAME):$(VERSION)
	
	sleep 3

tests:
	sleep 5
	./bats/bin/bats test/tests.bats

stop:
	docker exec postgresql /bin/bash -c "sv stop postgresql" || true
	sleep 2
	docker exec postgresql /bin/bash -c "rm -rf /etc/postgresql/9.3/main/*" || true
	docker exec postgresql /bin/bash -c "rm -rf /var/lib/postgresql/9.3/main/*" || true
	docker stop postgresql postgresql_no_postgresql postgresql_default || true

clean: stop
	docker rm postgresql postgresql_no_postgresql postgresql_default || true
	rm -rf /tmp/postgresql || true
	docker images | grep "^<none>" | awk '{print$3 }' | xargs docker rmi || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: run tests clean tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -s -X POST https://hooks.microbadger.com/images/$(NAME)/jaJQb-O_tU-ZppG--6GHnJSaiBU=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
