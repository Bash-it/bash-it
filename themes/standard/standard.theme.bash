# scm themeing
SCM_THEME_PROMPT_DIRTY="×"
SCM_THEME_PROMPT_CLEAN="✓"
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

# TODO: need a check for OS before adding this to the prompt
# ${debian_chroot:+($debian_chroot)}

#added TITLEBAR for updating the tab and window titles with the pwd
case $TERM in
	xterm*)
		TITLEBAR='\[\033]0;\w\007\]'
		;;
	*)
		TITLEBAR=""
		;;
esac

function prompt_command() {
	PROMPT='${green}\u${normal}@${green}\h${normal}:${blue}\w${normal}${red}$(prompt_char)$(git_prompt_info)${normal}\$ '
}

safe_append_prompt_command prompt_command
