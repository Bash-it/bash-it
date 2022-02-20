# shellcheck shell=bash
about-alias 'uuidgen aliases'

if _command_exists uuid; then # Linux
	alias uuidu="uuid | tr '[:lower:]' '[:upper:]'"
	alias uuidl=uuid
elif _command_exists uuidgen; then # macOS/BSD
	alias uuidu="uuidgen"
	alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'" # because upper case is like YELLING
	alias uuidl=uuid
fi
