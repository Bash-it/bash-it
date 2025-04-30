# shellcheck shell=bash
about-alias 'heroku task abbreviations'

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
