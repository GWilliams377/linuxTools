#!/bin/bash
#
# Author		 : Gareth Williams
# SPDX-License-Identifier: GPL-2.0+
# Description		 : A script for displaying the author information of a
#			   repository.
#

# TODO: Signed-off-by line parsing for contributor involvement
# TODO: Reviewed-by parsing for amount of reviews

# Print all the authors of commits on a git repository
viewAllAuthors()
{
	echo "*** Printing all metrics for whole repository ***"
	echo "Commit numbers:"
	git shortlog --summary --numbered --no-merges
}

printAuthor()
{
	#TODO align these outputs
	echo "Commits:	Author:"
	git shortlog --summary --numbered --no-merges | grep "$AUTHOR"
}

display_usage_simple() {
	echo "*** Kernel Contributor Metrics Analyzer ***"
	echo "Without parameters, this script displays the git metrics for the"
	echo "author listed at the top of this script, meaning:"
	echo "	- number of commits in the repository"
	echo "For all advanced options, see the -a option"
}

display_usage_advanced() {
	echo "Advanced help"
	echo "a: Advanced help"
	echo "n: Name of author"
	echo "e: Everyone's metrics"
	echo ""
}
	
while getopts haen: flag;
do
	case "$flag" in
		h)
			display_usage_simple
			exit 0
			;;
		a)
			display_usage_advanced
			exit 0
			;;
		n)
			AUTHOR=${OPTARG}
			;;
		e)
			viewAllAuthors
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

printAuthor
