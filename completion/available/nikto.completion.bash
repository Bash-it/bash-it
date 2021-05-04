# shellcheck shell=bash

__nikto_completion() {
	local prev=$(_get_pword)
	local curr=$(_get_cword)

	case $prev in
		-ask)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "yes no auto" -- "$curr"))
			;;
		-Display)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "1 2 3 4 D E P S V" -- "$curr"))
			;;
		-evasion)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "1 2 3 4 5 6 7 8 A B" -- "$curr"))
			;;
		-Format)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "csv htm nbe sql txt xml" -- "$curr"))
			;;
		-mutate)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "1 2 3 4 5 6" -- "$curr"))
			;;
		-Tuning)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "0 1 2 3 4 5 6 7 8 9 a b c d e x" -- "$curr"))
			;;
		-Userdbs)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "all none" -- "$curr"))
			;;
		*)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-H -Help -ask -Cgidirs -config -Display -dbcheck -evasion -Format -host -404code -404string -id -key -list-plugins -maxtime -mutate -mutate-options -nointeractive -nolookup -nossl -no404 -Option -output -Pause -Plugins -port -RSAcert -root -Save -ssl -Tuning -timeout -Userdbs -useragent -until -update -useproxy -Verbost -vhost" -- "$curr"))
			;;
	esac
}

complete -F __nikto_completion nikto
