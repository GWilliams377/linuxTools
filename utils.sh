#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : Ultilty functions for use in kernel related scripts

find_platforms() {
	PLATFORMS_DIR=$(dirname ${BASH_SOURCE[0]})/platforms

	PLATFORMS=$(ls $PLATFORMS_DIR)
	PLATFORMS=($PLATFORMS)
}

print_platform_descriptions() {
	for i in "${PLATFORMS[@]}"
	do
		. $PLATFORMS_DIR/$i/meta.sh
		echo "	[$i]: $DESC"
	done
}

find_platforms
