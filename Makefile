
NAME = madharjan/docker-postgresql
VERSION = 9.3

.PHONY: all build build_test clean_images test tag_latest release

all: build

build:
	docker build --build-arg POSTGRESQL_VERSION=$(VERSION) --build-arg VCS_REF=`git rev-parse --short HEAD` -t $(NAME):$(VERSION) --rm .

build_test:
	docker build --build-arg POSTGRESQL_VERSION=$(VERSION) --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg DEBUG=true -t $(NAME):$(VERSION) --rm .

clean_images:
	docker rmi $(NAME):latest $(NAME):$(VERSION) || true

test:
	env NAME=$(NAME) VERSION=$(VERSION) ./test/test.sh

tag_latest:
	docker tag $(NAME):$(VERSION) $(NAME):latest

release: test tag_latest
	@if ! docker images $(NAME) | awk '{ print $$2 }' | grep -q -F $(VERSION); then echo "$(NAME) version $(VERSION) is not yet built. Please run 'make build'"; false; fi
	@if ! head -n 1 Changelog.md | grep -q 'release date'; then echo 'Please note the release date in Changelog.md.' && false; fi
	docker push $(NAME)
	@echo "*** Don't forget to create a tag. git tag $(VERSION) && git push origin $(VERSION) ***"
