#!/usr/bin/env bash
BASH_IT="$HOME/.bash_it"

default_aliases_list="bundler general git maven vim"
default_plugins_list="base dirs extract git java python ruby rvm sshagent ssh tmux virtualenv"
default_completion_list="bash-it defaults fabric gem git git_flow maven pip rake ssh tmux"

test -w $HOME/.bash_profile &&
  cp $HOME/.bash_profile $HOME/.bash_profile.bak &&
  echo "Your original .bash_profile has been backed up to .bash_profile.bak"

cp $HOME/.bash_it/template/bash_profile.template.bash $HOME/.bash_profile

echo "Copied the template .bash_profile into ~/.bash_profile, edit this file to customize bash-it"

while true
do
  read -p "Do you use Jekyll? (If you don't know what Jekyll is, answer 'n') [Y/N] " RESP

  case $RESP
    in
    [yY])
      cp $HOME/.bash_it/template/jekyllconfig.template.bash $HOME/.jekyllconfig
      echo "Copied the template .jekyllconfig into your home directory. Edit this file to customize bash-it for using the Jekyll plugins"
      break
      ;;
    [nN])
      break
      ;;
    *)
      echo "Please enter Y or N"
  esac
done

function load_all() {
  file_type=$1
  [ ! -d "$BASH_IT/$file_type/enabled" ] && mkdir "$BASH_IT/${file_type}/enabled"
  for src in $BASH_IT/${file_type}/available/*; do
      filename="$(basename ${src})"
      [ ${filename:0:1} = "_" ] && continue
      dest="${BASH_IT}/${file_type}/enabled/${filename}"
      if [ ! -e "${dest}" ]; then
          ln -s "../available/${filename}" "${dest}"
      else
          echo "File ${dest} exists, skipping"
      fi
  done
}

function load_list() {
  local file_type=$1
  shift
  local src_list=$*
  [ ! -d "$BASH_IT/$file_type/enabled" ] && mkdir "$BASH_IT/${file_type}/enabled"
  for src in ${src_list}; do
      full_filename="$(ls ${BASH_IT}/${file_type}/available/${src}.*.bash)"
      if [ ! -e "${full_filename}" ]; then
          echo "File ${full_filename} missing, skipping"
          continue
      fi
      filename="$(basename ${full_filename})"
      [ ${filename:0:1} = "_" ] && continue
      dest="${BASH_IT}/${file_type}/enabled/${filename}"
      if [ -e "${dest}" ]; then
          echo "File ${dest} exists, skipping"
          continue
      fi
      ln -s "../available/${filename}" "${dest}"
  done
}

function load_some() {
    file_type=$1
    for path in `ls $BASH_IT/${file_type}/available/[^_]*`
    do
      if [ ! -d "$BASH_IT/$file_type/enabled" ]
      then
        mkdir "$BASH_IT/$file_type/enabled"
      fi
      file_name=$(basename "$path")
      while true
      do
        read -p "Would you like to enable the ${file_name%%.*} $file_type? [Y/N] " RESP
        case $RESP in
        [yY])
          ln -s "../available/${file_name}" "$BASH_IT/$file_type/enabled"
          break
          ;;
        [nN])
          break
          ;;
        *)
          echo "Please choose y or n."
          ;;
        esac
      done
    done
}

for type in "aliases" "plugins" "completion"
do
  while true
  do
    read -p "Would you like to enable all, some, or no $type? Some of these may make bash slower to start up (especially completion). (all/some/list/none) " RESP
    case $RESP
    in
    some)
      load_some $type
      break
      ;;
    all)
      load_all $type
      break
      ;;
    list)
      default_list_name="default_${type}_list"
      eval default_list=\$$default_list_name
      available_list=""
      for s in $BASH_IT/${type}/available/*.bash
      do
        available_list="${available_list} $( basename ${s} | cut -d. -f1 )"
      done
      echo "Enter space separated list of $type you want to have enabled."
      echo "Avalable: ${available_list}"
      echo "Default: ${default_list}"
      read -p "Your choice [press ENTER to accept default]:" RESP
      [ -z "${RESP}" ] && items_list=${default_list}
      load_list $type $items_list
      break
      ;;
    none)
      break
      ;;
    *)
      echo "Unknown choice. Please enter some, all, or none"
      continue
      ;;
    esac
  done
done
