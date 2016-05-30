#!/usr/bin/env bash
# Initialize Bash It

# Reload Library
case $OSTYPE in
  darwin*)
    alias reload='source ~/.bash_profile'
    ;;
  *)
    alias reload='source ~/.bashrc'
    ;;
esac

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

# Load composure first, so we support function metadata
source "${BASH_IT}/lib/composure.bash"

# support 'plumbing' metadata
cite _about _param _example _group _author _version

# Load colors first so they can be use in base theme
source "${BASH_IT}/themes/colors.theme.bash"
source "${BASH_IT}/themes/base.theme.bash"

# libraries, but skip appearance (themes) for now
LIB="${BASH_IT}/lib/*.bash"
APPEARANCE_LIB="${BASH_IT}/lib/appearance.bash"
for config_file in $LIB
do
  if [ $config_file != $APPEARANCE_LIB ]; then
    source $config_file
  fi
done

# Load enabled aliases, completion, plugins
for file_type in "aliases" "completion" "plugins"
do
  _load_bash_it_files $file_type
done

# appearance (themes) now, after all dependencies
source $APPEARANCE_LIB

# Load custom aliases, completion, plugins
for file_type in "aliases" "completion" "plugins"
do
  if [ -e "${BASH_IT}/${file_type}/custom.${file_type}.bash" ]
  then
    source "${BASH_IT}/${file_type}/custom.${file_type}.bash"
  fi
done

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
    export PS1="\["$PROMPT"\]"
fi

# Adding Support for other OSes
PREVIEW="less"
[ -s /usr/bin/gloobus-preview ] && PREVIEW="gloobus-preview"
[ -s /Applications/Preview.app ] && PREVIEW="/Applications/Preview.app"

# Load all the Jekyll stuff

if [ -e "$HOME/.jekyllconfig" ]
then
  . "$HOME/.jekyllconfig"
fi
