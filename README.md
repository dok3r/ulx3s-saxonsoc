[![](https://images.microbadger.com/badges/image/dok3r/ulx3s-saxonsoc.svg)](https://microbadger.com/images/dok3r/ulx3s-saxonsoc "Get your own image badge on microbadger.com")
[![Docker Pulls](https://img.shields.io/docker/pulls/dok3r/ulx3s-saxonsoc)](https://hub.docker.com/r/dok3r/ulx3s-saxonsoc "Docker hub")

# ulx3s-saxonsoc

Automated builds for ulx3s for all FPGA sizes.

# Usage

You just need to start wrap.sh:

```
git clone https://github.com/dok3r/ulx3s-saxonsoc.git
cd ulx3s-saxonsoc
./wrap.sh -e FPGA_SIZES=85 -e SDRAM_SIZES=64 -e DIST_OUT=/dist/ulx3s-85-64
```

make will output bit and other files in $HOME/dist

Or if you need build for all sizes:
```
git clone https://github.com/dok3r/ulx3s-saxonsoc.git
cd ulx3s-saxonsoc
./wrap.sh -e FPGA_SIZES="12 25 45 85" -e SDRAM_SIZES="32 64" -e DIST_OUT=/dist/ulx3s-85-64
```


# Docker

If you just need build environment:
```
docker run -it --user 1000 dok3r/ulx3s-saxonsoc
```

Of course, you can always run build script inside docker:
```
docker run -it --user 1000 -v $HOME/dist:/dist -v `pwd`/scripts:/scripts dok3r/ulx3s-saxonsoc
/scripts/buildsmp.sh
```

If you need more dirs to be available:
```
docker run -it --user 1000 -v $HOME/fpga:/fpga -v $HOME/dist:/dist -v `pwd`/scripts:/scripts dok3r/ulx3s-saxonsoc
```



