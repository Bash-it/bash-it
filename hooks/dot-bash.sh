#!/usr/bin/env bash

exit_code=0
for file in "$@"; do
	# TODO Confirm file has '.bash' extension

	# Confirm not executable
	#
	if [[ -x "${file}" ]]; then
		echo "Bash include file \`${file}\` should not be executable"
		exit_code=1
	fi

	# Confirm expected #! header
	#
	LINE1="$(head -n 1 "${file}")"
	if [[ "${LINE1}" != "#!/usr/bin/env echo run from bash: ." ]]; then
		echo "Bash include file \`${file}\` has bad/missing #! header"
		exit_code=1
	fi

	# Confirm expected schellcheck header
	#
	LINE2="$(head -n 2 "${file}" | tail -n 1)"
	if [[ "${LINE2}" != "# shellcheck shell=bash disable=SC2148,SC2096" ]]; then
		echo "Bash include file \`${file}\` has bad/missing shellcheck header"
		exit_code=1
	fi
done

exit $exit_code
