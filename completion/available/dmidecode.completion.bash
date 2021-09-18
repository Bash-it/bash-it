# shellcheck shell=bash

function __dmidecode_completion() {
	# shellcheck disable=SC2155
	local prev=$(_get_pword)
	# shellcheck disable=SC2155
	local curr=$(_get_cword)

	case $prev in
		-s | --string | -t | --type)
			OPTS=$(dmidecode "$prev" 2>&1 | grep -E '^ ' | sed 's/ *//g')
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "$OPTS" -- "$curr"))
			;;
		dmidecode)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-d --dev-mem -h --help -q --quiet -s --string -t --type -H --handle -u --dump{,-bin} --from-dump --no-sysfs --oem-string -V --version" -- "$curr"))
			;;
	esac
}

complete -F __dmidecode_completion dmidecode
