# Load rbebv, if you are using it

cite about-plugin
about-plugin 'load rbenv, if you are using it'

export PATH="$HOME/.rbenv/bin:$PATH"
[[ `which rbenv` ]] && eval "$(rbenv init -)"

# Load the auto-completion script if rbenv was loaded.
[[ -e ~/.rbenv/completions/rbenv.bash ]] && source ~/.rbenv/completions/rbenv.bash
