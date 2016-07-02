#!/usr/bin/env bash

# colored grep
alias grep='grep --color=auto'
export GREP_COLOR='1;33'

# colored ls
export LSCOLORS='Gxfxcxdxdxegedabagacad'

if [[ -z "$CUSTOM_THEME_DIR" ]]; then
    CUSTOM_THEME_DIR="${BASH_IT}/custom/themes"
fi

# Load the theme
if [[ $BASH_IT_THEME ]]; then
    if [[ -f "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash" ]]; then
        source "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    else
        source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    fi
fi
