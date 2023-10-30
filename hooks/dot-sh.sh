#!/usr/bin/env bash

exit_code=0
for file in "$@"; do
	# Confirm file is executable
	#
	if [[ ! -x "${file}" ]]; then
		echo "Bash file \`${file}\` is not executable"
		exit_code=1
	fi

	# Confirm expected #! header
	#
	LINE1="$(head -n 1 "${file}")"
	if [[ "${LINE1}" != "#!/usr/bin/env bash" ]]; then
		echo "Bash file \`${file}\` has bad/missing #! header"
		exit_code=1
	fi
done

exit "${exit_code:-0}"
