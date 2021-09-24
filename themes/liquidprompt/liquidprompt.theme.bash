# shellcheck shell=bash
# shellcheck disable=SC2034 # expected behavior for themes
# Wrapper to use liquidprompt with _Bash It_

gray="\[\e[1;90m\]"

## Download repository if needed
__bash_it_theme_liquidprompt_path="github.com/nojhan/liquidprompt"
__bash_it_theme_liquidprompt_dir="${BASH_IT?}/vendor/${__bash_it_theme_liquidprompt_path}"
if [[ ! -d "${__bash_it_theme_liquidprompt_dir}" ]]; then
	if git clone --branch stable "https://${__bash_it_theme_liquidprompt_path}" "${__bash_it_theme_liquidprompt_dir}";then
		echo -e "Successfully cloned liquidprompt!\n More configuration in '${__bash_it_theme_liquidprompt_dir/$HOME/\~}/liquid.theme'."
	fi
fi

## Configure theme
LP_MARK_LOAD="📈 "
: "${LP_ENABLE_TIME:=1}"
: "${LP_HOSTNAME_ALWAYS:=1}"
: "${LP_USER_ALWAYS:=1}"
: "${LP_BATTERY_THRESHOLD:=75}"
: "${LP_LOAD_THRESHOLD:=60}"
: "${LP_TEMP_THRESHOLD:=80}"

## Load theme
# shellcheck source-path=SCRIPTDIR/../../vendor/github.com/nojhan/liquidprompt
source "${__bash_it_theme_liquidprompt_dir}/liquidprompt"

## Override upstream defaults
PS2=" ┃ "
LP_PS1_PREFIX="┌─"
LP_PS1_POSTFIX="\n└▪ "
LP_ENABLE_RUNTIME=0

function _lp_git_branch() {
	((${LP_ENABLE_GIT:-0})) || return

	command git rev-parse --is-inside-work-tree > /dev/null 2>&1 || return

	local branch
	# Recent versions of Git support the --short option for symbolic-ref, but
	# not 1.7.9 (Ubuntu 12.04)
	if branch="$(command git symbolic-ref -q HEAD)"; then
		_lp_escape "$(command git rev-parse --short=5 -q HEAD 2> /dev/null):${branch#refs/heads/}"
	else
		# In detached head state, use commit instead
		# No escape needed
		command git rev-parse --short -q HEAD 2> /dev/null
	fi
}

function _lp_time() {
	if ((LP_ENABLE_TIME)) && ((!${LP_TIME_ANALOG:-0})); then
		LP_TIME="${gray?}\D{${THEME_CLOCK_FORMAT:-"%d-%H:%M"}}${normal?}"
	else
		LP_TIME=""
	fi
}

# Implementation using lm-sensors
function _lp_temp_sensors() {
	local -i i
	for i in $(sensors -u \
		| sed -n 's/^  temp[0-9][0-9]*_input: \([0-9]*\)\..*$/\1/p'); do
		((i > ${temperature:-0})) && ((i != 127)) && temperature=i
	done
}

# Implementation using 'acpi -t'
function _lp_temp_acpi() {
	local -i i
	for i in $(LANG=C acpi -t \
		| sed 's/.* \(-\?[0-9]*\)\.[0-9]* degrees C$/\1/p'); do
		((i > ${temperature:-0})) && ((i != 127)) && temperature=i
	done
}
