FROM ubuntu:18.10
MAINTAINER kost - https://github.com/kost

ENV PATH=/opt/riscv/bin:/opt/ulx3s/bin:$PATH \
 ULX3SURL=https://github.com/alpin3/ulx3s/releases/download/v2019.12.30/ulx3s-2019.12.30-linux-x86_64.tar.gz \
 RISCVTC=https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-20171231-x86_64-linux-centos6.tar.gz \
 GHDL_PREFIX=/opt/ulx3s/ghdl/lib/ghdl \
 ULX3S_USER=ulx3s

RUN apt-get update && \
 apt-get install git curl make software-properties-common build-essential bison flex bc wget cpio python unzip rsync -y && \
 add-apt-repository -y ppa:openjdk-r/ppa && \
 apt-get update && \
 apt-get install openjdk-8-jdk -y && \
 update-alternatives --config java && \
 update-alternatives --config java && \
 echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list && \
 apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 && \
 apt-get update && \
 apt-get install sbt -y && \
 mkdir -p /opt/riscv && \
 curl -L $RISCVTC | tar -xvz --strip-components=1 -C /opt/riscv -f - && \
 mkdir -p /opt/ulx3s && \
 curl -L $ULX3SURL | tar -xvz --strip-components=1 -C /opt/ulx3s -f - && \
 rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
 adduser --uid 1000 --system ${ULX3S_USER} && \
 echo "[i] Success"

# USER ulx3s
