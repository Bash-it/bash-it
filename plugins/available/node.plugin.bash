cite about-plugin
about-plugin 'Node.js helper functions'

__append_uniq_path './node_modules/.bin'

# Make sure the global npm prefix is on the path
[[ `which npm` ]] && __append_uniq_path "$(npm config get prefix)/bin"
