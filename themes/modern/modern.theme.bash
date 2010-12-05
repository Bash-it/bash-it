SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

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
		PS1="${bold_red}┌─${reset_color}$(modern_scm_prompt)[\W]
${bold_red}└─▪${normal} "
	else
		PS1="┌─$(modern_scm_prompt)[\W]
└─▪ "
	fi
}



PROMPT_COMMAND=prompt
