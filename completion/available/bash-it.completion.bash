# shellcheck shell=bash

function _compreply_candidates() {
	local IFS=$'\n'

	read -d '' -ra COMPREPLY < <(compgen -W "${candidates[*]}" -- "${cur}")
}

function _bash-it() {
	local cur prev verb file_type candidates suffix
	COMPREPLY=()
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"
	verb="${COMP_WORDS[1]}"
	file_type="${COMP_WORDS[2]:-}"
	candidates=('disable' 'enable' 'help' 'migrate' 'reload' 'restart' 'preview' 'profile' 'doctor' 'search' 'show' 'update' 'version')
	case "${verb}" in
		show)
			candidates=('aliases' 'completions' 'plugins')
			_compreply_candidates
			;;
		help)
			if [[ "${prev}" == "aliases" ]]; then
				candidates=('all' "$(_bash-it-component-list "${file_type}")")
				_compreply_candidates
			else
				candidates=('aliases' 'completions' 'migrate' 'plugins' 'update')
				_compreply_candidates
			fi
			;;
		profile)
			case "${file_type}" in
				load | rm)
					if [[ "${file_type}" == "$prev" ]]; then
						candidates=("${BASH_IT}/profiles"/*.bash_it)
						candidates=("${candidates[@]##*/}")
						candidates=("${candidates[@]%%.bash_it}")

						_compreply_candidates
					fi
					;;
				save | list) ;;
				*)
					candidates=('load' 'save' 'list' 'rm')
					_compreply_candidates
					;;
			esac
			;;
		doctor)
			candidates=('errors' 'warnings' 'all')
			_compreply_candidates
			;;
		update)
			if [[ "${cur}" == -* ]]; then
				candidates=('-s' '--silent')
			else
				candidates=('stable' 'dev')
			fi
			_compreply_candidates
			;;
		migrate | reload | restart | search | version) ;;
		preview)
			_bash-it-preview # completes itself
			return 0
			;;
		enable | disable)
			if [[ "${verb}" == "enable" ]]; then
				suffix="disabled"
			else
				suffix="enabled"
			fi
			case "${file_type}" in
				alias | completion | plugin)
					candidates=('all' "$("_bash-it-component-list-${suffix}" "${file_type}")")
					_compreply_candidates
					;;
				*)
					candidates=('alias' 'completion' 'plugin')
					_compreply_candidates
					;;
			esac
			;;
		*)
			_compreply_candidates
			;;
	esac
}

# Activate completion for bash-it and its common misspellings
complete -F _bash-it bash-it
complete -F _bash-it bash-ti
complete -F _bash-it shit
complete -F _bash-it bashit
complete -F _bash-it batshit
complete -F _bash-it bash_it
