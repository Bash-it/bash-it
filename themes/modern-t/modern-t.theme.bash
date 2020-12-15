# The "modern-t" theme is a "modern" theme variant with support
# for "t", the minimalist python todo list utility by Steve Losh.
# Get and install "t" at https://github.com/sjl/t#installing-t
#
# Warning: The Bash-it plugin "todo.plugin" breaks the "t"
# prompt integration, please disable it while using this theme.

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
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "[${cyan}vim shell${normal}]"
	fi
}

modern_scm_prompt() {
	CHAR=$(scm_char)
	if [ $CHAR = $SCM_NONE_CHAR ]
	then
		return
	else
		echo "[$(scm_char)][$(scm_prompt_info)]"
	fi
}

prompt() {
	if [ $? -ne 0 ]
	then
		# Yes, the indenting on these is weird, but it has to be like
		# this otherwise it won't display properly.

		PS1="${TITLEBAR}${bold_red}┌─[${cyan}$(t | wc -l | sed -e's/ *//')${reset_color}]${reset_color}$(modern_scm_prompt)[${cyan}\W${normal}]$(is_vim_shell)
${bold_red}└─▪${normal} "
	else
		PS1="${TITLEBAR}┌─[${cyan}$(t | wc -l | sed -e's/ *//')${reset_color}]$(modern_scm_prompt)[${cyan}\W${normal}]$(is_vim_shell)
└─▪ "
	fi
}

PS2="└─▪ "



safe_append_prompt_command prompt
