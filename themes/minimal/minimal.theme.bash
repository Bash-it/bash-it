prompt_setter() {
	if [[ $? -eq 0 ]]; then
		if [ ! $VIMRUNTIME = "" ]
		then
			PS1="{vim} \W "
		else
			PS1="\W "
		fi
	else
		if [ ! $VIMRUNTIME = "" ]
		then
			PS1="{vim} ${bold_red}\W ${normal}"
		else
			PS1="${bold_red}\W ${normal}"
		fi
	fi
}

PROMPT_COMMAND=prompt_setter

export PS3=">> "
