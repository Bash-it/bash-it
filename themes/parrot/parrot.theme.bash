# git branch parser
function parse_git_branch() {
	echo -e "\[\033[1;34m\]$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')\[\033[0m\]"
}

function parse_git_branch_no_color() {
	echo -e "$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/')"
}

function prompt() {
	# If not running interactively, don't do anything
	[[ $- != *i* ]] && return

	local force_color_prompt=yes

	if [ -n "$force_color_prompt" ]; then
		if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
			# We have color support; assume it's compliant with Ecma-48
			# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
			# a case would tend to support setf rather than setaf.)
			local color_prompt=yes
		else
			local color_prompt=
		fi
	fi

	if [ "$color_prompt" = yes ]; then
		PS1="\[\033[0;31m\]\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[0;31m\]\342\234\227\[\033[0;37m\]]\342\224\200\")[$(if [[ ${EUID} == 0 ]]; then echo '\[\033[01;31m\]root\[\033[01;33m\]@\[\033[01;96m\]\h'; else echo '\[\033[0;39m\]\u\[\033[01;33m\]@\[\033[01;96m\]\h'; fi)\[\033[0;31m\]]\342\224\200[\[\033[0;32m\]\w\[\033[0;31m\]]\n\[\033[0;31m\]\342\224\224\342\224\200\342\224\200\342\225\274 \[\033[0m\]\[\e[01;33m\]$(parse_git_branch) $\[\e[0m\] "

	else
		PS1='┌──[\u@\h]─[\w]\n└──╼ $(parse_git_branch_no_color) $ '
	fi
}

safe_append_prompt_command prompt
