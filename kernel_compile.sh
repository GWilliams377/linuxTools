#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : A kernel compile script intended for cross compiling

SOURCE_DIR=$PWD
OUTPUT_DIR=$PWD/output

# Default to not updating NFS directories
NFS_UPDATE=false

print_platform_descriptions() {
	for i in "${PLATFORMS[@]}"
	do
		. $PLATFORMS_DIR/$i/meta.sh
		echo "	[$i]: $DESC"
	done
}

display_usage_simple() {
	echo "*** Kernel Compilation Profiler ***"
	echo "Compiles the Linux kernel and device tree"
	echo "for hardware targets based on their manuals (i.e a Profile)"
	echo "Use the -p option to select a profile\n"
	echo "Output files are saved to ./output/profile"
	echo "Currently supported profiles:"
	print_platform_descriptions
	echo "For all advanced options, see the -a option"

}

display_usage_advanced() {
	echo "All options help:"
	echo "Compilation occurs under /tmp/linux/<profile>"
	echo "-p : Profile, select the target platform [rzn1]"
	print_platform_descriptions
	echo "-a : Adanced Help, show this message with all options"
	echo "-n : NFS Update, update the platforms NFS directory"
	echo "-h : Simple Help, show a simplifed quick start help message"
}

find_platforms() {
	PLATFORMS_DIR=$(dirname ${BASH_SOURCE[0]})/platforms

	PLATFORMS=$(ls $PLATFORMS_DIR)
	PLATFORMS=($PLATFORMS)
}

load_profile() {
	source $PLATFORMS_DIR/$1/constants.sh
	source $PLATFORMS_DIR/$1/meta.sh
	echo "$NAME Profile Selected"
}

compile_dtbs() {
	echo "Compiling Device Trees..."

	for DTB in "${DTBS[@]}"
	do :
		make O=$COMPILE_DIR $VENDOR$DTB > /dev/null
	done
}

apply_config() {
	echo "Applying $DEFCONFIG kernel configuration file"
	make O=$COMPILE_DIR $DEFCONFIG > /dev/null
}

compile_image() {
	echo "Compiling Kernel Image..."

	COMPILE_CMD=""

	if [ ! -z ${LOAD_ADDR} ]; then
		COMPILE_CMD="make -j3 O=$COMPILE_DIR LOADADDR=$LOAD_ADDR $IMAGE_TYPE > /dev/null"
	else
		COMPILE_CMD="make -j3 O=$COMPILE_DIR $IMAGE_TYPE > /dev/null"
	fi

	if eval $COMPILE_CMD ; then
		echo "kernel compilation complete"
	else
		echo "kernel compilation failed"
		exit 1
	fi
}

setup_env() {
	mkdir -p $OUTPUT_DIR
	cd $SOURCE_DIR
}

handle_outputs() {
	echo "Copying output to: $OUTPUT_DIR"
	cp $COMPILE_DIR/arch/$ARCH/boot/$IMAGE_TYPE $OUTPUT_DIR

	for DTB in "${DTBS[@]}"
	do :
		cp $COMPILE_DIR/arch/$ARCH/boot/dts/$DTB $OUTPUT_DIR
	done

	if [ "$NFS_UPDATE" = true ]; then
		echo "Copying to NFS directory"
		cp $OUTPUT_DIR* $NFS_DIR
	fi
}

find_platforms

while getopts p:han flag
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
		n)	NFS_UPDATE=true
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
handle_outputs
