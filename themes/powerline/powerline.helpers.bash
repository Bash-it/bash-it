# A bunch of Powerline Prompt Helper functions that
# change which compnents are shown, and to what level of detail to
# render the Git/SCM info.

# Minimizing the list of components and showing less Git info can significantly
# speed up your prompt rendering.
#
# For instance, on the most recent MacBook Pro 16 (2020) with 3GHZ CPU it takes 1 second
# to render the `powerline.prompt.git.max()` and powerline.prompt.all

# @description
#    This function returns a shortened
# @see: https://stackoverflow.com/questions/1616678/bash-pwd-shortening
export POWERLINE_SHORT_CWD_WIDTH=40

function cwd.shorten() {
	local begin=""            # The unshortened beginning of the path.
	local shortbegin=""       # The shortened beginning of the path.
	local current=""          # The section of the path we're currently working on.
	local end="${2:-$(pwd)}/" # The unmodified rest of the path.

	if [[ "$end" =~ ${HOME} ]]; then
		INHOME=1
		end="${end#$HOME}" #strip /home/username from start of string
		begin="$HOME"      #start expansion from the right spot
	else
		INHOME=0
	fi

	local end="${end#/}"       # Strip the first /
	local shortenedpath="$end" # The whole path, to check the length.
	local maxlength="${1:-${POWERLINE_SHORT_CWD_WIDTH}}"

	shopt -q nullglob && NGV="-s" || NGV="-u" # Store the value for later.
	shopt -s nullglob                         # Without this, anything that doesn't exist in the filesystem turns into */*/*/...

	while [[ "$end" ]] && ((${#shortenedpath} > maxlength)); do
		current="${end%%/*}" # everything before the first /
		end="${end#*/}"      # everything after the first /

		shortcurstar="$current" # No star if we don't shorten it.

		for ((i = ${#current} - 2; i >= 0; i--)); do
			subcurrent="${current:0:i}"
			matching=("$begin/$subcurrent"*)  # Array of all files that start with $subcurrent.
			((${#matching[*]} != 1)) && break # Stop shortening if more than one file matches.
			shortcurstar="${subcurrent}…"
		done

		#a dvance
		begin="$begin/$current"
		shortbegin="$shortbegin/$shortcurstar"
		shortenedpath="$shortbegin/$end"
	done

	shortenedpath="${shortenedpath%/}" # strip trailing /
	shortenedpath="${shortenedpath#/}" # strip leading /

	if [ $INHOME -eq 1 ]; then
		echo "~/$shortenedpath" #make sure it starts with ~/
	else
		echo "/$shortenedpath" # Make sure it starts with /
	fi

	shopt "$NGV" nullglob # Rerandomize nullglob in case this is being used as a function.
}

# Powerline Prompt Configuration
function powerline.prompt.git.max() {
	export SCM_GIT_SHOW_MINIMAL_INFO=false

	export SCM_GIT_SHOW_COMMIT_COUNT=true
	export SCM_GIT_SHOW_CURRENT_USER=true
	export SCM_GIT_SHOW_DETAILS=true
	export SCM_GIT_SHOW_REMOTE_INFO=true
	export SCM_GIT_SHOW_STASH_INFO=true
}

function powerline.prompt.git.min() {
	export SCM_GIT_SHOW_MINIMAL_INFO=true

	export SCM_GIT_SHOW_CURRENT_USER=false
	export SCM_GIT_SHOW_DETAILS=false
	export SCM_GIT_SHOW_COMMIT_COUNT=false
	export SCM_GIT_SHOW_REMOTE_INFO=false
	export SCM_GIT_SHOW_STASH_INFO=false
}

function powerline.prompt.git.default() {
	export SCM_GIT_SHOW_MINIMAL_INFO=false

	export SCM_GIT_SHOW_CURRENT_USER=true
	export SCM_GIT_SHOW_DETAILS=true
	export SCM_GIT_SHOW_COMMIT_COUNT=false
	export SCM_GIT_SHOW_REMOTE_INFO=false
	export SCM_GIT_SHOW_STASH_INFO=true
}

.powerline.screen-width() {
	local w
	local os=$(uname -s)
	if [[ $os == 'Darwin' ]]; then
		w=$(stty -a 2>/dev/null | grep columns | awk '{print $6}')
	else
		w=$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | sed -E 's/;//g')
	fi
	printf -- "%d" "${w}"
}

# Filter/convert components passed as arguments to the
# correct powerline modules
# @example: powerline.filter-and-print ruby python k8 garbages
# @output:  ruby python_venv k8s_context
function powerline.filter-and-print() {
	local -a components
	components=()
	for c in "$@"; do
		[[ ${c} == "python" ]] && c="python_venv"
		[[ ${c} == "k8" ]] && c="k8s_context"
		local func="__powerline_${c}_prompt"
		type "$func" 2>/dev/null | head -1 | grep -q 'is a function' && components+=("${c}")
	done
	echo "${components[*]}"
}

function powerline.components.bulleted-list() {
	set | grep -E '^__powerline_.*_prompt' | sed 's/__powerline_//g; s/_prompt.*$//g; s/^/    • /g' | sort
}

function powerline.components.array() {
	set | grep -E '^__powerline_.*_prompt' | sed 's/__powerline_//g; s/_prompt.*$//g;' | tr '\n' ' '
	echo
}

function powerline.invalid-arguments() {
	echo -e "${echo_bold_red}ERROR:\n\tPlease pass an argument list of components " \
		"you'd like to\n\tsee in the PROMPT.${echo_normal}\n"
	echo -e "${echo_bold_yellow}\tHere is the list of all currently supported components:\n\t${echo_green}"
	powerline.components.bulleted-list
	echo -e "${echo_normal}"
}

function array.random-sort() {
  local -a randomized

	# shellcheck disable=2207
	randomized=(
		$(
      for c in "$@"; do
        echo "${c}"
      done | sort -R | tr '\n' ' '
		)
	)
	# shellcheck disable=2207
	printf "%s" "${randomized[*]}"
}

# @description You can pass an array of the components either
#              as a single space-separate string, of pass two
#              strings for left/right components.
# @exmples
#    # the first example will invoke powerline-multiline prompt:
#    $ powerline.prompt.choose "cwd ruby go" "battery cpu time"
#
#    # while the second will choose single line.
#    $ powerline.prompt.choose "cwd ruby go node battery"
#
function powerline.prompt.choose() {
	[[ -z "$*" ]] && {
		powerline.invalid-arguments
		echo
		echo "Please note: you can pass the components as a single string,"
		echo "or as two strings, in which case first one becomes left,"
		echo "and the second becomes right component."

		return 1
	}

	local left="$1"
	local rigth="$2"

	if [[ -z ${right} ]]; then
		export BASH_IT_THEME="powerline"
	else
		export BASH_IT_THEME="powerline-multiline"
	fi

	for component_string in "left" "right"; do
		local -a components
		# shellcheck disable=2206
		components=(${!component_string})

		# shellcheck disable=2207
		components=($(powerline.filter-and-print "${components[@]}"))
	done

	[[ -z ${right} ]] && {
		# Single-line Powerline Prompts
		export POWERLINE_PROMPT="${POWERLINE_LEFT_PROMPT}"
	}
}

# usage: powerline.prompt.randomize [ lang [ lang ]... ]
#    eg: powerline.prompt.randomize cwd ruby go node battery
function powerline.prompt.randomize() {
	local -a components
	local -a randomized
	if [[ -z $* ]];  then
		# shellcheck disable=2207
		components=($(powerline.components.array))
	else
		# shellcheck disable=2207
		components=($(powerline.filter-and-print "$@"))
	fi

	local count="${#components[@]}"
	local half="$((count / 2))"
	local even=0
	[[ $((count % 2)) -eq 0 ]] && even=1

	local half_plus_one="$((half + 1))"

	# Single-line Powerline Prompts
	export POWERLINE_PROMPT="${components[*]}"

	# Multiline Powerline Prompts
	export POWERLINE_LEFT_PROMPT="${components[*]:0:${half_plus_one}}"
	if ((even)); then
		export POWERLINE_RIGHT_PROMPT="${components[*]:${half_plus_one}}"
	else
		export POWERLINE_RIGHT_PROMPT="${components[*]:${half_plus_one}}"
	fi
}

function powerline.prompt.show() {
	if [[ $BASH_IT_THEME =~ "multiline" ]]; then
		echo "Left Side:"
    powerline.prompt.echo-prompt  left
		echo "Right Side:"
		powerline.prompt.side right
	else
		powerline.prompt.show-unified
	fi
}

# Print the prompt variable, either left/right or signle
function powerline.prompt.prompt-print() {
  local side="$1"
  local variable="$(powerline.prompt.variable "${side}")"
  eval "echo ${!variable}"
}

# Print the prompt variable, either left/right or signle
function powerline.prompt.variable-name() {
  local side="$1"
  if [[ -z ${side} ]]; then
    echo "POWERLINE_PROMPT"
  else
    echo "POWERLINE_${side^}_PROMPT"
  fi
}

# @description Set left, right or the middle promps itts
function powerline.prompt.set() {
	if [[ $BASH_IT_THEME =~ "multiline" ]]; then
    local side="$1"; shift

    if [[ ${side} == left || ${side} == right ]] ; then
      echo "USAGE: powerline.prompt.side [ left | right ] <component....  >"
      return 1
    fi

    local var="$(powerline.prompt.echo-prompt "${side}")"

    if [[ -z $* ]]; then
      echo "${POWERLINE_PROMPT}"
    else
      export POWERLINE_PROMPT="$(powerline.filter-and-print "$@")"
    fi
  fi
}

function powerline.prompt.right() {
	if [[ -z $* ]]; then
		echo "${POWERLINE_RIGHT_PROMPT}"
	else
		export POWERLINE_RIGHT_PROMPT="$(powerline.filter-and-print "$@")"
	fi
}

function powerline.prompt.left() {
	if [[ -z $* ]]; then
		echo "${POWERLINE_LEFT_PROMPT}"
	else
		export POWERLINE_LEFT_PROMPT="$(powerline.filter-and-print "$@")"
	fi
}

function powerline.prompt.randomize-to() {
	if [[ -z $* ]]; then
		echo "${POWERLINE_PROMPT}"
	else
		export POWERLINE_PROMPT="$(powerline.filter-and-print "$@")"
	fi
}

# @example: powerline.prompt.add-component left ruby
function powerline.prompt.add-component() {
	local side="$1"
	local func
	if [[ -n $1 ]]; then
		func="powerline.prompt.randomize-${side}-to"
		shift
	else
		func="powerline.prompt.randomize-to"
	fi

	${func} $(${func}) "$@"
}

function powerline.prompt.golang() {
	powerline.prompt.add-component left go
}

function powerline.prompt.node() {
	powerline.prompt.add-component left node
}

function powerline.prompt.ruby() {
	powerline.prompt.add-component left ruby
}

function powerline.prompt.python() {
	powerline.prompt.add-component left python_venv
}

## Configure the level of Git Detail
function powerline.prompt.min() {
	export POWERLINE_LEFT_PROMPT="cwd"
	export POWERLINE_RIGHT_PROMPT="clock user_info hostname"
}

function powerline.prompt.all() {
	powerline.prompt
	export POWERLINE_LEFT_PROMPT="scm clock cwd"
	export POWERLINE_RIGHT_PROMPT="user_info hostname battery"
}

function powerline.prompt.default() {
	export POWERLINE_LEFT_PROMPT="scm node ruby go cwd "
	export POWERLINE_RIGHT_PROMPT=" clock user_info hostname battery"
}

function powerline.default() {
	powerline-max
}

function powerline.prompt.alternative-symbols() {
	export SCM_GIT_CHAR=" Ⓖ "
	export USER_INFO_SSH_CHAR="🔐 "
	export PYTHON_VENV_CHAR="ⓟ "
	export CONDA_PYTHON_VENV_CHAR="ⓒⓟ "
	export NODE_CHAR="ⓝ  "
	export RUBY_CHAR="ⓡ  "
	export GO_CHAR="ⓖ  "
	export TERRAFORM_CHAR="ⓣ  "
	export KUBERNETES_CONTEXT_THEME_CHAR="⎈ "
	export AWS_PROFILE_CHAR="«aws» "
	export BATTERY_AC_CHAR="⚡"
	export IN_VIM_THEME_PROMPT_TEXT="ⓥ "
	export SHLVL_THEME_PROMPT_CHAR="ⓢ "
	export COMMAND_NUMBER_THEME_PROMPT_CHAR="↳"
}
