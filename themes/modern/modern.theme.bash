SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=' ${bold_red}✗${normal}'
SCM_THEME_PROMPT_CLEAN=' ${bold_green}✓${normal}'
SCM_GIT_CHAR='${bold_green}±${normal}'
SCM_SVN_CHAR='${bold_cyan}⑆${normal}'
SCM_HG_CHAR='${bold_red}☿${normal}'

PS3=">> "

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
		PS1="${bold_red}┌─${reset_color}$(modern_scm_prompt)[${cyan}\W${normal}]
${bold_red}└─▪${normal} "
	else
		PS1="┌─$(modern_scm_prompt)[${cyan}\W${normal}]
└─▪ "
	fi
}

PS2="└─▪ "



PROMPT_COMMAND=prompt
