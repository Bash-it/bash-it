# shellcheck shell=bash
if _command_exists awless; then
	# shellcheck disable=SC1090
	source <(awless completion bash)
fi
