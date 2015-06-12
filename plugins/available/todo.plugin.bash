#!/bin/bash

# you may override any of the exported variables below in your .bash_profile

if [ -z "$TODO_DIR" ]; then
    export TODO_DIR=$BASH_IT/custom  # store todo items in user's custom dir, ignored by git
fi
if [ -z "$TODOTXT_DEFAULT_ACTION" ]; then
    export TODOTXT_DEFAULT_ACTION=ls       # typing 't' by itself will list current todos
fi
if [ -z "$TODO_SRC_DIR" ]; then
    export TODO_SRC_DIR=$BASH_IT/plugins/available/todo
fi

# respect ENV var set in .bash_profile, default is 't'
alias $TODO='$TODO_SRC_DIR/todo.sh -d $TODO_SRC_DIR/todo.cfg'

pathmunge $TODO_SRC_DIR after

source $TODO_SRC_DIR/todo_completion   # bash completion for todo.sh
complete -F _todo $TODO                # enable completion for 't' alias
