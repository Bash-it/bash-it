cite 'about-alias'
about-alias 'pbcopy and pbpaste shortcuts to linux'

case $OSTYPE in
  linux*)
    XCLIP=$(command -v xclip)
    [[ $XCLIP ]] && alias pbcopy="$XCLIP -selection clipboard" && alias pbpaste="$XCLIP -selection clipboard -o"
    ;;   
esac

# to use it just install xclip on your distribution and it would work like:
# $ echo "hello" | pbcopy
# $ pbpaste
# hello

# very useful for things like:
# cat ~/.ssh/id_rsa.pub | pbcopy
# have fun!
