# shellcheck shell=bash
# shellcheck source-path=SCRIPTDIR
about-alias 'general aliases'

alias _='sudo'

# colored grep
# Need to check an existing file for a pattern that will be found to ensure
# that the check works when on an OS that supports the color option
if command grep --color=auto "a" "${BASH_IT?}"/*.md &> /dev/null; then
	alias grep='grep --color=auto'
fi

if _command_exists gshuf; then
	alias shuf=gshuf
fi

alias c='clear'
alias cls='clear'

alias pager='${PAGER:-less}'

alias q='exit'

alias irc='${IRC_CLIENT:-irc}'

# Language aliases
alias rb='ruby'
alias py='python'
alias ipy='ipython'

# Pianobar can be found here: http://github.com/PromyLOPh/pianobar/
if _command_exists pianobar; then
	alias piano='pianobar'
fi

# Shell History
alias h='history'

# Tree
if ! _command_exists tree; then
	alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Shorten extract
alias xt='extract'

# Display whatever file is regular file or folder
function catt() {
	for i in "$@"; do
		if [[ -d "$i" ]]; then
			ls "$i"
		else
			cat "$i"
		fi
	done
}

# The Bash-it aliases were moved to the `bash-it.aliases.bash` file. The intent of this
# is to keep the script readable and less bloated. If you don't need to use
# the `general` aliases, but you want the Bash-it aliases, you can disable the `general`
# aliases and enable just the ones for Bash-it explicitly:
# bash-it disable alias general
# bash-it enable alias bash-it
source "$BASH_IT/aliases/available/bash-it.aliases.bash"
source "$BASH_IT/aliases/available/directory.aliases.bash"
source "$BASH_IT/aliases/available/editor.aliases.bash"
