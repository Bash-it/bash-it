#!/usr/bin/env bash
# Wrapper to use liquidprompt with bashit

targetdir="$BASH_IT/themes/liquidprompt/liquidprompt"
gray="\[\e[1;90m\]"

cwd="$PWD"
if cd "$targetdir" &>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    true
else
    git clone https://github.com/nojhan/liquidprompt.git "$targetdir" && \
    echo -e "Successfully cloned liquidprompt!\n More configuration in '$targetdir/liquid.theme'."
fi
cd "$cwd"

export LP_ENABLE_TIME=1
export LP_HOSTNAME_ALWAYS=1
export LP_USER_ALWAYS=1
export LP_MARK_LOAD="📈 "
export LP_BATTERY_THRESHOLD=${LP_BATTERY_THRESHOLD:-75}
export LP_LOAD_THRESHOLD=${LP_LOAD_THRESHOLD:-60}
export LP_TEMP_THRESHOLD=${LP_TEMP_THRESHOLD:-80}


source "$targetdir/liquidprompt"
prompt() { true; }
export PS2=" ┃ "
export LP_PS1_PREFIX="┌─"
export LP_PS1_POSTFIX="\n└▪ "
export LP_ENABLE_RUNTIME=0

_lp_git_branch()
{
    (( LP_ENABLE_GIT )) || return

    \git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

    local branch
    # Recent versions of Git support the --short option for symbolic-ref, but
    # not 1.7.9 (Ubuntu 12.04)
    if branch="$(\git symbolic-ref -q HEAD)"; then
        _lp_escape "$(\git rev-parse --short=5 -q HEAD 2>/dev/null):${branch#refs/heads/}"
    else
        # In detached head state, use commit instead
        # No escape needed
        \git rev-parse --short -q HEAD 2>/dev/null
    fi
}

_lp_time() {
    if (( LP_ENABLE_TIME )) && (( ! LP_TIME_ANALOG )); then
        LP_TIME="${gray}$(date +%d-%H:%M)${normal}"
    else
        LP_TIME=""
    fi
}

# Implementation using lm-sensors
_lp_temp_sensors()
{
    local -i i
    for i in $(sensors -u |
            sed -n 's/^  temp[0-9][0-9]*_input: \([0-9]*\)\..*$/\1/p'); do
            (( $i > ${temperature:-0} )) && (( $i != 127 )) && temperature=i
    done
}

# Implementation using 'acpi -t'
_lp_temp_acpi()
{
    local -i i
    for i in $(LANG=C acpi -t |
            sed 's/.* \(-\?[0-9]*\)\.[0-9]* degrees C$/\1/p'); do
        (( $i > ${temperature:-0} )) && (( $i != 127 )) && temperature=i
    done
}
