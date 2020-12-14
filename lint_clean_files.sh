#!/usr/bin/env bash

# Pull list of checkable files from clean_files.txt
#  - Folder references are allowed
#  - Empty lines are ignored
#  - Comment lines (#) are ignored
#
# shellcheck disable=SC2002  # Prefer 'cat' for cleaner script
mapfile -t FILES < <(
	cat clean_files.txt \
		| grep -v -E '^\s*$' \
		| grep -v -E '^\s*#' \
		| xargs -n1 -I{} find "{}" -type f
)

# We clear the BASH_IT variable to help the shellcheck checker
# identify source includes within our scripts that require a
# 'source' directive.  For more information, see:
#
#    "Shellcheck SC1090 - Can't follow non-constant source"
#     https://www.shellcheck.net/wiki/SC1090
#
BASH_IT='' pre-commit run --files "${FILES[@]}"
