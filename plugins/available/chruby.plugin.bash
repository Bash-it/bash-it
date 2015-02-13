cite about-plugin
about-plugin 'load chruby                  (from /usr/local/share/chruby)'

if [ -e /usr/opt/local/chruby ]
then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
else
  source /usr/local/share/chruby/chruby.sh
fi
