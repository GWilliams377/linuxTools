#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : Platform specific kernel compilation constants
#			   for the RZ/N1 platform

LOAD_ADDR=80008000
DEFCONFIG="rzn1_defconfig"
COMPILE_DIR=/tmp/linux/rzn1
IMAGE_TYPE="uImage"
DTBS=(rzn1d400-db.dtb rzn1d400-db-both-gmacs.dtb rzn1d400-db-cm3-ethercat.dtb rzn1d400-db-no-cm3.dtb)
OUTPUT_DIR=$PWD/output/rzn1/
NFS_DIR=/tftpboot/rzn1/
CROSS_COMPILER_PATH="/usr/share/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf/bin"
MOD_COMPILE=false

export PATH=$CROSS_COMPILER_PATH:$PATH
export CROSS_COMPILE="arm-linux-gnueabihf-"
export ARCH=arm
