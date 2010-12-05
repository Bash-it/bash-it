ref() {
	if [ ! -d "$REF_DIR" ]
	then
		mkdir -p "$REF_DIR"
	fi

	REF_DIR=${REF_DIR%/}

	if [ "$1" = 'ls' ]
	then
		if [ "$2" = '' ]
		then
			builtin cd "$REF_DIR"
			ls -G
			builtin cd - > /dev/null
			return
		else
			builtin cd "$REF_DIR"/"$2"
			ls -G
			builtin cd - > /dev/null
			return
		fi
	fi

	DIR="${1}/${2}"

	builtin cd "$REF_DIR"/"$DIR"

	if [ $(uname) = "Darwin" ]
	then
		open index.html
	elif [ $(uname) = "Linux" ]
	then
		gnome-open index.html
	fi
}
