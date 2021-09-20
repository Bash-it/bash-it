#!/bin/bash
cite about-plugin
about-plugin 'Todo.txt integration'

# you may override any of the exported variables below in your .bash_profile

if [ -z "$TODOTXT_DEFAULT_ACTION" ]; then
  # typing 't' by itself will list current todos
  export TODOTXT_DEFAULT_ACTION=ls
fi

alias t='todo.sh'
