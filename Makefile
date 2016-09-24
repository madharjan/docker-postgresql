
NAME = madharjan/docker-postgresql
VERSION = 9.3

.PHONY: all build run tests clean tag_latest release clean_images

all: build

build:
	docker build \
	 --build-arg POSTGRESQL_VERSION=$(VERSION) \
	 --build-arg VCS_REF=`git rev-parse --short HEAD` \
	 --build-arg DEBUG=true \
	 -t $(NAME):$(VERSION) --rm .

run:
	rm -rf /tmp/postgresql
	mkdir -p /tmp/postgresql

	docker run -d -t \
		-e POSTGRESQL_DATABASE=mydb \
		-e POSTGRESQL_USERNAME=myuser \
		-e POSTGRESQL_PASSWORD=mypass \
		-v /tmp/postgresql/etc/:/etc/postgresql/9.3/main \
		-v /tmp/postgresql/lib:/var/lib/postgresql/9.3/main \
		-e DEBUG=true \
		--name postgresql -t $(NAME):$(VERSION)

	docker run -d -t \
		-e DISABLE_POSTGRESQL=1 \
		-e DEBUG=true \
		--name postgresql_no_postgresql -t $(NAME):$(VERSION)

	docker run -d -t \
		-e DEBUG=true \
	  --name postgresql_default -t $(NAME):$(VERSION)
tests:
	./bats/bin/bats test/tests.bats

clean:
	docker exec -t postgresql /bin/bash -c "sv stop postgresql" || true
	sleep 2
	docker exec -t postgresql /bin/bash -c "rm -rf /etc/postgresql/9.3/main/*" || true
	docker exec -t postgresql /bin/bash -c "rm -rf /var/lib/postgresql/9.3/main/*" || true
	docker stop postgresql postgresql_no_postgresql postgresql_default || true
	docker rm postgresql postgresql_no_postgresql postgresql_default || true
	rm -rf /tmp/postgresql || true

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
	curl -X https://hooks.microbadger.com/images/madharjan/docker-postgresql/jaJQb-O_tU-ZppG--6GHnJSaiBU=

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true
