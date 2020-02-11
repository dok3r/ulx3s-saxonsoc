#!/bin/sh
# create image from rootfs.tar.gz

# Use losetup -f to find free `loop devices

# Create a 32MB image file
rm image
dd if=/dev/zero of=image bs=1M count=32

# Create 1 Linux partition
fdisk image <fdisk.cmd

LOOP_DEVICE1=`losetup -f`
# Set loop device 1 to the whole file
sudo losetup ${LOOP_DEVICE1} image

LOOP_DEVICE2=`losetup -f`
# Set loop device 2 to the start of partition
sudo losetup -o $((512*2048)) ${LOOP_DEVICE2} ${LOOP_DEVICE1}

# Create an ext2 partition
sudo mkfs.ext2 ${LOOP_DEVICE2}

# Mount the partition
mkdir -p tmp
sudo mount ${LOOP_DEVICE2} tmp

# Extract the rootfs files
sudo tar xzf $1 -C tmp

# Ummount the partition
sudo umount tmp

# Detach loop devices
sudo losetup -d ${LOOP_DEVICE1}
sudo losetup -d ${LOOP_DEVICE2}

