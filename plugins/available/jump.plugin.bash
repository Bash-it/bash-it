# shellcheck shell=bash
# shellcheck disable=SC2016
about-plugin 'initialize jump (see https://github.com/gsamokovarov/jump). Add `export JUMP_OPTS=("--bind=z")` to change keybinding'

function _bash-it-component-plugin-callback-on-init-jump() {
	if _command_exists jump; then
		source < <(jump shell bash "${JUMP_OPTS[@]:-}")
	fi
}

_bash-it-component-plugin-callback-on-init-jump
