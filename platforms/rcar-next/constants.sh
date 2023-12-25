#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : Platform specific kernel compilation constants
#			   for the RZ/N1 platform

#LOAD_ADDR=80008000
DEFCONFIG="defconfig"
COMPILE_DIR=/tmp/linux/rcar
IMAGE_TYPE="Image"
DTBS=(r8a77960-salvator-xs.dtb r8a779m1-salvator-xs.dtb r8a779m3-salvator-xs.dtb r8a77965-salvator-xs.dtb r8a77960-salvator-x.dtb r8a77961-salvator-xs.dtb r8a77951-salvator-xs.dtb r8a77960-salvator-xs.dtb r8a779m5-salvator-xs.dtb r8a77965-salvator-x.dtb r8a77951-salvator-x.dtb)
OUTPUT_DIR=$PWD/output/rcar/
NFS_DIR=/tftpboot/rcar/
JETSON_CROSS_COMPILER_VERSION=7.3.1-2018.05
JETSON_CROSS_COMPILER=gcc-linaro-$JETSON_CROSS_COMPILER_VERSION-x86_64_aarch64-linux-gnu
CROSS_COMPILER_PATH=/usr/share/$JETSON_CROSS_COMPILER/bin

export PATH=$CROSS_COMPILER_PATH:$PATH
export CROSS_COMPILE="aarch64-linux-gnu-"
export ARCH=arm64

