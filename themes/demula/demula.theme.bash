# ------------------------------------------------------------------ COLOR CONF
D_DEFAULT_COLOR='${gray}'
D_USER_COLOR='${purple}'
D_SUPERUSER_COLOR='${red}'
D_MACHINE_COLOR='${cyan}'
D_DIR_COLOR='${green}'
D_SCM_COLOR='${yellow}'
D_BRANCH_COLOR='${yellow}'
D_CHANGES_COLOR='${white}'
D_CMDFAIL_COLOR='${red}'

case $TERM in
	xterm*)
	TITLEBAR="\[\033]0;\w\007\]"
	;;
	*)
	TITLEBAR=""
	;;
esac

PS3=">> "

is_vim_shell() {
	if [ ! -z "$VIMRUNTIME" ]
	then
		echo "on ${cyan}vim shell${white} "
	fi
}

mitsuhikos_lastcommandfailed() {
  code=$?
  if [ $code != 0 ]; then
    echo -n '\[${white}\]exited \[${red}\]'
    echo -n $code
    echo -n '\[${white}\] '
  fi
}

D_VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt
D_VCPROMPT_FORMAT="on ${D_SCM_COLOR}%s${white}:${D_BRANCH_COLOR}%b %r ${D_CHANGES_COLOR}%m%u ${white}"
demula_vcprompt() {
        $D_VCPROMPT_EXECUTABLE -f "$D_VCPROMPT_FORMAT"	
}

prompt() {
	# Yes, the indenting on these is weird, but it has to be like
	# this otherwise it won't display properly.

	PS1="\n${TITLEBAR}\[${D_USER_COLOR}\]\u ${white}\
at \[${D_MACHINE_COLOR}\]\h ${white}\
in \[${D_DIR_COLOR}\]\w ${white}\
$(mitsuhikos_lastcommandfailed)\
$(demula_vcprompt)\
$(is_vim_shell)
$ ${normal}"
}

PS2="$ "

PROMPT_COMMAND=prompt
