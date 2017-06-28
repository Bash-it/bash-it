# Load after the system completion to make sure that the fzf completions are working
# BASH_IT_LOAD_PRIORITY: 375

cite about-plugin
about-plugin 'load fzf, if you are using it'

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

fe() {
  about "Open the selected file in the default editor"
  group "fzf"
  param "1: Search term"
  example "fe foo"

  local IFS=$'\n'
  local files
  files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

fd() {
  about "cd to the selected directory"
  group "fzf"
  param "1: Directory to browse, or . if omitted"
  example "fd aliases"

  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune \
                  -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

vf() {
  about "Use fasd to search the file to open in vim"
  group "fzf"
  param "1: Search term for fasd"
  example "vf xml"

  local file
  file="$(fasd -Rfl "$1" | fzf -1 -0 --no-sort +m)" && vi "${file}" || return 1
}
