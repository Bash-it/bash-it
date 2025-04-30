# shellcheck shell=bash
# Bash completion support for Rake, Ruby Make.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

_rakecomplete() {
	if [ -f Rakefile ]; then
		#shellcheck disable=SC2012
		recent=$(ls -t -- .rake_tasks~ Rakefile **/*.rake 2> /dev/null | head -n 1)
		if [[ $recent != '.rake_tasks~' ]]; then
			rake --silent --tasks | cut -d " " -f 2 > .rake_tasks~
		fi
		local line
		while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$(cat .rake_tasks~)" -- "${COMP_WORDS[COMP_CWORD]}")
		return 0
	fi
}

complete -o default -o nospace -F _rakecomplete rake
