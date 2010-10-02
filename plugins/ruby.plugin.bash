#!/bin/bash
function remove_gem {
  gem list | grep $1 | awk '{ print $1; }' | xargs sudo gem uninstall
}