# shellcheck shell=bash
cite "about-completion"
about-completion "gem completion"

__gem_completion() {
	local cur=${COMP_WORDS[COMP_CWORD]}
	local prev=${COMP_WORDS[COMP_CWORD - 1]}
	case $prev in
		install)
			# list the remote gems and add to completion
			if [ -z "$REMOTE_GEMS" ]; then
				read -r -a REMOTE_GEMS <<< "$(gem list --remote --no-versions | sed 's/\*\*\* REMOTE GEMS \*\*\*//' | tr '\n' ' ')"
			fi

			local cur=${COMP_WORDS[COMP_CWORD]}
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "${REMOTE_GEMS[*]}" -- "$cur"))
			return 0
			;;
		uninstall)
			# list all local installed gems and add to completion
			read -r -a LOCAL_GEMS <<< "$(gem list --no-versions | sed 's/\*\*\* LOCAL GEMS \*\*\*//' | tr '\n' ' ')"

			local cur=${COMP_WORDS[COMP_CWORD]}
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "${LOCAL_GEMS[*]}" -- "$cur"))
			return 0
			;;
	esac
	local commands=(build cert check cleanup contents dependency environment fetch generate_index help install list lock outdated owner pristine push query rdoc search server sources specification stale uninstall unpack update which)
	# shellcheck disable=SC2207
	COMPREPLY=($(compgen -W "${commands[*]}" -- "$cur"))
}

complete -F __gem_completion gem
