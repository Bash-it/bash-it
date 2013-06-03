# cd becomes pushd
#
# cd : Push directory to stack and change directory
# ex $ cd /path/to/directory
#
# pd : Pop directory off stack and change to previous directory
# ex $ pd
#
# vd : View directory stack

cite about-plugin
about-plugin 'always use pushd - cd becomes pushd'

alias cd='pushd'
alias pd='popd'
alias vd='dirs -v'
