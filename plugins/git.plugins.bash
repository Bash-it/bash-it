#!/bin/bash

function git_remote {
  echo "Running: git remote add origin ${GIT_HOSTING}:$1.git"
  git remote add origin $GIT_HOSTING:$1.git
}

function git_first_push {
  echo "Running: git push origin master:refs/heads/master"
  git push origin master:refs/heads/master
}

function git_remove_missing_files() {
  git ls-files -d -z | xargs -0 git update-index --remove
}

# Adds files to git's exclude file (same as .gitignore)
function local-ignore() {
  echo "$1" >> .git/info/exclude
}

# get a quick overview for your git repo
function git_info() {
    if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
        # print informations
        echo "git repo overview"
        echo "-----------------"
        echo

        # print all remotes and thier details
        for remote in $(git remote show); do
            echo $remote:  
            git remote show $remote
            echo
        done

        # print status of working repo
        echo "status:"
        if [ -n "$(git status -s 2> /dev/null)" ]; then
            git status -s
        else
            echo "working directory is clean"
        fi

        # print at least 5 last log entries
        echo 
        echo "log:"
        git log -5 --oneline
        echo 

    else
        echo "you're currently not in a git repository"

    fi
}

