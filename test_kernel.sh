#!/bin/bash
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : A script to run standard kernel testing tools

source $(dirname "$0")/utils.sh

load_test_data() {
	source $PLATFORMS_DIR/$1/meta.sh
	source $PLATFORMS_DIR/$1/test_constants.sh
	echo "$NAME Test Profile Selected"
}

run_kunit() {
	KUNIT_CMD="tools/testing/kunit/kunit.py run"

	if [ ! -z ${KUNIT_DIRS} ]; then
		for DIR in "${KUNIT_DIRS[@]}"
		do :
			KUNIT_CMD="${KUNIT_CMD} --kunitconfig="${DIR}
		done
	fi

	if [ ! -z ${KUNIT_CONFIGS} ]; then
		for CONFIG in "${KUNIT_CONFIGS[@]}"
		do :
			KUNIT_CMD="${KUNIT_CMD} --kconfig_add ${CONFIG}=y"
		done
	fi

	${KUNIT_CMD}
}

display_usage() {
	echo "All options help:"
	echo "Compilation occurs under /tmp/linux/<profile>"
	echo "-k : Run KUnit"
	echo "-p : Profile, select the target platform [rzn1]"
}

while getopts kp: flag
do
	case "${flag}" in
		p)
			PROFILE=${OPTARG}
			;;
		k)	KTEST=true
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

load_test_data $PROFILE
if [ "$KTEST" = true ]; then
	run_kunit
fi
