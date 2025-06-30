# Modified version of the original modern theme in bash-it
# Removes the battery charge and adds the current time

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

case $TERM in
	xterm*)
		TITLEBAR="\[\033]0;\w\007\]"
		;;
	*)
		TITLEBAR=""
		;;
esac

PS3=">> "

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]; then
		echo "[${cyan}vim shell${normal}]"
	fi
}

modern_current_time_prompt() {
	echo "[$(date '+%l:%M%p')]"
}

prompt() {
	SCM_PROMPT_FORMAT='[%s][%s]'
	if [ $? -ne 0 ]; then
		# Yes, the indenting on these is weird, but it has to be like
		# this otherwise it won't display properly.

		PS1="${TITLEBAR}${bold_red}┌─${reset_color}$(scm_prompt)$(modern_current_time_prompt)[${cyan}\W${normal}]$(is_vim_shell)
${bold_red}└─▪${normal} "
	else
		PS1="${TITLEBAR}┌─$(scm_prompt)$(modern_current_time_prompt)[${cyan}\W${normal}]$(is_vim_shell)
└─▪ "
	fi
}

PS2="└─▪ "

safe_append_prompt_command prompt
