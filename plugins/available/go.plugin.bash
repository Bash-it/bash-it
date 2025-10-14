# shellcheck shell=bash
cite about-plugin
about-plugin 'go environment variables & path configuration'
url "https://golang.org/"

# Load after basher and goenv
# BASH_IT_LOAD_PRIORITY: 270

# Test `go version` because goenv creates shim scripts that will be found in PATH
# but do not always resolve to a working install.
{ _command_exists go && go version &> /dev/null; } || return 0

export GOROOT="${GOROOT:-$(go env GOROOT)}"
export GOPATH="${GOPATH:-$(go env GOPATH)}"

# $GOPATH/bin is the default location for binaries. Because GOPATH accepts a list of paths and each
# might be managed differently, we add each path's /bin folder to PATH using pathmunge,
# while preserving ordering.
# e.g. GOPATH=foo:bar  ->  PATH=foo/bin:bar/bin
_bash-it-gopath-pathmunge() {
	_about 'Ensures paths in GOPATH are added to PATH using pathmunge, with /bin appended'
	_group 'go'
	if [[ -z "${GOPATH:-}" ]]; then
		_log_warning 'GOPATH empty'
		return 1
	fi
	local paths apath
	IFS=: read -r -a paths <<< "$GOPATH"
	for apath in "${paths[@]}"; do
		pathmunge "${apath}/bin" || true
	done
}
_bash-it-gopath-pathmunge
