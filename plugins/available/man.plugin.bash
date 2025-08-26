# shellcheck shell=bash
about-plugin 'colorize man pages for better readability'

: "${LESS_TERMCAP_mb:=$'\e[1;32m'}"
: "${LESS_TERMCAP_md:=$'\e[1;32m'}"
: "${LESS_TERMCAP_me:=$'\e[0m'}"
: "${LESS_TERMCAP_se:=$'\e[0m'}"
: "${LESS_TERMCAP_so:=$'\e[01;33m'}"
: "${LESS_TERMCAP_ue:=$'\e[0m'}"
: "${LESS_TERMCAP_us:=$'\e[1;4;31m'}"

: "${LESS:=}"
export "${!LESS_TERMCAP@}"
export LESS="--RAW-CONTROL-CHARS ${LESS}"
