#!/bin/bash
#
# -binaryanomaly

cite 'about-alias'
about-alias 'kubectl aliases'

# set apt aliases
function _set_pkg_aliases()
{
	if [ -x $(which kubectl) ]; then
		alias kc='kubectl'
		alias kcgp='kubectl get pods'
    alias kcgd='kubectl get deployments'
    alias kcgn='kubectl get nodes'
    alias kcdp='kubectl describe pod'
    alias kcdd='kubectl describe deployment'
    alias kcdn='kubectl describe node'
    alias kcgpan='kubectl get pods --all-namespaces'
    alias kcgdan='kubectl get deployments --all-namespaces'
    alias kcnetshoot='kubectl run --generator=run-pod/v1 netshoot-$(uuidgen | tr A-Z a-z | sed 's/-//g') --rm -i --tty --image nicolaka/netshoot -- /bin/bash'
	fi
}

_set_pkg_aliases
