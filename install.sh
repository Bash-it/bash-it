#!/usr/bin/env bash
shopt -qs nocaseglob
# users can define their own home for bash-it to live in with their dotfiles
bash_it=${bash_it-$HOME/.bash_it}
bash_prof=$HOME/.bash_profile

prep() {
  # use this to shorten some commandlines
  local templates=$bash_it/template resp
  # if symlink or doesn't exist, pointless operation
  if [[ -e $bash_prof && ! -L $bash_prof ]]; then
    cp "$bash_prof" "$bash_prof.bak"
    echo "$bash_prof has been backed up to $bash_prof.bak"
  fi

  # why is the name so long? it's already in /template/ directory
  cp "$templates/bash_profile" "$bash_prof"

  echo "Copied $templates/bash_profile into $bash_prof."
  echo "Edit this file to customize bash-it"

  # why do we care about a static blog framework for our custom shell?
  # this seems really short-sighted -- why is jekyll special?
  while :; do
    # -N1 doesn't wait for user to press enter
    read -N1 -p "Do you use Jekyll? (If you don't know what Jekyll is, answer 'n') [y/n] " resp

    case $resp in
      y)
	cp "$templates/jekyllconfig" "$HOME/.jekyllconfig"
	echo "Copied the template .jekyllconfig into your home directory."
	echo "Edit this file to customize bash-it for using the Jekyll plugins"
	break ;;
      n) break ;;
      *) echo "Please enter y or n" ;;
    esac
  done
}

list() {
  declare -a apply; local extension resp
  PS3="Choose which options you would like to enable. (0 to continue) "
  printf %s\\n "Some of these may make bash slower to start up (especially completions)."
  select extension in aliases plugins completions; do
    (( $extension )) || break
    apply+=($extension)
  done
  if (( ! ${#apply[@]} )); then
    while :; do
      read -N1 -p "No options specified. Would you like to retry? [y/n] " resp
      case $resp in
	y) load ;;
	n) break ;;
	*) echo "Please choose y or n." ;;
      esac
    done
  fi
}

install() {
  local avail enabled
  for h; do
    avail=$bash_it/$h/available
    enabled=${avail%*/}/enabled
    mkdir -p "$enabled"
    # this glob eliminates the [[ ${filename:0:1} = _ ]] test
    for src in "$avail/"[^_]*; do
      filename=${src##*/}
      dest=$enabled/$filename
      ln -s "$src" "$dest"
    done
  done
}

prep
list
install "${apply[@]}"
