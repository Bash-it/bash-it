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
	fi
}

_set_pkg_aliases
