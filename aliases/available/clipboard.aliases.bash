# shellcheck shell=bash
about-alias 'xclip shortcuts'

alias pbcopy="xclip -selection clipboard"
alias pbpaste="xclip -selection clipboard -o"

alias xcpy="xclip -selection clipboard"
alias xpst="xclip -selection clipboard -o"
# to use it just install xclip on your distribution and it would work like:
# $ echo "hello" | xcpy
# $ xpst
# hello

# very useful for things like:
# cat ~/.ssh/id_rsa.pub | xcpy
# have fun!
