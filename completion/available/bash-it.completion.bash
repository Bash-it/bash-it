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

	opts="help show enable disable"

	case "${prev}" in
		show)
			local show_args="plugins aliases completions"
			COMPREPLY=( $(compgen -W "${show_args}" -- ${cur}) )
			return 0
			;;
		help)
			local help_args="plugins aliases completions"
			COMPREPLY=( $(compgen -W "${help_args}" -- ${cur}) )
			return 0
			;;
		enable)
			_bash-it-comp-enable-disable
			return 0
			;;
		disable)
			_bash-it-comp-enable-disable
			return 0
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
		alias)
			prevprev="${COMP_WORDS[COMP_CWORD-2]}"

			case "${prevprev}" in
				enable)
					_bash-it-comp-list-available-not-enabled aliases
					return 0
					;;
				disable)
					_bash-it-comp-list-enabled aliases
					return 0
					;;
			esac
			;;
		plugin)
			prevprev="${COMP_WORDS[COMP_CWORD-2]}"

			case "${prevprev}" in
				enable)
					_bash-it-comp-list-available-not-enabled plugins
					return 0
					;;
				disable)
					_bash-it-comp-list-enabled plugins
					return 0
					;;
			esac
			;;
		completion)
			prevprev="${COMP_WORDS[COMP_CWORD-2]}"

			case "${prevprev}" in
				enable)
					_bash-it-comp-list-available-not-enabled completion
					return 0
					;;
				disable)
					_bash-it-comp-list-enabled completion
					return 0
					;;
			esac
			;;
	esac

	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )

	return 0
}

complete -F _bash-it-comp bash-it
