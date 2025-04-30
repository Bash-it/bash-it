# shellcheck shell=bash
about-alias 'kubectl aliases'

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
	alias kcnetshoot='kubectl run netshoot-$(date +%s) --rm -i --tty --image nicolaka/netshoot -- /bin/bash'
fi
