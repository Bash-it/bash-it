cite about-alias
about-alias 'general aliases'

# List directory contents
# Alias source: http://tldp.org/LDP/abs/html/sample-bashrc.html

local LS_COLOR_OPTION

case "$OSTYPE" in
  linux*)
    # Set Linux color option
    LS_COLOR_OPTION="--color=auto"
    ;;
  darwin*)
    # Set BSD color optio
    LS_COLOR_OPTION="-G"
    #Check if coreutils version of if exists
    if [[ -x "/usr/local/opt/coreutils/libexec/gnubin/ls" ]]; then
      # Check if coreutils path is in $PATH
      if [[ ":$PATH:" == *":/usr/local/opt/coreutils/libexec/gnubin:"* ]]; then
        # Set Linux color option
        LS_COLOR_OPTION="--color=auto"
      fi
    fi
    ;;
  *)
    # Use Linux color option as fallback
    LS_COLOR_OPTION="--color=auto"
    ;;
esac


# # Add colors for filetype and  human-readable sizes by default on 'ls':
alias l="ls -a $LS_COLOR_OPTION"            # Standard
alias lx="ls -lXB $LS_COLOR_OPTION"         # Sort by extension.
alias lk="ls -lSr $LS_COLOR_OPTION"         # Sort by size, biggest last.
alias lt="ls -ltr $LS_COLOR_OPTION"         # Sort by date, most recent last.
alias lc="ls -ltcr $LS_COLOR_OPTION"        # Sort by/show change time,most recent last.
alias lu="ls -ltur $LS_COLOR_OPTION"        # Sort by/show access time,most recent last.

# # The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first $LS_COLOR_OPTION"
alias lm="ll |more"                # Pipe through "more"
alias lr="ll -R"                   # Recursive ls.
alias la="ll -A"                   # Show hidden files.

alias sl="ls"
alias l1="ls -1 --group-directories-first $LS_COLOR_OPTION"


alias _="sudo"


which gshuf &> /dev/null
if [ $? -eq 0 ]
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
