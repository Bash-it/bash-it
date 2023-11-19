function prompt_command() {
  PS1='$(if [ $? -eq 0 ]; then echo -e "\[\033[42m\] \[\033[0m\]"; else echo -e "\[\033[41m\] \[\033[0m\]"; fi) \[\033[1;32m\]$(if [ $(jobs | wc -l) -gt 0 ]; then echo -n "\j "; fi)\[\033[1;36m\]\u\[\033[0m\] \[\033[1;33m\]\w\[\033[0m\] \[\033[1;34m\]$(if [ $(date +%H) -ge 6 -a $(date +%H) -lt 18 ]; then echo -n "☀️"; else echo -n "🌙"; fi)\[\033[0m\] '
}

safe_append_prompt_command prompt_command
