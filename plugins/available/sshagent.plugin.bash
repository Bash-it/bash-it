# shellcheck shell=bash
cite about-plugin
about-plugin 'sshagent helper functions'

function _get_sshagent_pid_from_env_file() {
	local env_file="${1}"
	[[ -r "${env_file}" ]] || {
		echo ""
		return
	}
	tail -1 "${env_file}" \
		| cut -d' ' -f4 \
		| cut -d';' -f1
}

function _get_process_status_field() {
	# uses /proc filesystem
	local \
		pid \
		status_file \
		field
	pid="${1}"
	field="${2}"
	status_file="/proc/${pid}/status"
	if ! { [[ -d "${status_file%/*}" ]] \
		&& [[ -r "${status_file}" ]]; }; then
		echo ""
		return
	fi
	grep "${field}:" "${status_file}" \
		| cut -d':' -f2 \
		| sed -e 's/[[:space:]]\+//g' \
		| cut -d'(' -f1
}

function _is_item_in_list() {
	local item
	for item in "${@:1}"; do
		if [[ "${item}" == "${1}" ]]; then
			return 1
		fi
	done
	return 0
}

function _is_proc_alive_at_pid() {
	local \
		pid \
		expected_name \
		actual_name \
		actual_state
	pid="${1?}"
	expected_name="ssh-agent"
	# we want to exclude: X (killed), T (traced), Z (zombie)
	actual_name=$(_get_process_status_field "${pid}" "Name")
	[[ "${expected_name}" == "${actual_name}" ]] || return 1
	actual_state=$(_get_process_status_field "${pid}" "State")
	if _is_item_in_list "${actual_state}" "X" "T" "Z"; then
		return 1
	fi
	return 0
}

function _ensure_valid_sshagent_env() {
	local \
		agent_pid \
		tmp_res

	mkdir -p "${HOME}/.ssh"
	type restorecon &> /dev/null
	tmp_res="$?"

	if [[ "${tmp_res}" -eq 0 ]]; then
		restorecon -rv "${HOME}/.ssh"
	fi

	# no env file -> shoot a new agent
	if ! [[ -r "${SSH_AGENT_ENV}" ]]; then
		ssh-agent > "${SSH_AGENT_ENV}"
		return
	fi

	## do not trust pre-existing SSH_AGENT_ENV
	agent_pid=$(_get_sshagent_pid_from_env_file "${SSH_AGENT_ENV}")
	if [[ -z "${agent_pid}" ]]; then
		# no pid detected -> shoot a new agent
		ssh-agent > "${SSH_AGENT_ENV}"
		return
	fi

	## do not trust SSH_AGENT_PID
	if _is_proc_alive_at_pid "${agent_pid}"; then
		return
	fi

	ssh-agent > "${SSH_AGENT_ENV}"
	return
}

function _ensure_sshagent_dead() {
	[[ -r "${SSH_AGENT_ENV}" ]] \
		|| return ## no agent file - no problems
	## ensure the file indeed points to a really running agent:
	agent_pid=$(
		_get_sshagent_pid_from_env_file \
			"${SSH_AGENT_ENV}"
	)

	[[ -n "${agent_pid}" ]] \
		|| return # no pid - no problem

	_is_proc_alive_at_pid "${agent_pid}" \
		|| return # process is not alive - no problem

	echo -e -n "Killing ssh-agent (pid:${agent_pid}) ... "
	kill -9 "${agent_pid}" && echo "DONE" || echo "FAILED"
	rm -f "${SSH_AGENT_ENV}"
}

function sshagent() {
	about 'ensures ssh-agent is up and running'
	param '1: on|off '
	example '$ sshagent on'
	group 'ssh'
	[[ -z "${SSH_AGENT_ENV}" ]] \
		&& export SSH_AGENT_ENV="${HOME}/.ssh/agent_env.${HOSTNAME}"

	case "${1}" in
		on)
			_ensure_valid_sshagent_env
			# shellcheck disable=SC1090
			source "${SSH_AGENT_ENV}" > /dev/null
			;;
		off)
			_ensure_sshagent_dead
			;;
		*) ;;
	esac
}

sshagent on
