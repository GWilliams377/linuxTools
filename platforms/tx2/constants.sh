#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : Platform specific kernel compilation constants
#			   for the Nvidia TX2 NX

DEFCONFIG="tegra_defconfig"
COMPILE_DIR=/tmp/linux/jetson_tx2
IMAGE_TYPE="Image"
DTBS=(tegra186-p3636-0001-p3509-0000-a01.dtb)
OUTPUT_DIR=$PWD/output/jetson-tx2/
NFS_DIR=/tftpboot/jetson-tx2/
JETSON_CROSS_COMPILER_VERSION=7.3.1-2018.05
JETSON_CROSS_COMPILER=gcc-linaro-$JETSON_CROSS_COMPILER_VERSION-x86_64_aarch64-linux-gnu
CROSS_COMPILER_PATH=/usr/share/$JETSON_CROSS_COMPILER/bin
LOADADDR=80280000
MOD_COMPILE=false

export PATH=$CROSS_COMPILER_PATH:$PATH
export CROSS_COMPILE="aarch64-linux-gnu-"
export ARCH=arm64
