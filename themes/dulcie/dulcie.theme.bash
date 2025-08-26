# shellcheck shell=bash
# shellcheck disable=SC2034 # Expected behavior for themes.

# Simplistic one-liner theme to display source control management info beside
# the ordinary Linux bash prompt.
#
# Demo:
#
# [ritola@localhost ~]$ cd .bash-it/themes/dulcie
# [ritola@localhost |master ✓| dulcie]$ # This is single line mode
# |bash-it|± master ✓|
# [ritola@localhost dulcie]$ # In multi line, the SCM info is in the separate line
#
# Configuration. Change these by adding them in your .bash_profile

DULCIE_COLOR=${DULCIE_COLOR:=1}         # 0 = monochrome, 1 = colorful
DULCIE_MULTILINE=${DULCIE_MULTILINE:=1} # 0 = Single line, 1 = SCM in separate line

dulcie_color() {
	echo -en "\[\e[38;5;${1}m\]"
}

dulcie_background() {
	echo -en "\[\e[48;5;${1}m\]"
}

dulcie_prompt() {
	color_user_root=$(dulcie_color 169)
	color_user_nonroot="${green?}"
	color_host_local=$(dulcie_color 230)
	color_host_remote=$(dulcie_color 214)
	color_rootdir=$(dulcie_color 117)
	color_workingdir=$(dulcie_color 117)
	background_scm=$(dulcie_background 238)

	SCM_THEME_ROOT_SUFFIX="|$(scm_char) "

	# Set colors
	if [ "${DULCIE_COLOR}" -eq "1" ]; then
		if [[ $EUID -ne 0 ]]; then
			color_user="${color_user_nonroot}"
		else
			color_user="${color_user_root}"
		fi

		if [[ -n "${SSH_CLIENT}" ]]; then
			color_host="${color_host_remote}"
		else
			color_host="${color_host_local}"
		fi

		DULCIE_USER="${color_user?}\u${reset_color?}"
		DULCIE_HOST="${color_host?}\h${reset_color?}"
		DULCIE_WORKINGDIR="${color_workingdir?}\W${reset_color?}"
		DULCIE_PROMPTCHAR="${color_user?}"'\$'"${reset_color?}"

		SCM_THEME_PROMPT_DIRTY=" ${red?}✗${reset_color}"
		SCM_THEME_PROMPT_CLEAN=" ${bold_green?}✓${normal?}"
		DULCIE_SCM_BACKGROUND="${background_scm}"
		DULCIE_SCM_DIR_COLOR="${color_rootdir}"
		SCM_THEME_ROOT_SUFFIX="${reset_color}${SCM_THEME_ROOT_SUFFIX}"
		SCM_THEME_PROMPT_DIRTY=" $(dulcie_color 1)✗${reset_color?}"
		SCM_THEME_PROMPT_CLEAN=" $(dulcie_color 10)✓${reset_color?}"
	else
		DULCIE_USER='\u'
		DULCIE_HOST='\h'
		DULCIE_WORKINGDIR='\W'
		DULCIE_PROMPTCHAR='\$'

		DULCIE_SCM_BACKGROUND=""
		DULCIE_SCM_DIR_COLOR=""
		SCM_THEME_DIR_COLOR=""
		SCM_THEME_PROMPT_DIRTY=" ✗"
		SCM_THEME_PROMPT_CLEAN=" ✓"
	fi

	# Change terminal title
	printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME%%.*}" "${PWD/#$HOME/\~}"

	# Open the new terminal in the same directory
	_is_function __vte_osc7 && __vte_osc7

	PS1="${reset_color}[${DULCIE_USER}@${DULCIE_HOST}$(scm_prompt_info)${reset_color?} ${DULCIE_WORKINGDIR}]"
	if [[ "${DULCIE_MULTILINE}" -eq "1" ]]; then
		PS1="${reset_color}[${DULCIE_USER}@${DULCIE_HOST}${reset_color?} ${DULCIE_WORKINGDIR}]"
		if [[ "$(scm_prompt_info)" ]]; then
			SCM_THEME_PROMPT_PREFIX="${DULCIE_SCM_BACKGROUND}|${DULCIE_SCM_DIR_COLOR}"
			SCM_THEME_PROMPT_SUFFIX="|${normal}"
			PS1="$(scm_prompt_info)\n${PS1}"
		fi
	else
		SCM_THEME_PROMPT_PREFIX=" ${DULCIE_SCM_BACKGROUND}|${DULCIE_SCM_DIR_COLOR}"
		SCM_THEME_PROMPT_SUFFIX="|${normal}"
		PS1="${reset_color?}[${DULCIE_USER}@${DULCIE_HOST}$(scm_prompt_info)${reset_color?} ${DULCIE_WORKINGDIR}]"
	fi
	PS1="${PS1}${DULCIE_PROMPTCHAR} "
}

safe_append_prompt_command dulcie_prompt
