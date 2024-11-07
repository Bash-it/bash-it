# shellcheck shell=bash
# based on https://gist.github.com/318247

cite about-plugin
about-plugin 'render commandline output in your browser'

# shellcheck disable=SC2120
function browser() {
	about 'pipe html to a browser'
	example '$ echo "<h1>hi mom!</h1>" | browser'
	example '$ ron -5 man/rip.5.ron | browser'
	group 'browser'

	if [ -t 0 ]; then
		if [ -n "$1" ]; then
			open "$1"
		else
			reference browser
		fi

	else
		f="/tmp/browser.$RANDOM.html"
		cat /dev/stdin > $f
		open $f
	fi
}

function wmate() {
	about 'pipe hot spicy interwebs into textmate and cleanup!'
	example '$ wmate google.com'
	group 'browser'

	if [ -t 0 ]; then
		if [ -n "$1" ]; then
			wget -qO- "$1" | /usr/bin/mate
			TIDY=$(
				/usr/bin/osascript << EOT
tell application "TextMate"
	activate
end tell

tell application "System Events"
	tell process "TextMate"
		tell menu bar 1
			tell menu bar item "Bundles"
				tell menu "Bundles"
					tell menu item "HTML"
						tell menu "HTML"
							click menu item "Tidy"
						end tell
					end tell
				end tell
			end tell
		end tell
	end tell
end tell
EOT
			)
			export TIDY

		else
			reference wmate
		fi
	fi
}

function raw() {
	about 'write wget into a temp file and pump it into your browser'
	example '$ raw google.com'
	group 'browser'

	if [ -t 0 ]; then
		if [ -n "$1" ]; then
			wget -qO- "$1" | browser
		else
			reference raw
		fi
	fi
}
