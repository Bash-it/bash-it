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

if [ -e "$HOME/$BACKUP_FILE" ]; then
    echo -e "\033[0;33mBackup file already exists. Make sure to backup your .bashrc before running this installation.\033[0m" >&2
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

test -w "$HOME/$CONFIG_FILE" &&
  cp -a "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak" &&
  echo -e "\033[0;32mYour original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak\033[0m"

cp "$HOME/.bash_it/template/bash_profile.template.bash" "$HOME/$CONFIG_FILE"

echo -e "\033[0;32mCopied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it\033[0m"

function load_one() {
  file_type=$1
  file_to_enable=$2
  [ ! -d "$BASH_IT/$file_type/enabled" ] && mkdir "$BASH_IT/${file_type}/enabled"

  dest="${BASH_IT}/${file_type}/enabled/${file_to_enable}"
  if [ ! -e "${dest}" ]; then
      ln -s "../available/${file_to_enable}" "${dest}"
  else
      echo "File ${dest} exists, skipping"
  fi
}

echo ""
echo "Enabling sane defaults"
load_one completion bash-it.completion.bash

echo ""
echo -e "\033[0;32mInstallation finished successfully! Enjoy bash-it!\033[0m"
echo -e "\033[0;32mTo start using it, open a new tab or 'source "$HOME/$CONFIG_FILE"'.\033[0m"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  bash-it show aliases"
echo "  bash-it show completions"
echo "  bash-it show plugins"
echo ""
echo "To avoid issues and to keep your shell lean, please enable only features you really want to use."
echo "Enabling everything can lead to issues."
