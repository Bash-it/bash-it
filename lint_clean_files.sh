#!/usr/bin/env bash

# Pull list of checkable files from clean_files.txt
#
mapfile -t FILES < clean_files.txt

pre-commit run --files "${FILES[@]}"
