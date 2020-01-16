# ulx3s-saxonsoc

Automated builds for ulx3s for all FPGA sizes.

# Usage

You just need to start wrap.sh:

```
git clone https://github.com/dok3r/ulx3s-saxonsoc.git
cd ulx3s-saxonsoc
./wrap.sh -e FPGA_SIZE=85 -e SDRAM_SIZE=32 -e DIST_OUT=/dist/ulx3s-85-32
```

make will output bit and other files in $HOME/dist

# Docker

If you just need build environment:
```
docker run -it --user 1000 dok3r/ulx3s-saxonsoc
```

Of course, you can always run build script inside docker:
```
docker run -it --user 1000 -v $HOME/dist:/dist -v `pwd`/scripts:/scripts dok3r/ulx3s-saxonsoc
/scripts/build.sh
```

If you need more dirs to be available:
```
docker run -it --user 1000 -v $HOME/fpga:/fpga -v $HOME/dist:/dist -v `pwd`/scripts:/scripts dok3r/ulx3s-saxonsoc
```



