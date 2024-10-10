#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : Platform specific kernel compilation constants
#			   for the Radxa CM3 IO platform
DEFCONFIG="rockchip_linux_defconfig"
COMPILE_DIR=/tmp/linux/radxa_cm3_io
IMAGE_TYPE="Image"
DTBS=(rockchip/rk3566-radxa-cm3-io.dtb)
OUTPUT_DIR=$PWD/output/radxa_cm3_io/
NFS_DIR=/tftpboot/radxa_cm3_io/
CROSS_COMPILER_PATH="/usr/local/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/"
MOD_COMPILE=false

export PATH=$CROSS_COMPILER_PATH:$PATH
export CROSS_COMPILE="aarch64-none-linux-gnu-"
export ARCH=arm64
