cite about-plugin
about-plugin 'load chruby + auto-switching'
if [ -e /usr/opt/local/chruby ]
then
  source /usr/local/opt/chruby/share/chruby/chruby.sh
  source /usr/local/opt/chruby/share/chruby/auto.sh
else
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi
