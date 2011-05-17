prompt_setter() {
  PS1="${cyan}\W${normal} "
}

PROMPT_COMMAND=prompt_setter

export PS3=">> "
