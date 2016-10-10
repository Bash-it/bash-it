# Load rbebv, if you are using it

cite about-plugin
about-plugin 'load rbenv, if you are using it'

pathmunge "$HOME"/.rbenv/bin
[ -x `which rbenv` ] && eval "$(rbenv init -)"

[ -d "$HOME"/.rbenv/plugins/ruby-build ] && pathmunge "$HOME"/.rbenv/plugins/ruby-build/bin
