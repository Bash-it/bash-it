# shellcheck shell=bash
# shellcheck disable=SC2016
cite about-plugin
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump). Add `export JUMP_OPTS=("--bind=z")` to change keybinding'
url "https://github.com/gsamokovarov/jump"

function __init_jump() {
	if _command_exists jump; then
		eval "$(jump shell bash "${JUMP_OPTS[@]}")"
	fi
}

__init_jump
