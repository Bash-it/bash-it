if [[ $BASH_PREVIEW ]];
then
  unset BASH_PREVIEW #Prevent infinite looping
  echo "

  Previewing Bash-it Themes

  "

  THEMES="$BASH_IT/themes/*/*.theme.bash"
  for theme in $THEMES
  do
    BASH_IT_THEME=$(echo $theme | sed "s/\//\n/g" | tail -1 | sed "s/.theme.bash//")
    echo "
    $BASH_IT_THEME"
    echo "" | bash --init-file $BASH_IT/bash_it.sh -i
  done
fi
