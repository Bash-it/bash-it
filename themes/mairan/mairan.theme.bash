# Mairan Bash Prompt, inspired by "Zork"

if tput setaf 1 &> /dev/null; then
    if [[ $(tput colors) -ge 256 ]] 2>/dev/null; then
      MAGENTA=$(tput setaf 9)
      ORANGE=$(tput setaf 172)
      GREEN=$(tput setaf 190)
      PURPLE=$(tput setaf 141)
      WHITE=$(tput setaf 0)
    else
      MAGENTA=$(tput setaf 5)
      ORANGE=$(tput setaf 4)
      GREEN=$(tput setaf 2)
      PURPLE=$(tput setaf 1)
      WHITE=$(tput setaf 7)
    fi
    BOLD=$(tput bold)
    RESET=$(tput sgr0)
else
    MAGENTA="\033[1;31m"
    ORANGE="\033[1;33m"
    GREEN="\033[1;32m"
    PURPLE="\033[1;35m"
    WHITE="\033[1;37m"
    BOLD=""
    RESET="\033[m"
fi

# prompt_symbol='λ'
# prompt_symbol='⚡'
prompt_symbol=''
BRACKET_COLOR=$ORANGE

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${bold_red}✗${normal}"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
SCM_GIT_CHAR="${bold_green}±${normal}"
SCM_SVN_CHAR="${bold_cyan}⑆${normal}"
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
                echo "[$(scm_char)][$GREEN$(scm_prompt_info)]"
        fi
}

# show chroot if exist
chroot(){
    if [ -n "$debian_chroot" ]
    then
        my_ps_chroot="${bold_cyan}$debian_chroot${normal}";
        echo "($my_ps_chroot)";
    fi
    }

# show virtualenvwrapper
my_ve(){
    if [ -n "$VIRTUAL_ENV" ]
    then
        my_ps_ve="${bold_purple}$ve${normal}";
        echo "($my_ps_ve)";
    fi
    echo "";
    }

prompt() {

    my_ps_host="$BOLD$ORANGE\h${normal}";
    # yes, these are the the same for now ...
    my_ps_host_root="$ORANGE\h${normal}";

    my_ps_user="$BOLD$GREEN\u${normal}"
    my_ps_root="${bold_red}\u${normal}";

    if [ -n "$VIRTUAL_ENV" ]
    then
        ve=`basename $VIRTUAL_ENV`;
    fi

    # nice prompt
    case "`id -u`" in
        0) PS1="\n${TITLEBAR}${BRACKET_COLOR}┌─${normal}$(my_ve)$(chroot)[$my_ps_root][$my_ps_host_root]$(modern_scm_prompt)$(__my_rvm_ruby_version)[${green}\w${normal}]$(is_vim_shell)${BRACKET_COLOR}
└─▪ ${prompt_symbol} ${normal}"
        ;;
        *) PS1="\n${TITLEBAR}${BRACKET_COLOR}┌─${normal}$(my_ve)$(chroot)[$my_ps_user][$my_ps_host]$(modern_scm_prompt)${normal}$(__my_rvm_ruby_version)[${green}\w${normal}]$(is_vim_shell)${BRACKET_COLOR}
└─▪ ${prompt_symbol} ${normal}"
        ;;
    esac
}

PS2="└─▪ "



safe_append_prompt_command prompt
