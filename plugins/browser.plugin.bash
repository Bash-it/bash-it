# based on https://gist.github.com/318247

# Usage: browser
# pipe html to a browser
# e.g.
# $ echo "<h1>hi mom!</h1>" | browser
# $ ron -5 man/rip.5.ron | browser

function browser() {
    if [ -t 0 ]; then
        if [ -n "$1" ]; then
            open $1
        else
            cat <<usage
Usage: browser
pipe html to a browser

$ echo '<h1>hi mom!</h1>' | browser
$ ron -5 man/rip.5.ron | browser
usage

    fi

    else
        f="/tmp/browser.$RANDOM.html"
        cat /dev/stdin > $f
        open $f 
    fi
}


# pipe hot spicy interwebs into textmate and cleanup!
#
# Usage: wmate
# wget into a pipe into TextMate and force Tidy (you can undo in textmate)
# e.g.
# $ wmate google.com

function wmate() {
    if [ -t 0 ]; then
        if [ -n "$1" ]; then
            wget -qO- $1 | /usr/bin/mate

TIDY=`/usr/bin/osascript << EOT
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
EOT`

        else
            cat <<usage
Usage: wmate google.com
wget into a pipe into TextMate and force Tidy (you can undo in textmate)

$ wmate google.com
usage

      fi
    fi
}

#
# Usage: raw google.com
# wget into a temp file and pump it into your browser
#
# e.g.
# $ raw google.com
function raw() {
    if [ -t 0 ]; then
        if [ -n "$1" ]; then
            wget -qO- $1 | browser
        else
            cat <<usage
Usage: raw google.com
wget into a temp file and pump it into your browser

$ raw google.com
usage
      fi
    fi
}
