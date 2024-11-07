# shellcheck shell=bash
about-alias 'MSYS2 aliases'

LS_COMMON="-hG"
LS_COMMON="$LS_COMMON --color=auto"
LS_COMMON="$LS_COMMON -I NTUSER.DAT\* -I ntuser.dat\*"

# alias
# setup the main ls alias if we've established common args
alias ls='command ls ${LS_COMMON:-}'
alias ll="ls -l"
alias la="ls -a"
alias lal="ll -a"
alias lf="ls -F"
