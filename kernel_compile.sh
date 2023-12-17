#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : A kernel compile script intended for cross compiling

# Set some defaults
PROFILE=default
DEFCONFIG="rzn1_defconfig"
IMAGE_TYPE="uImage"
DTBS=(rzn1d400-db.dtb)
COMPILE_DIR=/tmp/linux
SOURCE_DIR=$PWD
OUTPUT_DIR=$PWD/output
NFS_DIR=/tftpboot/rzn1/
CROSS_COMPILER_PATH=/usr/share/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin

display_usage_simple() {
	echo "*** Kernel Compilation Profiler ***"
	echo "Compiles the Linux kernel and device tree"
	echo "for hardware targets based on their manuals (i.e a Profile)"
	echo "Use the -p option to select a profile\n"
	echo "Output files are saved to ./output/profile"
	echo "Currently supported profiles:"
	echo "rzn1: The Renesas RZ/N1"
	echo "tx2: The Nvidia Jetson TX2 NX"
	echo "radxa_cm3_io: The Radxa BSP for CM3 IO board"
	echo "For all advanced options, see the -a option"

}

display_usage_advanced() {
	echo "All options help:"
	echo "Compilation occurs under /tmp/linux/<profile>"
	echo "-p : Profile, select the target platform [rzn1]"
	echo "		[rzn1]	: The Renesas RZ/N1"
	echo "          [tx2]: The Nvidia Jetson TX2 NX"
	echo "          [radxa_cm3_io]: The Radxa BSP CM3 IO"
	echo "-a : Adanced Help, show this message with all options"
	echo "-h : Simple Help, show a simplifed quick start help message"
}

setup_radxa_cm3_io_cross_compiler() {
	echo "Radxa CM3 IO Cross compiler not found, install it? [Y/n]"
	read install_rzn_cc

	case $install_rzn_cc in
	        [Yy]* )
			echo "Installing Radxa CM3 IO Cross Compiler..."
			wget https://dl.radxa.com/tools/linux/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.gz
			sudo tar zxvf gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu.tar.gz -C /usr/local/

			echo "Radxa Cross Compiler installed."
		;;
	        [Nn]* )
			echo "Error: Radxa CM3 IO requires a suitable cross compiler"
			exit 1
		;;

		* )
			echo "Error: Unknown response..."
			exit 1
		;;
	esac
}

setup_tx2nx_cross_compiler() {
	JETSON_CROSS_COMPILER_VERSION_BASE=7.3-2018.05
	JETSON_CROSS_COMPILER_DOWNLOAD=$JETSON_CROSS_COMPILER".tar.xz"

	echo "Downloading Nvidia Jetson TX2 NX Cross Compiler..."
	mkdir -p $COMPILE_DIR/downloads
	wget -qP $COMPILE_DIR/downloads http://releases.linaro.org/components/toolchain/binaries/$JETSON_CROSS_COMPILER_VERSION_BASE/aarch64-linux-gnu/$JETSON_CROSS_COMPILER_DOWNLOAD

	echo "Installing Jetson TX2 Cross Compiler..."
	sudo tar -xf $COMPILE_DIR/downloads/$JETSON_CROSS_COMPILER_DOWNLOAD -C /usr/share
	rm -R $COMPILE_DIR/downloads

	echo "Nvidia Jetson TX2 NX Cross Compiler installed."
}

setup_rzn1_cross_compiler() {
	echo "RZ/N1 Cross compiler not found, install it? [Y/n]"
	read install_rzn_cc

	case $install_rzn_cc in
	        [Yy]* )
			echo "Downloading RZ/N1 Cross Compiler..."
			mkdir -p $COMPILE_DIR/downloads
			wget -qP $COMPILE_DIR/downloads https://releases.linaro.org/components/toolchain/binaries/6.3-2017.02/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz

			echo "Installing RZ/N1 Cross Compiler..."
			sudo tar -xf $COMPILE_DIR/downloads/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf.tar.xz -C /usr/share
			rm -R $COMPILE_DIR/downloads

			echo "RZ/N1 Cross Compiler installed."
		;;
	        [Nn]* )
			echo "Error: RZ/N1 requires a suitable cross compiler"
			echo "Please see documentation:"
			echo "https://www.renesas.com/eu/en"
			exit 1
		;;

		* )
			echo "Error: Unknown response..."
			exit 1
		;;
	esac
}

load_profile() {
	case $1 in
		rzn1)
			echo "RZ/N1 profile selected"
			LOAD_ADDR=80008000
			DEFCONFIG="rzn1_defconfig"
			COMPILE_DIR=/tmp/linux/rzn1
			IMAGE_TYPE="uImage"
			DTBS=(rzn1d400-db.dtb rzn1d400-db-both-gmacs.dtb rzn1d400-db-cm3-ethercat.dtb rzn1d400-db-no-cm3.dtb)
			OUTPUT_DIR=$PWD/output/rzn1/
			NFS_DIR=/tftpboot/rzn1/
			CROSS_COMPILER_PATH="/usr/share/gcc-linaro-6.3.1-2017.02-x86_64_arm-linux-gnueabihf/bin"

			export PATH=$CROSS_COMILER_PATH:$PATH
			export CROSS_COMPILE="arm-linux-gnueabihf-"
			export ARCH=arm

			if [ ! -d "$CROSS_COMPILER_PATH" ]; then
				setup_rzn1_cross_compiler
			else
				echo "Found cross compiler at $CROSS_COMPILER_PATH"
			fi
			;;
		tx2)
			echo "Nvidia Jetson TX2 profile selected"
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

			export PATH=$CROSS_COMPILER_PATH:$PATH
			export CROSS_COMPILE="aarch64-linux-gnu-"
			export ARCH=arm64

			if [[ ! -d "$CROSS_COMPILER_PATH" ]]; then
				setup_tx2nx_cross_compiler
			else
				echo "Jetson toolchain exists in $CROSS_COMPILER_PATH"
			fi
			;;
		radxa_cm3_io)
			echo "Radxa CM3 IO profile selected"
			DEFCONFIG="rockchip_linux_defconfig"
			COMPILE_DIR=/tmp/linux/radxa_cm3_io
			IMAGE_TYPE="Image"
			DTBS=(rockchip/rk3566-radxa-cm3-io.dtb)
			OUTPUT_DIR=$PWD/output/radxa_cm3_io/
			NFS_DIR=/tftpboot/radxa_cm3_io/
			CROSS_COMPILER_PATH="/usr/local/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/"
			export PATH=$CROSS_COMPILER_PATH:$PATH

			export CROSS_COMPILE="aarch64-none-linux-gnu-"
			export ARCH=arm64

			FILE=/usr/local/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-rockchip1031-linux-gnu-gcc

			if ! [ -f "$FILE" ]; then
				setup_radxa_cm3_io_cross_compiler
			else
				echo "Found cross compiler at $CROSS_COMPILER_PATH"
			fi
			;;
		*)
			echo "Error: Unknown hardware profile...Using Default"

	esac
}

compile_dtbs() {
	echo "Compiling Device Trees..."

	for DTB in "${DTBS[@]}"
	do :
		make O=$COMPILE_DIR $DTB #> /dev/null 2>&1
	done
}

apply_config() {
	echo "Applying $DEFCONFIG kernel configuration file"
	make O=$COMPILE_DIR $DEFCONFIG
}

compile_image() {
	echo "Compiling Kernel Image"

	if [ -z ${LOAD_ADDR} ]; then
		make -j3 O=$COMPILE_DIR LOADADDR=$LOAD_ADDR $IMAGE_TYPE #> /dev/null 2>&1
	else
		make -j3 O=$COMPILE_DIR $IMAGE_TYPE #> /dev/null 2>&1
	fi
}

setup_env() {
	mkdir -p $OUTPUT_DIR
	cd $SOURCE_DIR
}

handle_outputs() {
	echo "Copying to NFS directory"
	cp $OUTPUT_DIR* $NFS_DIR
}

while getopts p:ha flag
do
	case "${flag}" in
		p)
			PROFILE=${OPTARG}
			;;
		h)
			display_usage_simple
			exit 0
			;;
		a)
			display_usage_advanced
			exit 0
			;;
		:)
			echo "Error: Option is missing an argument."
			exit 1
			;;
		?)
			echo "Error: Unknown option."
			exit 1
			;;
	esac
done

load_profile $PROFILE
setup_env
apply_config
compile_image
compile_dtbs
#handle_outputs
