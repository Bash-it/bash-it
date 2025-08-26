# shellcheck shell=bash
cite about-plugin
about-plugin 'miscellaneous tools'

function ips() {
	about 'display all ip addresses for this host'
	group 'base'
	if _command_exists ifconfig; then
		ifconfig | awk '/inet /{ gsub(/addr:/, ""); print $2 }'
	elif _command_exists ip; then
		ip addr | grep -oP 'inet \K[\d.]+'
	else
		echo "You don't have ifconfig or ip command installed!"
	fi
}

function down4me() {
	about 'checks whether a website is down for you, or everybody'
	param '1: website url'
	example '$ down4me http://www.google.com'
	group 'base'
	curl -Ls "http://downforeveryoneorjustme.com/$1" | sed '/just you/!d;s/<[^>]*>//g'
}

function myip() {
	about 'displays your ip address, as seen by the Internet'
	group 'base'
	list=("http://myip.dnsomatic.com/" "http://checkip.dyndns.com/" "http://checkip.dyndns.org/")
	for url in "${list[@]}"; do
		if res="$(curl -fs "${url}")"; then
			break
		fi
	done
	res="$(echo "$res" | grep -Eo '[0-9\.]+')"
	echo -e "Your public IP is: ${echo_bold_green-} $res ${echo_normal-}"
}

function pickfrom() {
	about 'picks random line from file'
	param '1: filename'
	example '$ pickfrom /usr/share/dict/words'
	group 'base'
	local file=${1:-}
	local -i n=0 length
	if [[ ! -r "$file" ]]; then
		reference "${FUNCNAME[0]}" && return
	fi
	length="$(wc -l < "$file")"
	n=$((RANDOM * length / 32768 + 1))
	head -n "$n" "$file" | tail -1
}

function passgen() {
	about 'generates random password from dictionary words'
	param 'optional integer length'
	param 'if unset, defaults to 4'
	example '$ passgen'
	example '$ passgen 6'
	group 'base'
	local -i i length=${1:-4}
	local pass
	# shellcheck disable=SC2034
	pass="$(for i in $(eval "echo {1..$length}"); do pickfrom /usr/share/dict/words; done)"
	echo "With spaces (easier to memorize): ${pass//$'\n'/ }"
	echo "Without spaces (easier to brute force): ${pass//$'\n'/}"
}

# Create alias pass to passgen when pass isn't installed or
# BASH_IT_LEGACY_PASS is true.
if ! _command_exists pass || [[ "${BASH_IT_LEGACY_PASS:-}" == true ]]; then
	alias pass=passgen
fi

if _command_exists markdown && _command_exists browser; then
	function pmdown() {
		about 'preview markdown file in a browser'
		param '1: markdown file'
		example '$ pmdown README.md'
		group 'base'

		markdown "${1?}" | browser
	}
fi

function mkcd() {
	about 'make one or more directories and cd into the last one'
	param 'one or more directories to create'
	example '$ mkcd foo'
	example '$ mkcd /tmp/img/photos/large'
	example '$ mkcd foo foo1 foo2 fooN'
	example '$ mkcd /tmp/img/photos/large /tmp/img/photos/self /tmp/img/photos/Beijing'
	group 'base'
	mkdir -p -- "$@" && cd -- "${!#}" || return
}

# shellcheck disable=SC2010
function lsgrep() {
	about 'search through directory contents with grep'
	group 'base'
	ls | grep "$@"
}

function quiet() {
	about 'what *does* this do?'
	group 'base'
	nohup "$@" &> /dev/null < /dev/null &
}

function usage() {
	about 'disk usage per directory, in Mac OS X and Linux'
	param '1: directory name'
	group 'base'
	case $OSTYPE in
		*'darwin'*)
			du -hd 1 "$@"
			;;
		*'linux'*)
			du -h --max-depth=1 "$@"
			;;
	esac
}

function t() {
	about 'todo.sh if available, otherwise one thing todo'
	param 'if not set, display todo item'
	param '1: todo text'

	local todotxt="${XDG_STATE_HOME:-~/.local/state}/bash_it/todo.txt"

	if _bash-it-component-item-is-enabled plugin todo; then
		todo.sh "$@"
		return
	elif [[ ! -f "${todotxt}" && -f ~/.t ]]; then
		mv -vn ~/.t "${todotxt}" # Verbose, so the user knows. Don't overwrite, just in case.
	fi

	if [[ "$#" -eq 0 ]]; then
		cat "${todotxt}"
	else
		echo "$@" >| "${todotxt}"
	fi
}

if _command_exists mkisofs; then
	function mkiso() {
		about 'creates iso from current dir in the parent dir (unless defined)'
		param '1: ISO name'
		param '2: dest/path'
		param '3: src/path'
		example 'mkiso'
		example 'mkiso ISO-Name dest/path src/path'
		group 'base'

		local isoname="${1:-${PWD##*/}}"
		local destpath="${2:-../}"
		local srcpath="${3:-${PWD}}"

		if [[ ! -f "${destpath%/}/${isoname}.iso" ]]; then
			echo "writing ${isoname}.iso to ${destpath} from ${srcpath}"
			mkisofs -V "${isoname}" -iso-level 3 -r -o "${destpath%/}/${isoname}.iso" "${srcpath}"
		else
			echo "${destpath%/}/${isoname}.iso already exists"
		fi
	}
fi

# useful for administrators and configs
function buf() {
	about 'back up file with timestamp'
	param 'filename'
	group 'base'
	local filename="${1?}" filetime
	filetime=$(date +%Y%m%d_%H%M%S)
	cp -a "${filename}" "${filename}_${filetime}"
}

if ! _command_exists del; then
	function del() {
		about 'move files to hidden folder in tmp, that gets cleared on each reboot'
		param 'file or folder to be deleted'
		example 'del ./file.txt'
		group 'base'
		mkdir -p /tmp/.trash && mv "$@" /tmp/.trash
	}
fi

# replace multiple file extensions at once
function renex() {
	about 'mass replace of the extension of multiple files'
	param '1: extension to replace'
	param '2: new extenstion'
	example 'rex txt md'
	group 'base'
	local ext2replace="${1:-}"
	local newext="${2:-}"
	local files=(*."$ext2replace")
	for file in "${files[@]}"; do
		local dst=${file/%."$ext2replace"/."$newext"}
		mv "$file" "$dst"
	done
}
