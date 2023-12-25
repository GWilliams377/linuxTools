#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : A kernel compile script intended for cross compiling

SOURCE_DIR=$PWD
OUTPUT_DIR=$PWD/output

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

find_platforms_dir() {
	PLATFORMS_DIR=$(dirname ${BASH_SOURCE[0]})/platforms
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
			wget -qP $COMPILE_DIR/downloads https://releases.linaro.org/components/toolchain/binaries/6.3-2017.05/arm-linux-gnueabihf/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz

			echo "Installing RZ/N1 Cross Compiler..."
			sudo tar -xf $COMPILE_DIR/downloads/gcc-linaro-6.3.1-2017.05-x86_64_arm-linux-gnueabihf.tar.xz -C /usr/share
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
	source $PLATFORMS_DIR/$1/constants.sh

	case $1 in
		rzn1)
			echo "RZ/N1 profile selected"

			if [ ! -d "$CROSS_COMPILER_PATH" ]; then
				setup_rzn1_cross_compiler
			else
				echo "Found cross compiler at $CROSS_COMPILER_PATH"
			fi
			;;
		tx2)
			echo "Nvidia Jetson TX2 profile selected"

			if [[ ! -d "$CROSS_COMPILER_PATH" ]]; then
				setup_tx2nx_cross_compiler
			else
				echo "Jetson toolchain exists in $CROSS_COMPILER_PATH"
			fi
			;;
		radxa_cm3_io)
			echo "Radxa CM3 IO profile selected"

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

find_platforms_dir
load_profile $PROFILE
setup_env
apply_config
compile_image
compile_dtbs
#handle_outputs
