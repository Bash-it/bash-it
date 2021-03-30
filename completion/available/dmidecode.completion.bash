function __dmidecode_completion() {
	local prev=$(_get_pword)
	local curr=$(_get_cword)

	case $prev in
	-s | --string | -t | --type)
		OPTS=$(dmidecode $prev 2>&1 | grep -E '^ ' | sed 's/ *//g')
		COMPREPLY=($(compgen -W "$OPTS" -- "$curr"))
		;;
	dmidecode)
		COMPREPLY=($(compgen -W "-d --dev-mem -h --help -q --quiet -s --string -t --type -H --handle -u --dump{,-bin} --from-dump --no-sysfs --oem-string -V --version" -- "$curr"))
		;;
	esac
}

complete -F __dmidecode_completion dmidecode
