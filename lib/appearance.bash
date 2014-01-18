#!/usr/bin/env bash

# colored grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;33'

# colored ls
export LSCOLORS='Gxfxcxdxdxegedabagacad'

# colored ls
#if [[ ! -z $(which dircolors) ]]
#then
#    export DIRCOLORS_COMMAND=dircolors
#elif [[ ! -z $(which gdircolors) ]]
#then
#    export DIRCOLORS_COMMAND=gdircolors
#fi
#eval `$DIRCOLORS_COMMAND $BASH_IT/dircolors/$LS_THEME`


# Load the theme
if [[ $BASH_IT_THEME ]]; then
    source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
fi

