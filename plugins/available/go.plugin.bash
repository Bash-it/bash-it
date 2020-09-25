cite about-plugin
about-plugin 'go environment variables & path configuration'

# Load after goenv
# BASH_IT_LOAD_PRIORITY: 285

{ _command_exists go && go version &>/dev/null ; } || return 0

# Wrapper function to iterate, in reverse, through a list of colon
# separated paths to support multiple entries in GOPATH.
function _go_pathmunge_wrap() {
  IFS=':' local -a 'a=($1)'
  local i=${#a[@]}
  while [[ $i -gt 0 ]] ; do
    i=$(( i - 1 ))
    pathmunge "${a[i]}/bin"
  done
}

export GOROOT="${GOROOT:-$(go env GOROOT)}"
export GOPATH="${GOPATH:-$(go env GOPATH)}"
_go_pathmunge_wrap "${GOPATH}:${GOROOT}"
