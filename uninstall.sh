#!/usr/bin/env bash
if [ -z "$BASH_IT" ];
then
  BASH_IT="$HOME/.bash_it"
fi

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

BACKUP_FILE=$CONFIG_FILE.bak

if [ ! -e "$HOME/$BACKUP_FILE" ]; then
  echo -e "\033[0;33mBackup file "$HOME/$BACKUP_FILE" not found.\033[0m" >&2

  test -w "$HOME/$CONFIG_FILE" &&
    mv "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.uninstall" &&
    echo -e "\033[0;32mMoved your $HOME/$CONFIG_FILE to $HOME/$CONFIG_FILE.uninstall.\033[0m"
else
  test -w "$HOME/$BACKUP_FILE" &&
    cp -a "$HOME/$BACKUP_FILE" "$HOME/$CONFIG_FILE" &&
    rm "$HOME/$BACKUP_FILE" &&
    echo -e "\033[0;32mYour original $CONFIG_FILE has been restored.\033[0m"
fi

echo ""
echo -e "\033[0;32mUninstallation finished successfully! Sorry to see you go!\033[0m"
echo ""
echo "Final steps to complete the uninstallation:"
echo "  -> Remove the $BASH_IT folder"
echo "  -> Open a new shell/tab/terminal"
