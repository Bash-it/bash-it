cite about-plugin
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump). Add `export JUMP_OPTS=("--bind=z")` to change keybinding'

__init_jump() {
  command -v jump &> /dev/null || return
  eval "$(jump shell bash "${JUMP_OPTS[@]}")"
}

__init_jump
