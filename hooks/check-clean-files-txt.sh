#!/usr/bin/env bash

file=$1
# Should only be run on clean_files.txt
if [ "$file" != "clean_files.txt" ]; then
	echo "Please run this script on clean_files.txt only!"
	exit 1
fi

function compare_lines() {
	prev=""
	local line
	while read -r line; do
		# Skip unimportant lines
		[[ $line =~ "#" ]] && continue
		[[ $line == "" ]] && continue
		# Actual check
		if [[ $prev > $line ]]; then
			echo "$line should be before $prev"
			exit 1
		fi
		prev=$line
	done <<< "$1"
}

# We compare using the legacy way
shopt -s compat31

# Test root files
compare_lines "$(grep -v "/" "$file")"

# Test root directory
compare_lines "$(grep "/$" "$file")"

# Test non root directories
compare_lines "$(grep "/." "$file")"

shopt -u compat31
# Yay, all good!
exit 0
