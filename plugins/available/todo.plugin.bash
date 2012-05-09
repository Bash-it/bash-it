#!/bin/bash

export TODO_DIR=$HOME/.bash_it/custom  # store todo items in user's custom dir, ignored by git
export TODOTXT_DEFAULT_ACTION=ls       # typing 't' by itself will list current todos

export TODO_SRC_DIR=$HOME/.bash_it/plugins/available/todo

# respect ENV var set in .bash_profile, default is 't'
alias $TODO='$TODO_SRC_DIR/todo.sh -d $TODO_SRC_DIR/todo.cfg'

export PATH=$PATH:$TODO_SRC_DIR
source $TODO_SRC_DIR/todo_completion   # bash completion for todo.sh
complete -F _todo $TODO                # enable completion for 't' alias
