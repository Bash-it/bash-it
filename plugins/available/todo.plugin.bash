# shellcheck shell=bash
about-plugin 'Todo.txt integration'

# you may override any of the exported variables below in your .bash_profile
: "${TODOTXT_DEFAULT_ACTION:=ls}"
export TODOTXT_DEFAULT_ACTION
