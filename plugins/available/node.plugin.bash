cite about-plugin
about-plugin 'Node.js helper functions'

pathmunge "./node_modules/.bin" "after"

# Make sure the global npm prefix is on the path
[[ `which npm 2>/dev/null` ]] && pathmunge "$(npm config get prefix)/bin" "after"
