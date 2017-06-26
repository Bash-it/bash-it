cite about-alias
about-alias 'general aliases'

if ls --color -d . &> /dev/null
then
  alias ls="ls --color=auto"
elif ls -G -d . &> /dev/null
then
  alias ls='ls -G'        # Compact view, show colors
fi

# List directory contents
alias sl=ls
alias la='ls -AF'       # Compact view, show hidden
alias ll='ls -al'
alias l='ls -a'
alias l1='ls -1'

alias _="sudo"

# Shortcuts to edit startup files
alias vigen="vim ~/.bash_it/aliases/available/general.aliases.bash"
alias vbrc="vim ~/.bashrc"
alias vbpf="vim ~/.bash_profile"

# vmpooler
function vm-grab() {
    printf "Hello! You rule. Which vm would you like?: "
    read vm_msg
    LDAP_USERNAME=rod LDAP_PASSWORD=$(python -c 'import getpass;print(getpass.getpass())') vmpool grab "$vm_msg"
}

function vm-list() {
LDAP_USERNAME=rod LDAP_PASSWORD=$(python -c 'import getpass;print(getpass.getpass())') vmpool list
}

# colored grep
# Need to check an existing file for a pattern that will be found to ensure
# that the check works when on an OS that supports the color option
if grep --color=auto "a" "${BASH_IT}/"*.md &> /dev/null
then
  alias grep='grep --color=auto'
  export GREP_COLOR='1;33'
fi

if which gshuf &> /dev/null
then
  alias shuf=gshuf
fi

alias c='clear'
alias k='clear'
alias cls='clear'

alias edit="$EDITOR"
alias pager="$PAGER"

alias q='exit'

alias irc="$IRC_CLIENT"

# Language aliases
alias rb='ruby'
alias py='python'
alias ipy='ipython'

# Pianobar can be found here: http://github.com/PromyLOPh/pianobar/

alias piano='pianobar'

alias ..='cd ..'         # Go up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias -- -='cd -'        # Go back

# Shell History
alias h='history'

# Tree
if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Directory
alias md='mkdir -p'
alias rd='rmdir'

# Common misspellings of bash-it
alias bsh='bash-it'
alias batbsh='bash-it'
alias babsh='bash-it'
alias bash_it='bash-it'
alias bash_ti='bash-it'
alias bsh='bash-it'

# Additional bash-it aliases for help/show
alias bshsa='bash-it show aliases'
alias bshsc='bash-it show completions'
alias bshsp='bash-it show plugins'
alias bshha='bash-it help aliases'
alias bshhc='bash-it help completions'
alias bshhp='bash-it help plugins'
alias bshsch="bash-it search $1"
alias bshschen="bash-it search $1 --enable"
alias bshenp="bash-it enable plugin"
alias bshena="bash-it enable alias"
alias bshenc="bash-it enable completion"

# Shorten extract
alias xt="extract"

# source ~/.bash_profile
alias sprof="source ~/.bash_profile"

# sudo vim
alias svim="sudo vim"

# Display whatever file is regular file or folder
catt() {
  for i in "$@"; do
    if [ -d "$i" ]; then
      ls "$i"
    else
      cat "$i"
    fi
  done
}
