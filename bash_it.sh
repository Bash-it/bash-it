#!/bin/bash
# Initialize Bash It

# Reload Library
alias reload='source ~/.bash_profile'

# Load the framework

# Load colors first so they can be use in base theme
source "${BASH}/themes/colors.theme.bash"
source "${BASH}/themes/base.theme.bash"

# Library
LIB="${BASH}/lib/*.bash"
for config_file in $LIB
do
  source $config_file
done

# Tab Completion
COMPLETION="${BASH}/completion/*.bash"
for config_file in $COMPLETION
do
  source $config_file
done

# Plugins
if [ ! -d "${BASH}/plugins/enabled" ]
then
  mkdir "${BASH}/plugins/enabled"
  ln -s ${BASH}/plugins/available/* "${BASH}/plugins/enabled"
fi
PLUGINS="${BASH}/plugins/enabled/*.bash"
for config_file in $PLUGINS
do
  source $config_file
done

# Aliases
if [ ! -d "${BASH}/aliases/enabled" ]
then
  mkdir "${BASH}/aliases/enabled"
  ln -s ${BASH}/aliases/available/* "${BASH}/aliases/enabled"
fi
FUNCTIONS="${BASH}/aliases/enabled/*.bash"
for config_file in $FUNCTIONS
do
  source $config_file
done

if [ -e "${BASH}/aliases/custom.aliases.bash" ]
then
  source "${BASH}/aliases/custom.aliases.bash"
fi

# Custom
CUSTOM="${BASH}/custom/*.bash"
for config_file in $CUSTOM
do
  source $config_file
done


unset config_file
if [[ $PROMPT ]]; then
    export PS1=$PROMPT
fi

# Adding Support for other OSes
PREVIEW="less"
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview"
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app"


#
# Custom Help

function bash-it() {
  echo "Welcome to Bash It!"
  echo
  echo "Here is a list of commands you can use to get help screens for specific pieces of Bash it:"
  echo
  echo "  rails-help                  This will list out all the aliases you can use with rails."
  echo "  git-help                    This will list out all the aliases you can use with git."
  echo "  todo-help                   This will list out all the aliases you can use with todo.txt-cli"
  echo "  brew-help                   This will list out all the aliases you can use with Homebrew"
  echo "  aliases-help                Generic list of aliases."
  echo "  plugins-help                This will list out all the plugins and functions you can use with bash-it"
  echo
}
