REPO=dok3r
NAME=ulx3s-saxonsoc
IMAGE=$(REPO)/$(NAME)
OSTYPE=$(shell uname -s | tr '[A-Z]' '[a-z]')
MACHINE=$(shell uname -m)
ARCH=$(OSTYPE)-$(MACHINE)
VERSION=$(shell date '+%Y.%m.%d')

ver:
	echo $(IMAGE) version $(VERSION)

build:
	docker build -t $(IMAGE):v$(VERSION) .

push:
	docker push $(IMAGE):v$(VERSION)

pull:
	docker pull $(IMAGE):v$(VERSION)

latest:
	docker tag $(IMAGE):v$(VERSION) $(IMAGE):latest
	docker push $(IMAGE):latest

gittag:
	git tag v$(VERSION)
	git push --tags origin master

clean:
	rm -rf dist work

rel:
	ghr v$(VERSION) dist/

draft:
	ghr -draft v$(VERSION) dist/
