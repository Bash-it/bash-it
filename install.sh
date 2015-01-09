#!/usr/bin/env bash
BASH_IT="$HOME/.bash_it"

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

test -w $HOME/$CONFIG_FILE &&
  cp $HOME/$CONFIG_FILE $HOME/$CONFIG_FILE.bak &&
  echo "Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak"

cp $HOME/.bash_it/template/bash_profile.template.bash $HOME/$CONFIG_FILE

echo "Copied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it"

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
    read -p "Would you like to enable all, some, or no $type? Some of these may make bash slower to start up (especially completion). (all/some/none) " RESP
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
