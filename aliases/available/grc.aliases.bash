cite about-alias
about-alias 'grc aliases'

# Generic coloriser found at https://github.com/garabik/grc
# apt-get install grc or for rpm based systems grab the binary or build from repo
#
if [[ -x `which grc` ]]; then
    alias grc='grc --colour=auto'
    alias ping='grc ping'
    alias last='grc last'
    alias netstat='grc netstat'
    alias traceroute='grc traceroute'
    alias diff='grc diff'
    alias gcc='grc gcc'
    alias configure='grc configure'
    alias cvs='grc cvs'
    alias ps='grc ps'
    alias ifconfig='grc ifconfig'
fi
