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