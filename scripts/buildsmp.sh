#!/bin/bash

export CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-elf-

if [ "x$SAXON_BRANCH" = "x" ]; then
	export SAXON_BRANCH=dev-0.1
fi
if [ "x$DIST_OUT" = "x" ]; then
	export DIST_OUT=/dist/
fi
mkdir -p $DIST_OUT
echo "[i] Started clone"

cd $HOME && \
       mkdir Ulx3sSmp && \
       cd Ulx3sSmp && \
       git clone https://github.com/SpinalHDL/SaxonSoc.git -b $SAXON_BRANCH --recursive SaxonSoc
source SaxonSoc/bsp/radiona/ulx3s/smp/source.sh
       saxon_clone && \
       echo "[i] Success clone"

if [ "x$FPGA_SIZES" = "x" ]; then
	export FPGA_SIZES=12	# 12, 25, 45 or 85 usually
fi
if [ "x$SDRAM_SIZES" = "x" ]; then
	export SDRAM_SIZES=32 	# 32 or 64 usually
fi

for SDRAM_SIZE in $SDRAM_SIZES
do
for FPGA_SIZE in $FPGA_SIZES
do
if [ "x$SDRAM_SIZE" = "x" ]; then
	export SDRAM_SIZE=32 	# 32 or 64 usually
fi
if [ "$SDRAM_SIZE" == "32" ]; then
	export SDRAM_TIMING=MT48LC16M16A2_6A_ps
fi
if [ "$SDRAM_SIZE" == "64" ]; then
	export SDRAM_TIMING=AS4C32M16SB_7TCN_ps
fi
if [ "x$FPGA_SIZE" = "x" ]; then
	export FPGA_SIZE=12	# 12, 25, 45 or 85 usually
fi
echo "Building $FPGA_SIZE with SDRAM $SDRAM_SIZE and $SDRAM_TIMING to $DIST_OUT"
	cd $HOME && \
	saxon_standalone_compile bootloader CFLAGS_ARGS="-DSDRAM_TIMING=$SDRAM_TIMING" && \
	SDRAM_SIZE=$SDRAM_SIZE saxon_netlist && \
	FPGA_SIZE=$FPGA_SIZE saxon_bitstream && \
        cp $HOME/Ulx3sSmp/SaxonSoc/hardware/synthesis/radiona/ulx3s/smp/bin/toplevel.bit $DIST_OUT/ulx3s-saxonsoc-$FPGA_SIZE-$SDRAM_SIZE.bit && \
	saxon_opensbi && \
	cp $HOME/Ulx3sSmp/opensbi/build/platform/spinal/saxon/radiona/ulx3s/firmware/fw_jump.bin $DIST_OUT/ulx3s-saxonsoc-fwjump-$FPGA_SIZE-$SDRAM_SIZE.bin && \
	saxon_uboot && \
	cp $HOME/Ulx3sSmp/u-boot/u-boot.bin $DIST_OUT/ulx3s-saxonsoc-uboot-$FPGA_SIZE-$SDRAM_SIZE.bin && \
	saxon_standalone_compile sdramInit CFLAGS_ARGS="-DSDRAM_TIMING=$SDRAM_TIMING" && \
	echo "[i] Success bitstream"
done
done

if [ "x$SAXON_NOBUILDROOT" = "x" ]; then
	echo "[i] Started buildroot" && \
	saxon_buildroot && \
        cp $HOME/Ulx3sSmp/buildroot/output/images/dtb $DIST_OUT/ulx3s-saxonsoc.dtb && \
	cp $HOME/Ulx3sSmp/buildroot/output/images/rootfs.cpio.uboot $DIST_OUT/ulx3s-saxonsoc-rootfs.cpio.uboot && \
	cp $HOME/Ulx3sSmp/buildroot/output/images/uImage $DIST_OUT/ulx3s-saxonsoc-uImage && \
	cp $HOME/Ulx3sSmp/buildroot/output/images/rootfs.tar $DIST_OUT/ulx3s-saxonsoc-rootfs.tar && \
	saxon_openocd && \
	echo "[i] Success buildroot"
else
	echo "Skipping buildroot"
fi
