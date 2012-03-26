#!/bin/bash
# Initialize Bash It

# Reload Library
alias reload='source ~/.bash_profile'

# Only set $BASH_IT if it's not already set
if [ -z "$BASH_IT" ];
then
    # Setting $BASH to maintain backwards compatibility
    # TODO: warn users that they should upgrade their .bash_profile
    export BASH_IT=$BASH
    export BASH=`bash -c 'echo $BASH'`
fi

# For backwards compatibility, look in old BASH_THEME location
if [ -z "$BASH_IT_THEME" ];
then
    # TODO: warn users that they should upgrade their .bash_profile
    export BASH_IT_THEME="$BASH_THEME";
    unset $BASH_THEME;
fi

# Load colors first so they can be use in base theme
source "${BASH_IT}/themes/colors.theme.bash"
source "${BASH_IT}/themes/base.theme.bash"

# library
LIB="${BASH_IT}/lib/*.bash"
for config_file in $LIB
do
  source $config_file
done

# Load enabled aliases, completion, plugins
for file_type in "aliases" "completion" "plugins"
do
  _load_bash_it_files $file_type
done

# Load any custom aliases that the user has added
if [ -e "${BASH_IT}/aliases/custom.aliases.bash" ]
then
  source "${BASH_IT}/aliases/custom.aliases.bash"
fi

# Custom
CUSTOM="${BASH_IT}/custom/*.bash"
for config_file in $CUSTOM
do
  if [ -e "${config_file}" ]; then
    source $config_file
  fi
done

unset config_file
if [[ $PROMPT ]]; then
    export PS1=$PROMPT
fi

# Adding Support for other OSes
PREVIEW="less"
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview"
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app"

# Load all the Jekyll stuff

if [ -e $HOME/.jekyllconfig ]
then
  . $HOME/.jekyllconfig
fi


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
