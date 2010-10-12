prompt_setter() {
	if [[ $? -eq 0 ]]; then
		PS1="\W "
	else
		PS1="${red}\W ${reset_color}"
	fi
}

PROMPT_COMMAND=prompt_setter
