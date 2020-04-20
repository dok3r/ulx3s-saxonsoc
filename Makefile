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

bins:
	./wrap.sh -e FPGA_SIZE="12 25 45 85" -e SDRAM_SIZE=32 -e DIST_OUT=/dist/saxon-32-$(VERSION)

bins64:
	./wrap.sh -e FPGA_SIZE="85" -e SDRAM_SIZE=64 -e SDRAM_TIMING=AS4C32M16SB_7TCN_ps -e DIST_OUT=/dist/saxon-64-$(VERSION)

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
