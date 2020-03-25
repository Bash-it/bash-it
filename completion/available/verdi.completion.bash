# For AiiDA's verdi command line interface tab-completion:
# https://aiida.readthedocs.io/projects/aiida-core/en/latest/install/configuration.html#verdi-tab-completion
#eval "$(_VERDI_COMPLETE=source verdi)"

_verdi_completion() {
    local IFS=$'\t'
    COMPREPLY=( $( env COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   _VERDI_COMPLETE=complete-bash $1 ) )
    return 0
}

complete -F _verdi_completion -o default verdi

