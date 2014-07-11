cite about-plugin
about-plugin 'sshagent helper functions'

function sshagent() {
	local op=$1
	case $op in
	on)
		if [ -z "$SSH_AGENT_ENV" ]; then
			export SSH_AGENT_ENV=${HOME}/.ssh/agent_env
		fi
		if [ ! -d "${HOME}/.ssh" ]; then
			mkdir -p "${HOME}/.ssh"
			restorecon -rv "${HOME}/.ssh"
		fi

		if [ -r ${SSH_AGENT_ENV} ]; then
			## do not trust SSH_AGENT_PID
			agent_pid=$( cat ${SSH_AGENT_ENV} | tail -1 | cut -d' ' -f4 | cut -d';' -f1 )
			ps --pid ${agent_pid} -opid= &> /dev/null
			if [ $? -ne 0 ]; then
				echo "There's a dead ssh-agent at the landing..."
				rm -f ${SSH_AGENT_ENV}
			fi
		fi

		if [ ! -r $SSH_AGENT_ENV ]; then
		    ssh-agent > ${SSH_AGENT_ENV}
		fi

		. ${SSH_AGENT_ENV}
	;;
	off)
		if [ -r ${SSH_AGENT_ENV} ]; then
			## ensure the file indeed points to a really running agend:
			agent_pid=$( cat ${SSH_AGENT_ENV} | tail -1 | cut -d' ' -f4 | cut -d';' -f1 )
			ps auxw | grep ${agent_pid} | grep -v grep > /dev/null
			if [ $? -eq 0 ]; then
				echo "Killing ssh-agent ..."
				kill -9 ${agent_pid}
				rm -f ${SSH_AGENT_ENV}
			fi
		fi

	;;
	*)
	;;
	esac

}

sshagent on
