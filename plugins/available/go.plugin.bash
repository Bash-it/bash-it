cite about-plugin
about-plugin 'go environment variables & path configuration'

# Load late to ensure goenv runs first, if enabled
# BASH_IT_LOAD_PRIORITY: 275

_command_exists go || return 0

# If using goenv, make sure it can find go
go version &>/dev/null || return 0

function _go_pathmunge_wrap() {
  IFS=':' local -a 'a=($1)'
  local i=${#a[@]}
  while [ $i -gt 0 ] ; do
    i=$(( i - 1 ))
    pathmunge "${a[i]}/bin"
  done
}

export GOROOT="${GOROOT:-$(go env GOROOT)}"
export GOPATH="${GOPATH:-$(go env GOPATH)}"
_go_pathmunge_wrap "${GOPATH}:${GOROOT}"
