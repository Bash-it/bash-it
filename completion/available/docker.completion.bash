# shellcheck shell=bash
cite "about-completion"
about-completion "docker completion"

# Make sure docker is installed
_command_exists docker || return

# Don't handle completion if it's already managed
_completion_exists docker && return

_docker_bash_completion_paths=(
	# MacOS
	'/Applications/Docker.app/Contents/Resources/etc/docker.bash-completion'
	# Linux
	'/usr/share/bash-completion/completions/docker'
)

for fn in "${_docker_bash_completion_paths[@]}"; do
	if [ -r "$fn" ]; then
		# shellcheck disable=SC1090
		source "$fn"
		break
	fi
done
