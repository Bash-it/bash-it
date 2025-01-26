# shellcheck shell=bash
cite about-plugin
about-plugin 'ssh helper functions'

function add_ssh() {
	about 'add entry to ssh config'
	param '1: host'
	param '2: hostname'
	param '3: user'
	group 'ssh'

	[[ $# -ne 3 ]] && echo "add_ssh host hostname user" && return 1
	[[ ! -d ~/.ssh ]] && mkdir -m 700 ~/.ssh
	[[ ! -e ~/.ssh/config ]] && touch ~/.ssh/config && chmod 600 ~/.ssh/config
	echo -en "\n\nHost $1\n  HostName $2\n  User $3\n  ServerAliveInterval 30\n  ServerAliveCountMax 120" >> ~/.ssh/config
}

function sshlist() {
	about 'list hosts defined in ssh config'
	group 'ssh'

	awk '$1 ~ /Host$/ {for (i=2; i<=NF; i++) print $i}' ~/.ssh/config
}

function ssh-add-all() {
	about 'add all ssh private keys to agent'
	group 'ssh'

	grep -slR "PRIVATE" ~/.ssh | xargs ssh-add
}
