#!/bin/bash
#========================================
#   Linux Distribution: Manjaro/Debian 8+/
#   Author: 6donote4 <mailto:do_note@hotmail.com>
#   Dscription: Merge openwrt-ci.yml from coolsnowwolf repository .
#   Version: 0.0.1
#   Blog: https://www.donote.tk https://6donote4.github.io
#========================================
# This script is used to merge openwrt-ci.yml from coolsnowwolf repository.
VERSION=0.0.1
PROGNAME="$(basename $0)"

export LC_ALL=C

SCRIPT_UMASK=0122
umask $SCRIPT_UMASK

usage() {
cat << EOF
delfiles $VERSION

Usage:
./$PROGNAME [option] FILE
Options
-m  Merge from coolsnowwolf repository
--version  Show version
-h --help  Show this usage
EOF
}

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

if [[ "$1" == ""  ]];then
    usage
    exit 0
fi

merging() {
    git remote add upstream  https://github.com/Bash-it/bash-it.git;
    git pull     https://github.com/Bash-it/bash-it.git --no-edit --strategy-option ours
    git fetch upstream;
    git checkout master;
    git merge upstream/master;
    git push origin master ;
}

ARGS=( "$@" )

while [[ -n "$1" ]];
do
	case "$1" in
           -m)
			merging
			echo "done"
	                exit 0
			;;
	    -h|--help)
			usage
			exit 0
			;;
	    --version)
			echo $VERSION
			exit 0
			;;

	    *)
			echo  "Invalid parameter $1" 1>&2
			exit 1
			;;
	esac
done
