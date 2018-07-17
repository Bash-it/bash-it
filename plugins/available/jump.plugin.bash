cite about-plugin
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump)'

__init_jump() {
  command -v jump &> /dev/null
  if [ $? -eq 1 ]; then
    echo -e "You must install jump before you can use this plugin"
    echo -e "See: https://github.com/gsamokovarov/jump"
  else
    eval "$(jump shell --bind=z)"
  fi
}

__init_jump
