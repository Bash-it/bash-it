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
export POWERLINE_SHORT_CWD_WIDTH=30

function cwd.shorten() {
  local begin="" # The unshortened beginning of the path.
  local shortbegin="" # The shortened beginning of the path.
  local current="" # The section of the path we're currently working on.
  local end="${2:-$(pwd)}/" # The unmodified rest of the path.

  if [[ "$end" =~ "${HOME}" ]]; then
      INHOME=1
      end="${end#$HOME}" #strip /home/username from start of string
      begin="$HOME"      #start expansion from the right spot
  else
      INHOME=0
  fi

  local end="${end#/}" # Strip the first /
  local shortenedpath="$end" # The whole path, to check the length.
  local maxlength="${1:-${POWERLINE_SHORT_CWD_WIDTH}}"

  shopt -q nullglob && NGV="-s" || NGV="-u" # Store the value for later.
  shopt -s nullglob    # Without this, anything that doesn't exist in the filesystem turns into */*/*/...

  while [[ "$end" ]] && (( ${#shortenedpath} > maxlength ))
  do
    current="${end%%/*}" # everything before the first /
    end="${end#*/}"    # everything after the first /

    shortcurstar="$current" # No star if we don't shorten it.

    for ((i=${#current}-2; i>=0; i--)); do
      subcurrent="${current:0:i}"
      matching=("$begin/$subcurrent"*) # Array of all files that start with $subcurrent. 
      (( ${#matching[*]} != 1 )) && break # Stop shortening if more than one file matches.
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

  shopt "$NGV" nullglob # Reset nullglob in case this is being used as a function.
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
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $6}');
  else
    w=$(stty -a 2>/dev/null | grep columns | awk '{print $7}' | sed -E 's/;//g');
  fi
  printf -- "%d" ${w}
}

# Filter/convert components passed as arguments to the 
# correct powerline modules
# @example: .powerline.components ruby python k8 garbage
# @output:  ruby python_venv k8s_context 
function .powerline.components() {
  local -a components
  components=()
  for c in "$@"; do
    [[ ${c} == "python" ]] && c="python_venv"
    [[ ${c} == "k8" ]] && c="k8s_context"
    local func="__powerline_${c}_prompt"
    type "$func" 2> /dev/null | head -1 | grep -q 'is a function' && components+=("${c}")
  done
  echo "${components[@]}"
}

function .powerline.supported.components() {
   set | grep -E '^__powerline_.*_prompt' | sed 's/__powerline_//g; s/_prompt.*$//g; s/^/    • /g'
}

# usage: powerline.prompt.set [ lang [ lang ]... ]
#    eg: powerline.prompt.set cwd ruby go node battery
function powerline.prompt.set() {
  [[ -z "$*" ]] && {
    echo -e "${echo_bold_red}Please pass an argument list of components you'd like to see in the PROMPT.${echo_reset_color}"
    echo -e "${echo_bold_yellow}Here is the list of all currently supported components:${echo_green}\n"
    .powerline.supported.components
    echo -e "${echo_reset_color}"
    return 
  }

  local -a components
  components=($(.powerline.components "$@"))

  local count="${#components[@]}"
  local half="$(( count / 2 ))"
  local even=0
  [[ $(( count % 2 )) -eq 0 ]] && even=1

  local half_plus_one="$((half+1))"

  # Single-line Powerline Prompts
  export POWERLINE_PROMPT="${components[*]}"
  
  # Multiline Powerline Prompts
  export POWERLINE_LEFT_PROMPT="${components[@]:0:${half_plus_one}}"
  if (( even )); then
    export POWERLINE_RIGHT_PROMPT="${components[@]:${half_plus_one}}"
  else
    export POWERLINE_RIGHT_PROMPT="${components[@]:${half_plus_one}}"
  fi
}

function powerline.prompt.show() {
  if [[ $BASH_IT_THEME =~ "multiline" ]]; then
    powerline.prompt.set-left-to
    powerline.prompt.set-right-to
  else
    powerline.prompt.set-to  
  fi
}

function powerline.prompt.set-to() {
  if [[ -z $* ]]; then
    echo "${POWERLINE_PROMPT}"  
  else
    export POWERLINE_PROMPT="$(.powerline.components "$@")"
  fi
}

function powerline.prompt.set-right-to() {
  if [[ -z $* ]]; then
    echo "${POWERLINE_RIGHT_PROMPT}"  
  else
    export POWERLINE_RIGHT_PROMPT="$(.powerline.components "$@")"
  fi
}

function powerline.prompt.set-left-to() {
  if [[ -z $* ]]; then
    echo "${POWERLINE_LEFT_PROMPT}"  
  else
    export POWERLINE_LEFT_PROMPT="$(.powerline.components "$@")"
  fi
}

# @example: powerline.prompt.add-component left ruby
function powerline.prompt.add-component() {
  local side="$1"
  local func
  if [[ -n $1 ]] ; then
    func="powerline.prompt.set-${side}-to" 
    shift
  else
    func="powerline.prompt.set-to"
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
