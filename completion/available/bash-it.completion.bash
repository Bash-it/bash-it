# shellcheck shell=bash

function _bash-it-comp-list-available-not-enabled() {
	local subdirectory="$1"
	COMPREPLY=($(compgen -W "all $(_bash-it-component-list-disabled "${subdirectory}")" -- "${cur}"))
}

function _bash-it-comp-list-enabled() {
	local subdirectory="$1"
	COMPREPLY=($(compgen -W "all $(_bash-it-component-list-enabled "${subdirectory}")" -- "${cur}"))
}

function _bash-it-comp-list-available() {
	local subdirectory="$1"
	COMPREPLY=($(compgen -W "all $(_bash-it-component-list "${subdirectory}")" -- "${cur}"))
}

function _bash-it-comp-list-profiles() {
	local profiles

	profiles=("${BASH_IT}/profiles"/*.bash_it)
	profiles=("${profiles[@]##*/}")

	COMPREPLY=($(compgen -W "${profiles[*]%%.bash_it}" -- "${cur}"))
}

function _bash-it-comp() {
	local cur prev opts
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"
	chose_opt="${COMP_WORDS[1]}"
	file_type="${COMP_WORDS[2]:-}"
	opts="disable enable help migrate reload restart profile doctor search show update version"
	case "${chose_opt}" in
		show)
			local show_args="aliases completions plugins"
			COMPREPLY=($(compgen -W "${show_args}" -- "${cur}"))
			return 0
			;;
		help)
			if [[ "${prev}" == "aliases" ]]; then
				_bash-it-comp-list-available aliases
				return 0
			else
				local help_args="aliases completions migrate plugins update"
				COMPREPLY=($(compgen -W "${help_args}" -- "${cur}"))
				return 0
			fi
			;;
		profile)
			case "${file_type}" in
				load)
					if [[ "load" == "$prev" ]]; then
						_bash-it-comp-list-profiles
					fi
					return 0
					;;
				rm)
					if [[ "rm" == "$prev" ]]; then
						_bash-it-comp-list-profiles
					fi
					return 0
					;;
				save)
					return 0
					;;
				list)
					return 0
					;;
				*)
					local profile_args="load save list rm"
					COMPREPLY=($(compgen -W "${profile_args}" -- "${cur}"))
					return 0
					;;
			esac
			;;
		doctor)
			local doctor_args="errors warnings all"
			COMPREPLY=($(compgen -W "${doctor_args}" -- "${cur}"))
			return 0
			;;
		update)
			if [[ "${cur}" == -* ]]; then
				local update_args="-s --silent"
			else
				local update_args="stable dev"
			fi
			COMPREPLY=($(compgen -W "${update_args}" -- "${cur}"))
			return 0
			;;
		migrate | reload | restart | search | version)
			return 0
			;;
		enable | disable)
			if [[ "${chose_opt}" == "enable" ]]; then
				suffix="available-not-enabled"
			else
				suffix="enabled"
			fi
			case "${file_type}" in
				alias | completion | plugin)
					_bash-it-comp-list-"${suffix}" "${file_type}"
					return 0
					;;
				*)
					local enable_disable_args="alias completion plugin"
					COMPREPLY=($(compgen -W "${enable_disable_args}" -- "${cur}"))
					return 0
					;;
			esac
			;;
	esac

	COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))

	return 0
}

# Activate completion for bash-it and its common misspellings
complete -F _bash-it-comp bash-it
complete -F _bash-it-comp bash-ti
complete -F _bash-it-comp shit
complete -F _bash-it-comp bashit
complete -F _bash-it-comp batshit
complete -F _bash-it-comp bash_it
