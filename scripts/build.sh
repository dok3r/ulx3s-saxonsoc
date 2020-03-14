#!/bin/sh

export CROSS_COMPILE=/opt/riscv/bin/riscv64-unknown-elf-
if [ "x$DIST_OUT" = "x" ]; then
	export DIST_OUT=/dist/
fi
if [ "x$SDRAM_TIMING" = "x" ]; then
	export SDRAM_TIMING=MT48LC16M16A2_6A_ps # 64 = AS4C32M16SB_7TCN_ps
fi
if [ "x$FPGA_SIZE" = "x" ]; then
	export FPGA_SIZE=25	# 12, 25, 45 or 85 usually
fi
if [ "x$SDRAM_SIZE" = "x" ]; then
	export SDRAM_SIZE=32 	# 32 or 64 usually
fi

echo "Building $FPGA_SIZE with SDRAM $SDRAM_SIZE and $SDRAM_TIMING to $DIST_OUT"
mkdir -p $DIST_OUT

 cd $HOME && \
 git clone https://github.com/SpinalHDL/SaxonSoc.git -b dev --recursive SaxonSoc && \
 cd SaxonSoc/ext/ && rm -rf SpinalHDL && git clone https://github.com/SpinalHDL/SpinalHDL && cd ../../ && \
 cd SaxonSoc/software/standalone/bootloader && \
 make clean all BSP=Ulx3sLinuxUboot CFLAGS_ARGS="-DSDRAM_TIMING=$SDRAM_TIMING" && \
 cd ../../../.. && \
 cd SaxonSoc/software/standalone/machineModeSbi && \
 make clean all BSP=Ulx3sLinuxUboot CFLAGS_ARGS="-DHDMI_CONSOLE -DPS2_KEYBOARD" && \
 cd ../../../.. && \
 cd SaxonSoc/hardware/synthesis/ulx3s && \
 cp makefile.uboot makefile && \
 make generate && \
 for SIZE in $FPGA_SIZE; do make FPGA_SIZE=$SIZE SDRAM_SIZE=$SDRAM_SIZE; cp bin/toplevel.bit $DIST_OUT/saxonsoc-ulx3s-linux-$SIZE.bit; rm bin/toplevel.[bc]*; done && \
 cd ../../../.. && \
 git clone https://github.com/SpinalHDL/u-boot.git -b saxon u-boot && \
 cd u-boot && \
 make saxon_ulx3s_defconfig && \
 make -j$(nproc) && \
 cd .. && \
 cp -a SaxonSoc/software/standalone/machineModeSbi/build/machineModeSbi.bin $DIST_OUT/bios.bin@0x300000.img && \
 cp -a u-boot/u-boot.bin $DIST_OUT/u-boot.bin@0x310000.img && \
 git clone https://github.com/SpinalHDL/buildroot.git -b saxon buildroot && \
 git clone https://github.com/SpinalHDL/linux.git -b vexriscv --depth 100 linux && \
 cd buildroot && \
 make spinal_saxon_ulx3s_defconfig && \
 make linux-rebuild all -j$(nproc) && \
 output/host/bin/riscv32-linux-objcopy  -O binary output/images/vmlinux output/images/Image && \
 output/host/bin/dtc -O dtb -o output/images/dtb board/spinal/saxon_ulx3s/spinal_saxon_ulx3s.dts && \
 output/host/bin/mkimage -A riscv -O linux -T kernel -C none -a 0x80000000 -e 0x80000000 -n Linux -d output/images/Image output/images/uImage && \
 cp output/images/uImage $DIST_OUT && \
 cp output/images/dtb $DIST_OUT && \
 cp board/spinal/saxon_ulx3s/spinal_saxon_ulx3s.dts $DIST_OUT && \
 cp output/images/rootfs.tar $DIST_OUT && \
 cd .. && \
 mkdir -p root/boot  && \
 mkdir -p root/bin && \
 mkdir -p root/etc/network && \
 mkdir -p root/root && \
 cp buildroot/output/images/uImage root/boot/ && \
 cp buildroot/output/images/dtb root/boot/ && \
 cp buildroot/board/spinal/saxon_ulx3s/spinal_saxon_ulx3s.dts root/boot/dts && \
 cp buildroot/output/images/rootfs.tar rootfs.tar && \
 curl -L https://raw.githubusercontent.com/lawrie/saxonsoc-ulx3s-bin/master/linux/static-bin/slirp -o root/bin/slirp && \
 chmod 755 root/bin/slirp && \
 curl -L https://raw.githubusercontent.com/lawrie/saxonsoc-ulx3s-bin/master/linux/u-boot/images/hosts -o root/etc/hosts && \
 curl -L https://raw.githubusercontent.com/lawrie/saxonsoc-ulx3s-bin/master/linux/u-boot/images/interfaces -o root/etc/network/interfaces && \
 curl -L https://raw.githubusercontent.com/lawrie/saxonsoc-ulx3s-bin/master/linux/u-boot/images/.slirprc -o root/root/.slirprc && \
 curl -L https://raw.githubusercontent.com/lawrie/saxonsoc-ulx3s-bin/master/linux/u-boot/images/create_keys.sh -o root/root/create_keys.sh && \
 cd root && \
 tar -rv --owner root --group root -f ../rootfs.tar . && \
 gzip -9 < ../rootfs.tar > ../rootfs.tar.gz && \
 cd .. && \
 cp rootfs.tar.gz $DIST_OUT && \
 echo "[i] Success"

