cite about-alias
about-alias 'general aliases'

# List directory contents
# Source: http://tldp.org/LDP/abs/html/sample-bashrc.html

# # Add colors for filetype and  human-readable sizes by default on 'ls':
#alias ls='ls --color'
alias l='ls -a --color'            # Standard
alias lx='ls -lXB --color'         # Sort by extension.
alias lk='ls -lSr --color'         # Sort by size, biggest last.
alias lt='ls -ltr --color'         # Sort by date, most recent last.
alias lc='ls -ltcr --color'        # Sort by/show change time,most recent last.
alias lu='ls -ltur --color'        # Sort by/show access time,most recent last.

# # The ubiquitous 'll': directories first, with alphanumeric sorting:
alias ll="ls -lv --group-directories-first --color"
  alias lm='ll |more'                # Pipe through 'more'
  alias lr='ll -R'                   # Recursive ls.
  alias la='ll -A'                   # Show hidden files.
alias tree='tree -C'               # Nice alternative to 'recursive ls' ...

alias sl='ls'
alias l1='ls -1 --group-directories-first --color'

# alias ls='ls -G'        # Compact view, show colors
# alias la='ls -AF'       # Compact view, show hidden
# alias ll='ls -al'


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

alias rb='ruby'

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
alias	md='mkdir -p'
alias	rd='rmdir'

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
