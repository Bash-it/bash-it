cite about-plugin
about-plugin 'soft delete by moving contents into a hidden folder in tmp'

# the tmp folder gets cleared on reboot
# so this would actually remove the file on
# shutdown
function del() { mkdir -p /tmp/.trash && mv "$@" /tmp/.trash; }
