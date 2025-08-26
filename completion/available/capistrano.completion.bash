# shellcheck shell=bash
# Bash completion support for Capistrano.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_capcomplete() {
	if [ -f Capfile ]; then
		# shellcheck disable=SC2012
		recent=$(ls -t .cap_tasks~ Capfile ./**/*.cap 2> /dev/null | head -n 1)
		if [[ $recent != '.cap_tasks~' ]]; then
			if cap --version | grep -q 'Capistrano v2.'; then
				# Capistrano 2.x
				cap --tool --verbose --tasks | cut -d " " -f 2 > .cap_tasks~
			else
				# Capistrano 3.x
				cap --all --tasks | cut -d " " -f 2 > .cap_tasks~
			fi
		fi
		# shellcheck disable=SC2207
		COMPREPLY=($(compgen -W "$(cat .cap_tasks~)" -- "${COMP_WORDS[COMP_CWORD]}"))
		return 0
	fi
}

complete -o default -o nospace -F _capcomplete cap
