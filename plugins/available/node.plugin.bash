cite about-plugin
about-plugin 'Node.js helper functions'

export PATH=./node_modules/.bin:$PATH

# Make sure the global npm prefix is on the path
[[ `which npm` ]] && export PATH=$(npm config get prefix)/bin:$PATH


