ALL_JSONNET := $(shell find . -name "*.jsonnet")
IMAGE_NAME := avastsoftware/luftsonnet
COMMIT := $(shell git rev-parse HEAD)
ACTUAL_IMAGE := $(IMAGE_NAME):$(COMMIT)

build:
	docker build -t $(ACTUAL_IMAGE) .

ci: test clean

test: build
	$(foreach var, $(ALL_JSONNET),docker run -it --rm -v $$PWD:/wd -w /wd $(ACTUAL_IMAGE) $(var) >| $(var).json)
	docker run --rm -v $$PWD/tests:/wd -w /wd avastsoftware/perl-extended bash -c "cpanm --installdeps .; perl test.pl ."

clean:
	find . -name "*.jsonnet.json" -delete

push:
	docker login -u $$DOCKER_USERNAME -p $$DOCKER_PASSWORD
	docker tag $(ACTUAL_IMAGE) $(IMAGE_NAME):$$TRAVIS_TAG
	docker push $(IMAGE_NAME):$$TRAVIS_TAG
