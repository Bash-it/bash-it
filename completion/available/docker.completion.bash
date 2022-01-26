# shellcheck shell=bash
about-completion "docker completion"

# Make sure docker is installed
_bash-it-completion-helper-necessary docker || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient docker || return

_docker_bash_completion_paths=(
	# MacOS App
	'/Applications/Docker.app/Contents/Resources/etc/docker.bash-completion'
	# Command Line
	'/usr/share/bash-completion/completions/docker'
)

# Load the first completion file found
_docker_bash_completion_found=false
for _comp_path in "${_docker_bash_completion_paths[@]}"; do
	if [[ -r "$_comp_path" ]]; then
		_docker_bash_completion_found=true
		# shellcheck disable=SC1090
		source "$_comp_path"
		break
	fi
done

# Cleanup
if [[ "${_docker_bash_completion_found}" == false ]]; then
	_log_warning "no completion files found - please try enabling the 'system' completion instead."
fi
unset "${!_docker_bash_completion@}"
