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

BACKUP_FILE=$CONFIG_FILE.bak

if [ -e $HOME/$BACKUP_FILE ]; then
    echo "Backup file already exists. Make sure to backup your .bashrc before running this installation." >&2
    while true
    do
        read -e -n 1 -r -p "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$BACKUP_FILE) [y/N] " RESP
        case $RESP in
        [yY])
            break
            ;;
        [nN]|"")
            echo -e "\033[91mInstallation aborted. Please come back soon!\033[m"
            exit 1
            ;;
        *)
            echo -e "\033[91mPlease choose y or n.\033[m"
            ;;
        esac
    done
fi

test -w $HOME/$CONFIG_FILE &&
  cp -a $HOME/$CONFIG_FILE $HOME/$CONFIG_FILE.bak &&
  echo "Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak"

cp $HOME/.bash_it/template/bash_profile.template.bash $HOME/$CONFIG_FILE

echo "Copied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it"

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
  [ -d "$BASH_IT/$file_type/enabled" ] || mkdir "$BASH_IT/$file_type/enabled"
  for path in `ls $BASH_IT/${file_type}/available/[^_]*`
  do
    file_name=$(basename "$path")
    while true
    do
      read -e -n 1 -p "Would you like to enable the ${file_name%%.*} $file_type? [y/N] " RESP
      case $RESP in
      [yY])
        ln -s "../available/${file_name}" "$BASH_IT/$file_type/enabled"
        break
        ;;
      [nN]|"")
        break
        ;;
      *)
        echo -e "\033[91mPlease choose y or n.\033[m"
        ;;
      esac
    done
  done
}

if [[ "$1" == "--none" ]]
then
  echo "Not enabling any aliases, plugins or completions"
elif [[ "$1" == "--all" ]]
then
  echo "Enabling all aliases, plugins and completions."
  load_all aliases
  load_all plugins
  load_all completion
else
  while true
  do
    read -e -n 1 -p "Do you use Jekyll? (If you don't know what Jekyll is, answer 'n') [y/N] " RESP
    case $RESP in
      [yY])
        cp $HOME/.bash_it/template/jekyllconfig.template.bash $HOME/.jekyllconfig
        echo "Copied the template .jekyllconfig into your home directory. Edit this file to customize bash-it for using the Jekyll plugins"
        break
        ;;
      [nN]|"")
        break
        ;;
      *)
        echo -e "\033[91mPlease choose y or n.\033[m"
        ;;
    esac
  done

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
echo -e "\033[0;32mInstallation finished successfully! Enjoy bash-it!\033[0m"
fi
