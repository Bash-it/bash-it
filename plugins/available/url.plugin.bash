# shellcheck shell=bash
cite about-plugin
about-plugin 'Basic url handling and manipulation functions'

function slugify() {
	about 'takes the text and transform to slug url, also supports formats like (html,link,rst,md)'
	group 'url'
	param "1: Text to transform (optional)"
	param "2: Output format (html,rst,link,md). Omit or pass any text to return only output"

	local TXT=$1
	local OUTPUT=$2
	local SLUG

	if [[ -z $TXT ]]; then
		read -rp "Enter the valid string: " TXT
	fi

	# Pass 1 - Clean the url
	# Credits: https://stackoverflow.com/a/20007549/10362396
	SLUG=$(echo -n "$TXT" | tr -cd ' [:alnum:]._-' | tr -s ' ')

	# Pass 2 - Transformation
	SLUG=$(echo -n "$SLUG" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

	case "$OUTPUT" in
		html | htm)
			echo "<a href=\"#$SLUG\">$TXT</a>"
			;;
		href | link)
			echo "#$SLUG"
			;;
		md)
			echo "[$TXT](#$SLUG)"
			;;
		rst)
			echo "\`$TXT <#$SLUG>\`_"
			;;

		*)
			echo "$SLUG"
			;;
	esac

}
