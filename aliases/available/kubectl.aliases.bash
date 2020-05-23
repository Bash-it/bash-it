#!/bin/bash
#
# -binaryanomaly

cite 'about-alias'
about-alias 'kubectl aliases'

function _set_pkg_aliases()
{
  if _command_exists kubectl; then
    alias kc='kubectl'
    alias kcgp='kubectl get pods'
    alias kcgd='kubectl get deployments'
    alias kcgn='kubectl get nodes'
    alias kcdp='kubectl describe pod'
    alias kcdd='kubectl describe deployment'
    alias kcdn='kubectl describe node'
    alias kcgpan='kubectl get pods --all-namespaces'
    alias kcgdan='kubectl get deployments --all-namespaces'
    # launches a disposable netshoot pod in the k8s cluster
    alias kcnetshoot='kubectl run --generator=run-pod/v1 netshoot-$(date +%s) --rm -i --tty --image nicolaka/netshoot -- /bin/bash'
  fi
}

_set_pkg_aliases
