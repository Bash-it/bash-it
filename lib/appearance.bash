#!/usr/bin/env bash

function _has_colors()
{
    # Check that stdout is a terminal
    test -t 1 || return 1

    ncolors=$(tput colors)
    test -n "$ncolors" && test "$ncolors" -ge 8 || return 1
    return 0
}

# colored ls
export LSCOLORS='Gxfxcxdxdxegedabagacad'

if [[ -z "$CUSTOM_THEME_DIR" ]]; then
    CUSTOM_THEME_DIR="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/themes"
fi

# Load the theme
if [[ $BASH_IT_THEME ]]; then
    if [[ -f $BASH_IT_THEME ]]; then
        source $BASH_IT_THEME
    elif [[ -f "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash" ]]; then
        source "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    else
        source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    fi
fi
