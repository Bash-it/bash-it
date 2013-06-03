# cd becomes pushd
#
# Add to stack with: cd /path/to/directory
# Delete current dir from stack with: popd
# Show stack with: dirs

cite about-plugin
about-plugin 'always use pushd - cd becomes pushd'

alias cd='pushd'
alias dirs='dirs -v'
