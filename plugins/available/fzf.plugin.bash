# shellcheck shell=bash
# Load after the system completion to make sure that the fzf completions are working
# BASH_IT_LOAD_PRIORITY: 375

cite about-plugin
about-plugin 'load fzf, if you are using it'

if [ -r ~/.fzf.bash ]; then
	# shellcheck disable=SC1090
	source ~/.fzf.bash
elif [ -r "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ]; then
	# shellcheck disable=SC1091
	source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
fi

# No need to continue if the command is not present
_command_exists fzf || return

if [ -z ${FZF_DEFAULT_COMMAND+x} ] && _command_exists fd; then
	export FZF_DEFAULT_COMMAND='fd --type f'
fi

fe() {
	about "Open the selected file in the default editor"
	group "fzf"
	param "1: Search term"
	example "fe foo"

	local IFS=$'\n' line
	local files=()
	while IFS='' read -r line; do files+=("$line"); done < <(fzf-tmux --query="$1" --multi --select-1 --exit-0)
	[[ -n "${files[0]}" ]] && ${EDITOR:-vim} "${files[@]}"
}

fcd() {
	about "cd to the selected directory"
	group "fzf"
	param "1: Directory to browse, or . if omitted"
	example "fcd aliases"

	local dir
	dir=$(find "${1:-.}" -path '*/\.*' -prune \
		-o -type d -print 2> /dev/null | fzf +m) \
		&& cd "$dir" || return 1
}
