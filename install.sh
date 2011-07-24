#!/usr/bin/env bash
BASH="$HOME/.bash_it"

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
  for file_type in "aliases" "completion" "plugins"
  do
    [ ! -d "$BASH/$file_type/enabled" ] && mkdir "$BASH/${file_type}/enabled"
    ln -s $BASH/${file_type}/available/* "${BASH}/${file_type}/enabled"
  done
}

function load_some() {
  for file_type in "aliases" "completion" "plugins"
  do
    for file in `ls $BASH/${file_type}/available`
    do
      if [ ! -d "$BASH/$file_type/enabled" ]
      then
        mkdir "$BASH/$file_type/enabled"
      fi
      while true
      do
        read -p "Would you like to enable the ${file%.*.*} $file_type? [Y/N] " RESP
        case $RESP in
        [yY])
          ln -s "$BASH/$file_type/available/$file" "$BASH/$file_type/enabled"
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
  done
}

while true
do
  read -p "Would you like to enable all, some, or no plugins/aliases/tab-completion plugins? Some of these may make bash slower to start up. (all/some/none) " RESP
  case $RESP
  in
  some)
    load_some
    break
    ;;
  all)
    load_all
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
