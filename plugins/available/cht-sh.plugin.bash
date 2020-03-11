cite about-plugin
about-plugin 'Simplify `curl cht.sh/<query>` to `cht.sh <query>`'

# Play nicely if user already installed cht.sh cli tool
if ! _command_exists cht.sh ; then
	function cht.sh () {
		about 'Executes a cht.sh curl query using the provided arguments'
		param ' [ ( topic [sub-topic] ) | ~keyword ] [ :list | :help | :learn ]'
		example '$ cht.sh :help'
		example '$ cht.sh :list'
		example '$ cht.sh tar'
		example '$ cht.sh js "parse json"'
		example '$ cht.sh python :learn'
		example '$ cht.sh rust :list'
		group 'cht-sh'

		# Separate arguments with '/', preserving spaces within them
		local query=$(IFS=/ ; echo "$*")
		curl "cht.sh/${query}"
	}
fi
