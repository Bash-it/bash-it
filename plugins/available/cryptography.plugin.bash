# shellcheck shell=bash

function encrypt-payload() {
	PAYLOAD=$1
	KEY=$2
	ALGO=${3:-aes-256-cbc}

	# exit with message if payload is empty string
	if [[ -z "$PAYLOAD" ]]; then
		echo "[x] Payload is empty!"
		return 1
	fi

	# create random key if not provided
	if [[ -z "$KEY" ]]; then
		KEY=$(echo "$RANDOM$RANDOM" | md5sum - | head -c 13)
		echo "[!] Key not provided, therefore choosen a random string -> $KEY" 1>&2
		echo "[!] To hide this message, provide the key as second argument or redirect stderr to /dev/null" 1>&2
	fi

	if [[ -f "$1" ]]; then
		# if payload file then encrypt with -in
		OUTFILE=$(mktemp)
		if ! openssl enc "-$ALGO" -a -A -e -pbkdf2 -pass pass:"$KEY" -in "$PAYLOAD" -out "$OUTFILE"; then
			echo "[x] Something went wrong!"
			rm -rf "$OUTFILE"
		else
			echo "[!] Saved the encrypted file to '$OUTFILE'"
		fi
	else
		# if payload file then encrypt with stdin
		echo -ne "$1" | openssl enc "-$ALGO" -a -A -e -pbkdf2 -pass pass:"$KEY"
	fi
}

function decrypt-payload() {
	PAYLOAD=$1
	KEY=$2
	ALGO=${3:-aes-256-cbc}

	# exit with message if payload is empty string
	if [[ -z "$PAYLOAD" ]]; then
		echo "[x] Payload is empty!"
		return 1
	fi

	# create random key if not provided
	if [[ -z "$KEY" ]]; then
		echo "[x] Key is empty!"
		return 1
	fi

	if [[ -f "$1" ]]; then
		# if payload file then encrypt with -in
		OUTFILE=$(mktemp)
		if ! openssl enc "-$ALGO" -a -A -d -pbkdf2 -pass pass:"$KEY" -in "$PAYLOAD" -out "$OUTFILE"; then
			echo "[x] Something went wrong!"
			rm -rf "$OUTFILE"
		else
			echo "[!] Saved the encrypted file to '$OUTFILE'"
		fi
	else
		# if payload file then encrypt with stdin
		echo -ne "$1" | openssl enc "-$ALGO" -a -A -d -pbkdf2 -pass pass:"$KEY"
	fi
}
