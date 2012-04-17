#!/usr/bin/env bash

# heroku
alias h='heroku'
alias hl='heroku list'
alias hi='heroku info'
alias ho='heroku open'

# dynos and workers
alias hd='heroku dynos'
alias hw='heroku workers'

# rake console
alias hr='heroku rake'
alias hcon='heroku console'

# new and restart
alias hnew='heroku create'
alias hrestart='heroku restart'

# logs
alias hlog='heroku logs'
alias hlogs='heroku logs'

# maint
alias hon='heroku maintenance:on'
alias hoff='heroku maintenance:off'

# heroku configs
alias hc='heroku config'
alias hca='heroku config:add'
alias hcr='heroku config:remove'
alias hcc='heroku config:clear'

function heroku-help() {
  echo "Heroku Aliases Usage"
  echo
  echo "  h           = heroku"
  echo "  hl          = heroku list"
  echo "  hi          = heroku info"
  echo "  ho          = heroku open"
  echo "  hd          = heroku dynos"
  echo "  hw          = heroku workers"
  echo "  hr          = heroku rake"
  echo "  hcon        = heroku console"
  echo "  hnew        = heroku create"
  echo "  hrestart    = heroku restart"
  echo "  hlog        = heroku logs"
  echo "  hon         = heroku maintenance:on"
  echo "  hoff        = heroku maintenance:off"
  echo "  hc          = heroku config"
  echo "  hca         = heroku config:add"
  echo "  hcr         = heroku config:remove"
  echo "  hcc         = heroku config:clear"
  echo
}
