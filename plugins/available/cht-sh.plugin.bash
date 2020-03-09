cite about-plugin
about-plugin 'Simplify `curl cht.sh/<query>` to `cht.sh <query>`'

# Play nicely if user already installed cht.sh cli tool
if ! _command_exists cht.sh ; then
	function cht.sh () {
		curl "cht.sh/$1"
	}
fi
