#!/usr/bin/env bash
cite "about-completion"
about-completion "GitHub CLI completion"

if _binary_exists gh; then
    complete -p gh &> /dev/null || return
    eval "$(gh completion --shell=bash)"
fi
