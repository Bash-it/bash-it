# shellcheck shell=bash
about-plugin 'go environment variables & path configuration'

# Load after basher and goenv
# BASH_IT_LOAD_PRIORITY: 270

# Test `go version` because goenv creates shim scripts that will be found in PATH
# but do not always resolve to a working install.
if ! _binary_exists go || ! go version &> /dev/null; then
	_log_warning "Unable to locate a working 'go'."
	return 1
fi

: "${GOROOT:=$(go env GOROOT)}"
: "${GOPATH:=$(go env GOPATH)}"
export GOROOT GOPATH

# $GOPATH/bin is the default location for binaries. Because GOPATH accepts a list of paths and each
# might be managed differently, we add each path's /bin folder to PATH using pathmunge,
# while preserving ordering.
# e.g. GOPATH=foo:bar  ->  PATH=foo/bin:bar/bin
function _bash-it-component-plugin-callback-on-init-go() {
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
_bash-it-component-plugin-callback-on-init-go
