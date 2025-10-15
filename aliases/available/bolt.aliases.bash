# shellcheck shell=bash
about-alias 'puppet bolt aliases'
url "https://www.puppet.com/docs/bolt/"

# Aliases
alias bolt='bolt command run --tty --no-host-key-check'
alias boltas='bolt -p -u'
alias sudobolt='bolt --run-as root --sudo-password'
alias sudoboltas='sudobolt -p -u'
