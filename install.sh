#!/usr/bin/env bash
BASH_IT="$HOME/.bash_it"

cp $HOME/.bash_profile $HOME/.bash_profile.bak

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
  ln -s $BASH_IT/${file_type}/available/* "${BASH_IT}/${file_type}/enabled"
}

function load_some() {
    file_type=$1
    for file in `ls $BASH_IT/${file_type}/available`
    do
      if [ ! -d "$BASH_IT/$file_type/enabled" ]
      then
        mkdir "$BASH_IT/$file_type/enabled"
      fi
      while true
      do
        read -p "Would you like to enable the ${file%.*.*} $file_type? [Y/N] " RESP
        case $RESP in
        [yY])
          ln -s "$BASH_IT/$file_type/available/$file" "$BASH_IT/$file_type/enabled"
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
