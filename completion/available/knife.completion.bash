# shellcheck shell=bash

# Published originally as public domain code at https://github.com/wk8/knife-bash-autocomplete

##############
### CONFIG ###
##############
### feel free to change those constants
# the dir where to store the cache (must be writable and readable by the current user)
# must be an absolute path
_KNIFE_AUTOCOMPLETE_CACHE_DIR="$HOME/.knife_autocomplete_cache"
# the maximum # of _seconds_ after which a cache will be considered stale
# (a cache is refreshed whenever it is used! this is only for caches that might not have been used for a long time)
# WARNING: keep that value > 100
_KNIFE_AUTOCOMPLETE_MAX_CACHE_AGE=86400

###############################################
### END OF CONFIG - DON'T CHANGE CODE BELOW ###
###############################################

### init
_KAC_CACHE_TMP_DIR="$_KNIFE_AUTOCOMPLETE_CACHE_DIR/tmp"
# make sure the cache dir exists
mkdir -p "$_KAC_CACHE_TMP_DIR"

##############################
### Cache helper functions ###
##############################

# GNU or BSD stat?
stat -c %Y /dev/null > /dev/null 2>&1 && _KAC_STAT_COMMAND="stat -c %Y" || _KAC_STAT_COMMAND="stat -f %m"

# returns 0 iff the file whose path is given as 1st argument
# exists and has last been modified in the last $2 seconds
# returns 1 otherwise
_KAC_is_file_newer_than() {
	[ -f "$1" ] || return 1
	[ $(($(date +%s) - $($_KAC_STAT_COMMAND "$1"))) -gt "$2" ] && return 1 || return 0
}

# helper function for _KAC_get_and_regen_cache, see doc below
_KAC_regen_cache() {
	local CACHE_NAME=$1
	local CACHE_PATH="$_KNIFE_AUTOCOMPLETE_CACHE_DIR/$CACHE_NAME"
	# shellcheck disable=SC2155
	local TMP_FILE=$(mktemp "$_KAC_CACHE_TMP_DIR/$CACHE_NAME.XXXX")
	shift 1
	# discard the temp file if it's empty AND the previous command didn't exit successfully, but still mark the cache as updated
	if ! "$@" > "$TMP_FILE" 2> /dev/null; then
		[[ $(wc -l "$TMP_FILE") == 0 ]] && rm -f "$TMP_FILE" && touch "$CACHE_PATH" && return 1
	else
		mv -f "$TMP_FILE" "$CACHE_PATH"
	fi
}

# cached files can't have spaces in their names
_KAC_get_cache_name_from_command() {
	echo "${@// /_SPACE_}"
}

# the reverse operation from the function above
_KAC_get_command_from_cache_name() {
	echo "${@//_SPACE_/ }"
}

# given a command as argument, it fetches the cache for that command if it can find it
# otherwise it waits for the cache to be generated
# in either case, it regenerates the cache, and sets the _KAC_CACHE_PATH env variable
# for obvious reason, do NOT call that in a sub-shell (in particular, no piping)
# shellcheck disable=SC2155
_KAC_get_and_regen_cache() {
	# the cache name can't have space in it
	local CACHE_NAME=$(_KAC_get_cache_name_from_command "$@")
	local REGEN_CMD="_KAC_regen_cache $CACHE_NAME $*"
	_KAC_CACHE_PATH="$_KNIFE_AUTOCOMPLETE_CACHE_DIR/$CACHE_NAME"
	# no need to wait for the regen if the file already exists
	if [[ -f "$_KAC_CACHE_PATH" ]]; then
		($REGEN_CMD &)
	else
		$REGEN_CMD
	fi
}

# performs two things: first, deletes all obsolete temp files
# then refreshes stale caches that haven't been called in a long time
_KAC_clean_cache() {
	local FILE CMD
	# delete all obsolete temp files, could be lingering there for any kind of crash in the caching process
	for FILE in "$_KAC_CACHE_TMP_DIR"/*; do
		_KAC_is_file_newer_than "$FILE" "$_KNIFE_AUTOCOMPLETE_MAX_CACHE_AGE" || rm -f "$FILE"
	done
	# refresh really stale caches
	find "$_KNIFE_AUTOCOMPLETE_CACHE_DIR" -maxdepth 1 -type f -not -name '.*' \
		| while read -r FILE; do
			_KAC_is_file_newer_than "$FILE" "$_KNIFE_AUTOCOMPLETE_MAX_CACHE_AGE" && continue
			# first let's get the original command
			CMD=$(_KAC_get_command_from_cache_name "$(basename "$FILE")")
			# then regen the cache
			_KAC_get_and_regen_cache "$CMD" > /dev/null
		done
}

# perform a cache cleaning when loading this file
# On big systems this could baloon up to a 30 second run or more, so not enabling by default.
[[ -n "${KNIFE_CACHE_CLEAN}" ]] && _KAC_clean_cache

#####################################
### End of cache helper functions ###
#####################################

# returns all the possible knife sub-commands
_KAC_knife_commands() {
	knife --help | grep -E "^knife" | sed -E 's/ \(options\)//g'
}

# rebuilds the knife base command currently being completed, and assigns it to $_KAC_CURRENT_COMMAND
# additionnally, returns 1 iff the current base command is not complete, 0 otherwise
# also sets $_KAC_CURRENT_COMMAND_NB_WORDS if the base command is complete
_KAC_get_current_base_command() {
	local PREVIOUS="knife"
	local I=1
	local CURRENT
	while [[ "${I}" -le "${COMP_CWORD}" ]]; do
		# command words are all lower-case
		echo "${COMP_WORDS[$I]}" | grep -E "^[a-z]+$" > /dev/null || break
		CURRENT="$PREVIOUS ${COMP_WORDS[$I]}"
		grep -E "^$CURRENT" "$_KAC_CACHE_PATH" > /dev/null || break
		PREVIOUS=$CURRENT
		I=$((I + 1))
	done
	_KAC_CURRENT_COMMAND=$PREVIOUS
	[[ "${I}" -le "${COMP_CWORD}" ]] && _KAC_CURRENT_COMMAND_NB_WORDS="${I}"
}

# searches the position of the currently completed argument in the current base command
# (i.e. handles "plural" arguments such as knife cookbook upload cookbook1 cookbook2 and so on...)
# assumes the current base command is complete
# shellcheck disable=SC2155
_KAC_get_current_arg_position() {
	local CURRENT_ARG_POS=$((_KAC_CURRENT_COMMAND_NB_WORDS + 1))
	local COMPLETE_COMMAND=$(grep -E "^$_KAC_CURRENT_COMMAND" "$_KAC_CACHE_PATH")
	local CURRENT_ARG
	while [ "$CURRENT_ARG_POS" -le "$COMP_CWORD" ]; do
		CURRENT_ARG=$(echo "$COMPLETE_COMMAND" | cut -d ' ' -f "$CURRENT_ARG_POS")
		# we break if the current arg is a "plural" arg
		echo "$CURRENT_ARG" | grep -E "^\\[[^]]+(\\.\\.\\.\\]|$)" > /dev/null && break
		CURRENT_ARG_POS=$((CURRENT_ARG_POS + 1))
	done
	echo "$CURRENT_ARG_POS"
}

# the actual auto-complete function
_knife() {
	_KAC_get_and_regen_cache _KAC_knife_commands
	local RAW_LIST ITEM REGEN_CMD ARG_POSITION
	# shellcheck disable=SC2034
	COMREPLY=()
	# get correct command & arg pos
	_KAC_get_current_base_command && ARG_POSITION=$(_KAC_get_current_arg_position) || ARG_POSITION=$((COMP_CWORD + 1))
	RAW_LIST=$(grep -E "^${_KAC_CURRENT_COMMAND}" "${_KAC_CACHE_PATH}" | cut -d ' ' -f "${ARG_POSITION}" | uniq)

	# we need to process that raw list a bit, most notably for placeholders
	# NOTE: I chose to explicitely fetch & cache _certain_ informations for the server (cookbooks & node names, etc)
	# as opposed to a generic approach by trying to find a 'list' knife command corresponding to the
	# current base command - that might limit my script in some situation, but that way I'm sure it caches only
	# not-sensitive stuff (a generic approach could be pretty bad e.g. with the knife-rackspace plugin)
	LIST=""
	for ITEM in $RAW_LIST; do
		# always relevant if only lower-case chars : continuation of the base command
		echo "$ITEM" | grep -E "^[a-z]+$" > /dev/null && LIST="$LIST $ITEM" && continue
		case "$ITEM" in
			*COOKBOOK*)
				# special case for cookbooks : from site or local
				[[ ${COMP_WORDS[2]} == 'site' ]] && REGEN_CMD="knife cookbook site list" || REGEN_CMD="knife cookbook list"
				_KAC_get_and_regen_cache "$REGEN_CMD"
				LIST="$LIST $(cut -d ' ' -f 1 < "$_KAC_CACHE_PATH")"
				continue
				;;
			*ITEM*)
				# data bag item : another special case
				local DATA_BAG_NAME=${COMP_WORDS[$((COMP_CWORD - 1))]}
				REGEN_CMD="knife data bag show $DATA_BAG_NAME"
				;;
			*INDEX*)
				# see doc @ http://docs.opscode.com/knife_search.html
				LIST="$LIST client environment node role"
				REGEN_CMD="knife data bag list"
				;;
			*BAG*) REGEN_CMD="knife data bag list" ;;
			*CLIENT*) REGEN_CMD="knife client list" ;;
			*NODE*) REGEN_CMD="knife node list" ;;
			*ENVIRONMENT*) REGEN_CMD="knife environment list" ;;
			*ROLE*) REGEN_CMD="knife role list" ;;
			*USER*) REGEN_CMD="knife user list" ;;
			# not a generic argument we support...
			*) continue ;;
		esac
		_KAC_get_and_regen_cache "$REGEN_CMD"
		LIST="$LIST $(cat "$_KAC_CACHE_PATH")"
	done
	# shellcheck disable=SC2207,SC2086
	COMPREPLY=($(compgen -W "${LIST}" -- ${COMP_WORDS[COMP_CWORD]}))
}

complete -F _knife knife
