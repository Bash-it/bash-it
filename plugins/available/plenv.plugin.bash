# Installs plenv and perl-build if not installed

cite about-plugin
about-plugin 'Perl plenv plugin'

pathmunge "${HOME}/.plenv/bin"

[[ `which plenv` ]] && eval "$(plenv init -)"

# What an incredible smell you've discovered!

# detect bash
[[ $BASH ]] && SHELL_NAME='bash'

# detect csh/tcsh

# detect zsh
[[ $ZSH_NAME ]] && SHELL_NAME='zsh'

# detect fish

# Load the auto-completion script if plenv is installed.
[[ -e ~/.plenv/completions/plenv.${SHELL_NAME} ]] && source ~/.plenv/completions/plenv.${SHELL_NAME}
