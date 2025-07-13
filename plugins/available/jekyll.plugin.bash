# shellcheck shell=bash
cite about-plugin
about-plugin 'manage your jekyll site'

function editpost() {
	about 'edit a post'
	param '1: site directory'
	group 'jekyll'

	local SITE site POST DATE TITLE POSTS
	local -i COUNTER=1 POST_TO_EDIT ret
	if [[ -z "${1:-}" ]]; then
		echo "Error: no site specified."
		echo "The site is the name of the directory your project is in."
		return 1
	fi

	for site in "${SITES[@]:-}"; do
		if [[ "${site##*/}" == "$1" ]]; then
			SITE="${site}"
			break
		fi
	done

	if [[ -z "${SITE:-}" ]]; then
		echo "No such site."
		return 1
	fi

	pushd "${SITE}/_posts" > /dev/null || return

	for POST in *; do
		DATE="$(echo "${POST}" | grep -E -o "[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}")"
		TITLE="$(grep -E -o "title: (.+)" < "${POST}")"
		TITLE="${TITLE/title: /}"
		echo "${COUNTER}) 	${DATE}	${TITLE}"
		POSTS[COUNTER]="$POST"
		COUNTER="$((COUNTER + 1))"
	done > >(less)
	read -rp "Number of post to edit: " POST_TO_EDIT
	"${JEKYLL_EDITOR:-${VISUAL:-${EDITOR:-${ALTERNATE_EDITOR:-nano}}}}" "${POSTS[POST_TO_EDIT]}"
	ret="$?"
	popd > /dev/null || return "$ret"
	return "$ret"
}

function newpost() {
	about 'create a new post'
	param '1: site directory'
	group 'jekyll'

	local SITE site FNAME_POST_TITLE FNAME YAML_DATE
	local JEKYLL_FORMATTING FNAME_DATE OPTIONS OPTION POST_TYPE POST_TITLE
	local -i loc=0 ret
	if [[ -z "${1:-}" ]]; then
		echo "Error: no site specified."
		echo "The site is the name of the directory your project is in."
		return 1
	fi

	if [[ -z "${SITE}" ]]; then
		echo "No such site."
		return 1
	fi

	for site in "${SITES[@]}"; do
		if [[ "${site##*/}" == "$1" ]]; then
			SITE="$site"
			JEKYLL_FORMATTING="${MARKUPS[loc]}"
			break
		fi
		loc=$((loc + 1))
	done

	# Change directory into the local jekyll root
	pushd "${SITE}/_posts" > /dev/null || return

	# Get the date for the new post's filename
	FNAME_DATE="$(date "+%Y-%m-%d")"

	# If the user is using markdown or textile formatting, let them choose what type of post they want. Sort of like Tumblr.
	OPTIONS=('Text' 'Quote' 'Image' 'Audio' 'Video' 'Link')

	if [[ $JEKYLL_FORMATTING == "markdown" || $JEKYLL_FORMATTING == "textile" ]]; then
		select OPTION in "${OPTIONS[@]}"; do
			POST_TYPE="${OPTION}"
			break
		done
	fi

	# Get the title for the new post
	read -rp "Enter title of the new post: " POST_TITLE

	# Convert the spaces in the title to hyphens for use in the filename
	FNAME_POST_TITLE="${POST_TITLE/ /-}"

	# Now, put it all together for the full filename
	FNAME="$FNAME_DATE-$FNAME_POST_TITLE.$JEKYLL_FORMATTING"

	# And, finally, create the actual post file. But we're not done yet...
	{
		# Write a little stuff to the file for the YAML Front Matter
		echo "---"

		# Now we have to get the date, again. But this time for in the header (YAML Front Matter) of the file
		YAML_DATE="$(date "+%B %d %Y %X")"

		# Echo the YAML Formatted date to the post file
		echo "date: $YAML_DATE"

		# Echo the original post title to the YAML Front Matter header
		echo "title: $POST_TITLE"

		# And, now, echo the "post" layout to the YAML Front Matter header
		echo "layout: post"

		# Close the YAML Front Matter Header
		echo "---"

		echo
	} > "${FNAME}"

	# Generate template text based on the post type
	if [[ $JEKYLL_FORMATTING == "markdown" ]]; then
		case $POST_TYPE in
			"Text")
				true
				;;
			"Quote")
				echo "> Quote"
				echo
				echo "&mdash; Author"
				;;
			"Image")
				echo "![Alternate Text](/path/to/image/or/url)"
				;;
			"Audio")
				echo "<html><audio src=\"/path/to/audio/file\" controls=\"controls\"></audio></html>"
				;;
			"Video")
				echo "<html><video src=\"/path/to/video\" controls=\"controls\"></video></html>"
				;;
			"Link")
				echo "[link][1]"
				echo
				echo "> Quote"
				echo
				echo "[1]: url"
				;;
		esac
	elif [[ $JEKYLL_FORMATTING == "textile" ]]; then
		case $POST_TYPE in
			"Text")
				true
				;;
			"Quote")
				echo "bq. Quote"
				echo
				echo "&mdash; Author"
				;;
			"Image")
				echo "!url(alt text)"
				;;
			"Audio")
				echo "<html><audio src=\"/path/to/audio/file\" controls=\"controls\"></audio></html>"
				;;
			"Video")
				echo "<html><video src=\"/path/to/video\" controls=\"controls\"></video></html>"
				;;
			"Link")
				echo "\"Site\":url"
				echo
				echo "bq. Quote"
				;;
		esac
	fi >> "${FNAME}"

	# Open the file in your favorite editor
	"${JEKYLL_EDITOR:-${VISUAL:-${EDITOR:-${ALTERNATE_EDITOR:-nano}}}}" "${FNAME}"
	ret="$?"
	popd > /dev/null || return "$ret"
	return "$ret"
}

function testsite() {
	about 'launches local jekyll server'
	param '1: site directory'
	group 'jekyll'

	local SITE site
	local -i ret
	if [[ -z "${1:-}" ]]; then
		echo "Error: no site specified."
		echo "The site is the name of the directory your project is in."
		return 1
	fi

	for site in "${SITES[@]}"; do
		if [[ "${site##*/}" == "$1" ]]; then
			SITE="$site"
			break
		fi
	done

	if [[ -z "${SITE}" ]]; then
		echo "No such site."
		return 1
	fi

	pushd "${SITE}" > /dev/null || return
	jekyll --server --auto
	ret="$?"
	popd > /dev/null || return "$ret"
	return "$ret"
}

function buildsite() {
	about 'builds site'
	param '1: site directory'
	group 'jekyll'

	local SITE site
	local -i ret
	if [[ -z "${1:-}" ]]; then
		echo "Error: no site specified."
		echo "The site is the name of the directory your project is in."
		return 1
	fi

	for site in "${SITES[@]}"; do
		if [[ "${site##*/}" == "$1" ]]; then
			SITE="$site"
			break
		fi
	done

	if [[ -z "${SITE}" ]]; then
		echo "No such site."
		return 1
	fi

	pushd "${SITE}" > /dev/null || return
	rm -rf _site
	jekyll --no-server
	ret="$?"
	popd > /dev/null || return "$ret"
	return "$ret"
}

function deploysite() {
	about 'rsyncs site to remote host'
	param '1: site directory'
	group 'jekyll'

	local SITE site REMOTE
	local -i loc=0 ret
	if [[ -z "${1:-}" ]]; then
		echo "Error: no site specified."
		echo "The site is the name of the directory your project is in."
		return 1
	fi

	for site in "${SITES[@]}"; do
		if [[ "${site##*/}" == "$1" ]]; then
			SITE="$site"
			# shellcheck disable=SC2153 # who knows
			REMOTE="${REMOTES[loc]}"
			break
		fi
		loc=$((loc + 1))
	done

	if [[ -z "${SITE}" ]]; then
		echo "No such site."
		return 1
	fi

	pushd "${SITE}" > /dev/null || return
	rsync -rz "${REMOTE?}"
	ret="$?"
	popd > /dev/null || return "$ret"
	return "$ret"
}

# Load the Jekyll config
if [[ -s "$HOME/.jekyllconfig" ]]; then
	# shellcheck disable=SC1091
	source "$HOME/.jekyllconfig"
fi
