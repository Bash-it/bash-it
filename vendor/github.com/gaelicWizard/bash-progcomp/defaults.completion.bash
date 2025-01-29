# shellcheck shell=bash
# shellcheck disable=SC2207
#
# Bash command line completion for defaults
#
# Version 1.0 created by Jonathon Mah on 2006-11-08.
# Version 2.0 written by John Pell on 2021-09-11.
#

function matchpattern()
{
	local PATTERN=${2:?$FUNCNAME: a pattern is required}
	local SEP=${3:-|}
	[[ -z "${PATTERN##*${SEP}${1}${SEP}*}" ]]
}

function _defaults_verbs()
{
	local IFS=$'\n'	# Treat only newlines as delimiters in string operations.
	local LC_CTYPE='C'	# Do not consider character set in string operations.
	local LC_COLLATE='C'	# Do not consider character set in pattern matching.
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"
	COMPREPLY=()

	case $COMP_CWORD in
	1)
		candidates=("${cmds// /$IFS}" "${host_opts[@]}")
		;;
	2 | 3)
		candidates=("${cmds// /$IFS}")
		;;
	*)
		return 1
		;;
	esac

	COMPREPLY=($(compgen -W "${candidates[*]}" | grep -i "^${cur}"))
	return 0
}

function _defaults_domains()
{
	local IFS=$'\n'	# Treat only newlines as delimiters in string operations.
	local LC_CTYPE='C'	# Do not consider character set in string operations.
	local LC_COLLATE='C'	# Do not consider character set in pattern matching.
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"
	COMPREPLY=()

	if [[ "$BASH_VERSINFO" -ge 4 ]]
	then # Exponential performance issue on strings greater than about 10k.
		local domains="$(defaults domains)"
		local candidates=($(compgen -W "${domains//, /$IFS}" | grep -i "^${cur}"))
	else
		local domains="$(defaults domains | sed -e 's/, /^/g' | tr '^' '\n')"
		local candidates=($(compgen -W "${domains}" | grep -i "^${cur}"))
	fi
	COMPREPLY=($(printf '%q\n' "${candidates[@]}"))
	if grep -q "^$cur" <<< '-app'
	then
		COMPREPLY[${#COMPREPLY[@]}]="-app"
	elif grep -q "^$cur" <<< '-g'
	then
		COMPREPLY[${#COMPREPLY[@]}]="-g"
	fi

	return 0
}

function _defaults()
{
	local IFS=$'\n'	# Treat only newlines as delimiters in string operations.
	local LC_CTYPE='C'	# Do not consider character set in string operations.
	local LC_COLLATE='C'	# Do not consider character set in pattern matching.
	local cur="${COMP_WORDS[COMP_CWORD]}"
	local prev="${COMP_WORDS[COMP_CWORD - 1]}"
	COMPREPLY=()

	local host_opts cmds cmd domain keys key_index candidates verbs value_types

	host_opts=('-currentHost' '-host')
	cmds=' delete domains export find help import read read-type rename write '
	value_types=('-string' '-data' '-integer' '-float' '-boolean' '-date' '-array' '-array-add' '-dict' '-dict-add')

	case $COMP_CWORD in
	1)
		_defaults_verbs
		return "$?"
		;;
	2)
		case $prev in
		"-currentHost")
			_defaults_verbs
			;;
		"-host")
			_known_hosts -a
			;;
		*)
			if matchpattern "$prev" "${cmds// /|}"
			then
				# TODO: not correct for verbs: domains, find, help
				_defaults_domains
			else
				return 1 # verb is not recognized
			fi
			;;
		esac
		return "$?"
		;;
	3)
		case ${COMP_WORDS[1]} in
		"-currentHost")
			_defaults_domains
			return "$?"
			;;
		"-host")
			_defaults_verbs
			return "$?"
			;;
		esac
		;;
	4)
		case ${COMP_WORDS[1]} in
		"-host")
			if matchpattern "$prev" "${cmds// /|}"
			then
				# TODO: not correct for verbs: domains, find, help
				_defaults_domains
			else
				return 1 # verb is not recognized
			fi
			;;
		esac
		;;
	esac

	# Both a domain and command have been specified

	case ${COMP_WORDS[1]} in
	"-currentHost")
		if matchpattern "${COMP_WORDS[2]}" "${cmds// /|}"
		then
			cmd="${COMP_WORDS[2]}"
			domain="${COMP_WORDS[3]}"
			key_index=4
			if [[ "$domain" == "-app" ]]
			then
				if [[ $COMP_CWORD -eq 4 ]]
				then
					# Completing application name. Can't help here, sorry
					return 0
				fi
				domain="-app ${COMP_WORDS[4]}"
				key_index=5
			fi
		fi
		;;
	"-host")
		if matchpattern "${COMP_WORDS[3]}" "${cmds// /|}"
		then
			cmd="${COMP_WORDS[3]}"
			domain="${COMP_WORDS[4]}"
			key_index=5
			if [[ "$domain" == "-app" ]]
			then
				if [[ $COMP_CWORD -eq 5 ]]
				then
					# Completing application name. Can't help here, sorry
					return 0
				fi
				domain="-app ${COMP_WORDS[5]}"
				key_index=6
			fi
		fi
		;;
	*)
		if matchpattern "${COMP_WORDS[1]}" "${cmds// /|}"
		then
			cmd="${COMP_WORDS[1]}"
			domain="${COMP_WORDS[2]}"
			key_index=3
			if [[ "$domain" == "-app" ]]
			then
				if [[ $COMP_CWORD -eq 3 ]]
				then
					# Completing application name. Can't help here, sorry
					return 0
				fi
				domain="-app ${COMP_WORDS[3]}"
				key_index=4
			fi
		fi
		;;

	esac

	keys=($(defaults read "$domain" 2> /dev/null | sed -n -e '/^    [^}) ]/p' | sed -e 's/^    \([^" ]\{1,\}\) = .*$/\1/g' -e 's/^    "\([^"]\{1,\}\)" = .*$/\1/g'))

	case $cmd in
	read | read-type)
		# Complete key
		if candidates=($(compgen -W "${keys[*]:-}" | grep -i "^${cur}"))
		then
			COMPREPLY=($(printf '%q\n' "${candidates[@]}"))
		fi
		;;
	write)
		if [[ $key_index -eq $COMP_CWORD ]]
		then
			# Complete key
			if candidates=($(compgen -W "${keys[*]:-}" | grep -i "^${cur}"))
			then
				COMPREPLY=($(printf '%q\n' "${candidates[@]}"))
			fi
		elif [[ $((key_index + 1)) -eq $COMP_CWORD ]]
		then
			# Complete value type
			local cur_type="$(defaults read-type "$domain" "${COMP_WORDS[key_index]}" 2> /dev/null | sed -e 's/^Type is \(.*\)/-\1/' -e's/dictionary/dict/' | grep "^$cur")"
			if [[ $cur_type ]]
			then
				COMPREPLY=("$cur_type")
			else
				COMPREPLY=($(compgen -W "${value_types[*]}" -- "$cur"))
			fi
		elif [[ $((key_index + 2)) -eq $COMP_CWORD ]]
		then
			# Complete value
			COMPREPLY=($(defaults read "$domain" "${COMP_WORDS[key_index]}" 2> /dev/null | grep -i "^${cur//\\/\\\\}"))
		fi
		;;
	rename)
		if [[ $key_index -eq $COMP_CWORD || $((key_index + 1)) -eq $COMP_CWORD ]]
		then
			# Complete source and destination keys
			if candidates=($(compgen -W "${keys[*]:-}" | grep -i "^${cur}"))
			then
				COMPREPLY=($(printf '%q\n' "${candidates[@]}"))
			fi
		fi
		;;
	delete)
		if [[ $key_index -eq $COMP_CWORD ]]
		then
			# Complete key
			if candidates=($(compgen -W "${keys[*]:-}" | grep -i "^${cur}"))
			then
				COMPREPLY=($(printf '%q\n' "${candidates[@]}"))
			fi
		fi
		;;
	esac

	return 0
}

complete -F _defaults -o default defaults

# This file is licensed under the BSD license, as follows:
#
# Copyright (c) 2006, Playhaus
# Copyright (c) 2021, gaelicWizard.LLC
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
# * Neither the names of the authors nor the names of its contributors may be
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
