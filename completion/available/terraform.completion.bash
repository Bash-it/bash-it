#!/usr/bin/env bash
# Bash completion for the terraform command
# 
# Copyright (c) 2018 Vangelis Tasoulas <vangelis@tasoulas.net>.

_terraform() {
	local cur prev words cword opts
	_get_comp_words_by_ref -n : cur prev words cword
	COMPREPLY=()
	opts=""

	if [[ ${cword} -eq 1 ]] ; then

		# Options that do not start with a hyphen, are always starting with four spaces.
		opts="$(terraform --help | grep -P '^\s\s\s\s\S' | awk '{print $1}')"
		opts="${opts} --help --version"

	elif [[ ${cword} -gt 1 ]] ; then

		if [[ ${cword} -eq 2 && ${prev} == '--help' ]] ; then

			opts="$(terraform --help | grep -P '^\s\s\s\s\S' | awk '{print $1}')"

		elif [[ ${words[1]} != "--help" && ${words[1]} != "--version" && ${words[1]} != "version" ]] ; then

			# Some commands acceps hyphened parameters,...
			opts="$(terraform --help "${words[1]}" | grep -P '^\s+-' | awk '{print $1}' | awk -F '=' '{ if ($0 ~ /=/) {print $1"="} else {print $1} }')"
			# but some other commands accept non hyphened parameters....
			opts="${opts} $(terraform --help "${words[1]}" | grep -P '^\s\s\s\s\S' | awk '{print $1}')"
			# All of the commands accept the --help parameter which is not listed
			# by the 'terraform --help <command>
			opts="${opts} --help"

		fi
	fi

	COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )

	if [[ ${#COMPREPLY[*]} -eq 1 ]] ; then
		if [[ ${COMPREPLY[0]} == *= ]]; then
			# When only one completion is left, check if there is an equal sign.
			# If an equal sign, then add no space after the autocompleted word.
			compopt -o nospace;
		fi
	fi
	return 0
}

complete -F _terraform terraform
