#!/bin/sh

docker run --rm -it --user 1000 "$@" -v $HOME/fpga:/fpga -v $HOME/dist:/dist -v `pwd`/scripts:/scripts dok3r/ulx3s-saxonsoc /scripts/buildsmp.sh

