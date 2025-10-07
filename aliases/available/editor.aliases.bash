# shellcheck shell=bash
about-alias 'shortcuts for editing'

alias edit='${EDITOR:-${ALTERNATE_EDITOR:-nano}}'
alias e='edit'

# sudo editors
alias svim='sudo ${VISUAL:-vim}'
alias snano='sudo ${ALTERNATE_EDITOR:-nano}'
alias sedit='sudo ${EDITOR:-${ALTERNATE_EDITOR:-nano}}'

# Shortcuts to edit startup files
alias vbrc='${VISUAL:-vim} ~/.bashrc'
alias vbpf='${VISUAL:-vim} ~/.bash_profile'
