# shellcheck shell=bash
#
# Displays the prompt from each _Bash It_ theme.

if [[ -n "${BASH_PREVIEW:-}" ]]; then
	unset BASH_PREVIEW #Prevent infinite looping
	echo "

  Previewing Bash-it Themes

  "

	for theme in "${BASH_IT?}/themes"/*/*.theme.bash; do
		BASH_IT_THEME=${theme%.theme.bash}
		BASH_IT_THEME=${BASH_IT_THEME##*/}
		echo "
    $BASH_IT_THEME"
		echo "" | bash --init-file "${BASH_IT?}/bash_it.sh" -i
	done
fi
