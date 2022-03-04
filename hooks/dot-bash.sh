#!/usr/bin/env bash

exit_code=0
for file in "$@"; do
	# Confirm file is not executable
	#
	if [[ -x "${file}" ]]; then
		echo "Bash include file \`${file}\` should not be executable"
		exit_code=1
	fi

	# Confirm expected schellcheck header
	#
	LINE1="$(head -n 1 "${file}")"
	SCSH="${file##*.}"
	if [[ "${LINE1}" != "# shellcheck shell=${SCSH}" ]]; then
		echo "Bash include file \`${file}\` has bad/missing shellcheck header"
		exit_code=1
	fi
done

exit "${exit_code:-0}"
