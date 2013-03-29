# defaults
# Bash command line completion for defaults
#
# Created by Jonathon Mah on 2006-11-08.
# Copyright 2006 Playhaus. All rights reserved.
#
# Version 1.0 (2006-11-08)


_defaults_domains()
{
    local cur
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}

	local domains=$( defaults domains | sed -e 's/, /:/g' | tr : '\n' | sed -e 's/ /\\ /g' | grep -i "^$cur" )
	local IFS=$'\n'
	COMPREPLY=( $domains )
	if [[ $( echo '-app' | grep "^$cur" ) ]]; then
		COMPREPLY[${#COMPREPLY[@]}]="-app"
	fi

    return 0
}


_defaults()
{
	local cur prev host_opts cmds cmd domain keys key_index
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

	host_opts='-currentHost -host'
	cmds='read read-type write rename delete domains find help'

	if [[ $COMP_CWORD -eq 1 ]]; then
		COMPREPLY=( $( compgen -W "$host_opts $cmds" -- $cur ) )
		return 0
	elif [[ $COMP_CWORD -eq 2 ]]; then
		if [[ "$prev" == "-currentHost" ]]; then
			COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
			return 0
		elif [[ "$prev" == "-host" ]]; then
			return 0
			_known_hosts -a
		else
			_defaults_domains
			return 0
		fi
	elif [[ $COMP_CWORD -eq 3 ]]; then
		if [[ ${COMP_WORDS[1]} == "-host" ]]; then
			_defaults_domains
			return 0
		fi
    fi

	# Both a domain and command have been specified

	if [[ ${COMP_WORDS[1]} == [${cmds// /|}] ]]; then
		cmd=${COMP_WORDS[1]}
		domain=${COMP_WORDS[2]}
		key_index=3
		if [[ "$domain" == "-app" ]]; then
			if [[ $COMP_CWORD -eq 3 ]]; then
				# Completing application name. Can't help here, sorry
				return 0
			fi
			domain="-app ${COMP_WORDS[3]}"
			key_index=4
		fi
	elif [[ ${COMP_WORDS[2]} == "-currentHost" ]] && [[ ${COMP_WORDS[2]} == [${cmds// /|}] ]]; then
		cmd=${COMP_WORDS[2]}
		domain=${COMP_WORDS[3]}
		key_index=4
		if [[ "$domain" == "-app" ]]; then
			if [[ $COMP_CWORD -eq 4 ]]; then
				# Completing application name. Can't help here, sorry
				return 0
			fi
			domain="-app ${COMP_WORDS[4]}"
			key_index=5
		fi
	elif [[ ${COMP_WORDS[3]} == "-host" ]] && [[ ${COMP_WORDS[3]} == [${cmds// /|}] ]]; then
		cmd=${COMP_WORDS[3]}
		domain=${COMP_WORDS[4]}
		key_index=5
		if [[ "$domain" == "-app" ]]; then
			if [[ $COMP_CWORD -eq 5 ]]; then
				# Completing application name. Can't help here, sorry
				return 0
			fi
			domain="-app ${COMP_WORDS[5]}"
			key_index=6
		fi
	fi

	keys=$( defaults read $domain 2>/dev/null | sed -n -e '/^    [^}) ]/p' | sed -e 's/^    \([^" ]\{1,\}\) = .*$/\1/g' -e 's/^    "\([^"]\{1,\}\)" = .*$/\1/g' | sed -e 's/ /\\ /g' )

	case $cmd in
	read|read-type)
		# Complete key
		local IFS=$'\n'
		COMPREPLY=( $( echo "$keys" | grep -i "^${cur//\\/\\\\}" ) )
		;;
	write)
		if [[ $key_index -eq $COMP_CWORD ]]; then
			# Complete key
			local IFS=$'\n'
			COMPREPLY=( $( echo "$keys" | grep -i "^${cur//\\/\\\\}" ) )
		elif [[ $((key_index+1)) -eq $COMP_CWORD ]]; then
			# Complete value type
			# Unfortunately ${COMP_WORDS[key_index]} fails on keys with spaces
			local value_types='-string -data -integer -float -boolean -date -array -array-add -dict -dict-add'
			local cur_type=$( defaults read-type $domain ${COMP_WORDS[key_index]} 2>/dev/null | sed -e 's/^Type is \(.*\)/-\1/' -e's/dictionary/dict/' | grep "^$cur" )
			if [[ $cur_type ]]; then
				COMPREPLY=( $cur_type )
			else
				COMPREPLY=( $( compgen -W "$value_types" -- $cur ) )
			fi
		elif [[ $((key_index+2)) -eq $COMP_CWORD ]]; then
			# Complete value
			# Unfortunately ${COMP_WORDS[key_index]} fails on keys with spaces
			COMPREPLY=( $( defaults read $domain ${COMP_WORDS[key_index]} 2>/dev/null | grep -i "^${cur//\\/\\\\}" ) )
		fi
		;;
	rename)
		if [[ $key_index -eq $COMP_CWORD ]] ||
		   [[ $((key_index+1)) -eq $COMP_CWORD ]]; then
			# Complete source and destination keys
			local IFS=$'\n'
			COMPREPLY=( $( echo "$keys" | grep -i "^${cur//\\/\\\\}" ) )
		fi
		;;
	delete)
		if [[ $key_index -eq $COMP_CWORD ]]; then
			# Complete key
			local IFS=$'\n'
			COMPREPLY=( $( echo "$keys" | grep -i "^${cur//\\/\\\\}" ) )
		fi
		;;
	esac

    return 0
}

complete -F _defaults -o default defaults


# This file is licensed under the BSD license, as follows:
#
# Copyright (c) 2006, Playhaus
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# * Neither the name of the Playhaus nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose are
# disclaimed. In no event shall the copyright owner or contributors be liable
# for any direct, indirect, incidental, special, exemplary, or consequential
# damages (including, but not limited to, procurement of substitute goods or
# services; loss of use, data, or profits; or business interruption) however
# caused and on any theory of liability, whether in contract, strict liability,
# or tort (including negligence or otherwise) arising in any way out of the use
# of this software, even if advised of the possibility of such damage.
