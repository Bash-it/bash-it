# https://pip.pypa.io/en/stable/user_guide/#command-completion

# All of these codes are shipped within officical pip distribution.
# Use the following commands to obtain these completion codes:
#pip completion --bash 
#pip3 completion --bash

# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 2>/dev/null ) )
}
complete -o default -F _pip_completion pip
complete -o default -F _pip_completion pip3
# pip bash completion end

