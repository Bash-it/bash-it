# shellcheck shell=bash

__nikto_completion() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD - 1]:-}

	case $prev in
		-ask)
			COMPREPLY=("yes" "no" "auto")
			;;
		-Display)
			COMPREPLY=('1' '2' '3' '4' 'D' 'E' 'P' 'S' 'V')
			;;
		-evasion)
			COMPREPLY=('1' '2' '3' '4' '5' '6' '7' '8' 'A' 'B')
			;;
		-Format)
			COMPREPLY=('csv' 'htm' 'nbe' 'sql' 'txt' 'xml')
			;;
		-mutate)
			COMPREPLY=('1' '2' '3' '4' '5' '6')
			;;
		-Tuning)
			COMPREPLY=('0' '1' '2' '3' '4' '5' '6' '7' '8' '9' 'a' 'b' 'c' 'd' 'e' 'x')
			;;
		-Userdbs)
			COMPREPLY=('all' 'none')
			;;
		*)
			COMPREPLY=('-H' '-Help' '-ask' '-Cgidirs' '-config' '-Display' '-dbcheck' '-evasion' '-Format' '-host' '-404code' '-404string' '-id' '-key' '-list-plugins' '-maxtime' '-mutate' '-mutate-options' '-nointeractive' '-nolookup' '-nossl' '-no404' '-Option' '-output' '-Pause' '-Plugins' '-port' '-RSAcert' '-root' '-Save' '-ssl' '-Tuning' '-timeout' '-Userdbs' '-useragent' '-until' '-update' '-useproxy' '-Verbost' '-vhost')
			;;
	esac
}

complete -F __nikto_completion -X '!&*' nikto
