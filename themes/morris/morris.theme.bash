
# prompt theming

# added TITLEBAR for updating the tab and window titles with the pwd
case $TERM in
	xterm*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

function prompt_command() {
	PS1="${TITLEBAR}[\u@\h \W $(scm_prompt_info)]\$ "
}

# scm theming
SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX="${green}("
SCM_THEME_PROMPT_SUFFIX="${green})${reset_color}"


PROMPT_COMMAND=prompt_command;
