# shellcheck shell=bash
about-alias 'jitsu task abbreviations'

# jitsu
alias j='jitsu'
alias jl='jitsu login'
alias jo='jitsu logout'

# deploy and update
alias jd='jitsu apps deploy'
alias ju='jitsu apps update'

# new and start, restart, stop
alias jn='jitsu apps create'
alias js='jitsu apps start'
alias jr='jitsu apps restart'
alias jx='jitsu apps stop'

# logs
alias jll='jitsu logs'
alias jlog='jitsu logs'
alias jlogs='jitsu logs'

# env
alias je='jitsu env'
alias jel='jitsu env list'
alias jes='jitsu env set'
alias jeg='jitsu env get'
alias jed='jitsu env delete'
alias jec='jitsu env clear'
alias jesv='jitsu env save'
alias jeld='jitsu env load'

# configuration
alias jc='jitsu conf'
alias jcl='jitsu config list'
alias jcs='jitsu config set'
alias jcg='jitsu config get'
alias jcd='jitsu config delete'

#  list and install, view
alias jls='jitsu list'
alias jin='jitsu install'
alias jv='jitsu apps view'

# Database, Snapshots and Tokens
alias jdb='jitsu databases'
alias jss='jitsu snapshots'
alias jto='jitsu tokens'
