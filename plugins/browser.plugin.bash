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
