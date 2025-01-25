SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_cyan}±${normal}"
SCM_SVN_CHAR="${bold_green}⑆${normal}"
SCM_HG_CHAR="${bold_red}☿${normal}"

#Mysql Prompt
export MYSQL_PS1="(\u@\h) [\d]> "

case $TERM in
	xterm*)
		TITLEBAR="\[\033]0;\w\007\]"
		;;
	*)
		TITLEBAR=""
		;;
esac

PS3=">> "

__my_rvm_ruby_version() {
	local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
	[ "$gemset" != "" ] && gemset="@$gemset"
	local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
	local full="$version$gemset"
	[ "$full" != "" ] && echo "[$full]"
}

__my_venv_prompt() {
	if [ ! -z "$VIRTUAL_ENV" ]; then
		echo "[${blue}@${normal}${VIRTUAL_ENV##*/}]"
	fi
}

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]; then
		echo "[${cyan}vim shell${normal}]"
	fi
}

prompt() {
	SCM_PROMPT_FORMAT='[%s][%s]'
	case $HOSTNAME in
		"clappy"*)
			my_ps_host="${green}\h${normal}"
			;;
		"icekernel")
			my_ps_host="${red}\h${normal}"
			;;
		*)
			my_ps_host="${green}\h${normal}"
			;;
	esac

	my_ps_user="\[\033[01;32m\]\u\[\033[00m\]"
	my_ps_root="\[\033[01;31m\]\u\[\033[00m\]"
	my_ps_path="\[\033[01;36m\]\w\[\033[00m\]"

	# nice prompt
	case "$(id -u)" in
		0)
			PS1="${TITLEBAR}[$my_ps_root][$my_ps_host]$(scm_prompt)$(__my_rvm_ruby_version)[${cyan}\w${normal}]$(is_vim_shell)
$ "
			;;
		*)
			PS1="${TITLEBAR}[$my_ps_user][$my_ps_host]$(scm_prompt)$(__my_rvm_ruby_version)$(__my_venv_prompt)[${cyan}\w${normal}]$(is_vim_shell)
$ "
			;;
	esac
}

PS2="> "

safe_append_prompt_command prompt
