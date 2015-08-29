cite about-plugin
about-plugin 'make and cd into a directory in one command'

function mkcd () { mkdir -p "$@" && eval cd "\"\$$#\""; }
