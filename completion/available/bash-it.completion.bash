#!/usr/bin/env bash

_bash-it-comp-enable-disable()
{
	local enable_disable_args="alias plugin completion"
	COMPREPLY=( $(compgen -W "${enable_disable_args}" -- ${cur}) )
}

_bash-it-comp-list-available-not-enabled()
{
	subdirectory="$1"

	local available_things=$(for f in `ls -1 $BASH_IT/$subdirectory/available/*.bash`;
		do
			if [ ! -e $BASH_IT/$subdirectory/enabled/$(basename $f) ]
			then
				basename $f | cut -d'.' -f1
			fi
		done)

	COMPREPLY=( $(compgen -W "all ${available_things}" -- ${cur}) )
}

_bash-it-comp-list-enabled()
{
	subdirectory="$1"

	local enabled_things=$(for f in `ls -1 $BASH_IT/$subdirectory/enabled/*.bash`;
		do
			basename $f | cut -d'.' -f1
		done)

	COMPREPLY=( $(compgen -W "all ${enabled_things}" -- ${cur}) )
}

_bash-it-comp-list-available()
{
	subdirectory="$1"

	local enabled_things=$(for f in `ls -1 $BASH_IT/$subdirectory/available/*.bash`;
		do
			basename $f | cut -d'.' -f1
		done)

	COMPREPLY=( $(compgen -W "${enabled_things}" -- ${cur}) )
}

_bash-it-comp()
{
	local cur prev opts prevprev
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD-1]}"
	chose_opt="${COMP_WORDS[1]}"
	file_type="${COMP_WORDS[2]}"
	opts="help show enable disable update search"
	case "${chose_opt}" in
		show)
			local show_args="plugins aliases completions"
			COMPREPLY=( $(compgen -W "${show_args}" -- ${cur}) )
			return 0
			;;
		help)
			local help_args="plugins aliases completions update"
			COMPREPLY=( $(compgen -W "${help_args}" -- ${cur}) )
			return 0
			;;
    update | search)
      return 0
      ;;
		enable | disable)
			if [ x"${chose_opt}" == x"enable" ];then
				suffix="available-not-enabled"
			else
				suffix="enabled"
			fi
			case "${file_type}" in
				alias)
						_bash-it-comp-list-${suffix} aliases
						return 0
						;;
				plugin)
						_bash-it-comp-list-${suffix} plugins
						return 0
						;;
				completion)
						_bash-it-comp-list-${suffix} completion
						return 0
						;;
				*)
						_bash-it-comp-enable-disable
						return 0
						;;
			esac
			;;
		aliases)
			prevprev="${COMP_WORDS[COMP_CWORD-2]}"

			case "${prevprev}" in
				help)
					_bash-it-comp-list-available aliases
					return 0
					;;
			esac
			;;
	esac

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

	return 0
}

complete -F _bash-it-comp bash-it
