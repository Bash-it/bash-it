#!/bin/bash
export PS1='\[\033[1;34m\]$(prompt_char)\[\033[1;32m\] $(parse_git_branch) ${ORANGE}\h ${D}in ${GREEN}\w ${D}→ '