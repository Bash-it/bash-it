#!/usr/bin/env bash

# Rails Commands
alias r='rails'
alias rg='rails g'
alias rs='rails s'
alias rc='rails c'
alias rn='rails new'
alias rd='rails dbconsole'
alias rp='rails plugin'
alias ra='rails application'
alias rd='rails destroy'
alias dbm='rake db:migrate'

alias ss='script/server'
alias ts="thin start"     # thin server
alias sc='script/console'
alias restartapp='touch tmp/restart.txt'
alias restart='touch tmp/restart.txt'  # restart passenger
alias devlog='tail -f log/development.log'
alias taild='tail -f log/development.log' # tail dev log

function rails-help() {
  echo "Rails Aliases Usage"
  echo
  echo "  r           = rails"
  echo "  rg          = rails generate"
  echo "  rs/ss       = rails server"
  echo "  ts          = thin server"
  echo "  rc/sc       = rails console"
  echo "  rn          = rails new"
  echo "  rd          = rails dbconsole"
  echo "  rp          = rails plugin"
  echo "  ra          = rails application"
  echo "  rd          = rails destroy"
  echo "  restartapp  = touch tmp/restart.txt"
  echo "  restart     = touch tmp/restart.txt"
  echo "  devlog      = tail -f log/development.log"
  echo "  taild       = tail -f log/development.log"
  echo
}

