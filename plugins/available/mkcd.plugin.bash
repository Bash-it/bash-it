function mkcd () { mkdir -p "$@" && eval cd "\"\$$#\""; }
