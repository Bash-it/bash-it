# port of zork theme

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=' ${bold_red}✗${normal}'
SCM_THEME_PROMPT_CLEAN=' ${bold_green}✓${normal}'
SCM_GIT_CHAR='${bold_green}±${normal}'
SCM_SVN_CHAR='${bold_cyan}⑆${normal}'
SCM_HG_CHAR='${bold_red}☿${normal}'

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

is_vim_shell() {
        if [ ! -z "$VIMRUNTIME" ]
        then
                echo "[${cyan}vim shell${normal}]"
        fi
}

todo_txt_count() {
	if `hash todo.sh 2>&-`; then
		count=`todo.sh ls | egrep "TODO: [0-9]+ of ([0-9]+) tasks shown" | awk '{ print $4 }'`
		echo "[T:$count]"
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

    my_ps_host="${bold_green}\h${normal}";
    my_ps_user="${bold_green}\u${normal}";
    my_ps_root="${bold_red}\u${normal}";
    my_ps_path="${bold_cyan}\w${normal}";

    # nice prompt
    case "`id -u`" in
        0) PS1="${TITLEBAR}┌─[$my_ps_root][$my_ps_host]$(modern_scm_prompt)$(__my_rvm_ruby_version)[${cyan}\w${normal}]$(is_vim_shell)
└─▪ "
        ;;
        *) PS1="${TITLEBAR}┌─[$my_ps_user][$my_ps_host]$(modern_scm_prompt)$(__my_rvm_ruby_version)[${cyan}\w${normal}]$(is_vim_shell)
└─▪$(todo_txt_count) "
        ;;
    esac
}

PS2="└─▪ "



PROMPT_COMMAND=prompt
