# shellcheck shell=bash
# shellcheck disable=SC2005

function __() {
	echo "$@"
}

function __make_ansi() {
	next=$1
	shift
	echo -e "\[\e[$("__$next" "$@")m\]"
}

function __make_echo() {
	next=$1
	shift
	echo -e "\033[$("__$next" "$@")m"
}

function __reset() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "0${out:+;${out}}"
}

function __bold() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}1"
}

function __faint() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}2"
}

function __italic() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}3"
}

function __underline() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}4"
}

function __negative() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}7"
}

function __crossed() {
	next=$1
	shift
	out="$("__$next" "$@")"
	echo "${out:+${out};}8"
}

function __color_normal_fg() {
	echo "3$1"
}

function __color_normal_bg() {
	echo "4$1"
}

function __color_bright_fg() {
	echo "9$1"
}

function __color_bright_bg() {
	echo "10$1"
}

function __color_black() {
	echo "0"
}

function __color_red() {
	echo "1"
}

function __color_green() {
	echo "2"
}

function __color_yellow() {
	echo "3"
}

function __color_blue() {
	echo "4"
}

function __color_magenta() {
	echo "5"
}

function __color_cyan() {
	echo "6"
}

function __color_white() {
	echo "7"
}

function __color_rgb() {
	r=$1 && g=$2 && b=$3
	[[ $r == "$g" && $g == "$b" ]] && echo $((r / 11 + 232)) && return # gray range above 232
	echo "8;5;$(((r * 36 + b * 6 + g) / 51 + 16))"
}

function __color() {
	color="$1"
	shift
	case "$1" in
		fg | bg)
			side="$1"
			shift
			;;
		*) side="fg" ;;
	esac
	case "$1" in
		normal | bright)
			mode="$1"
			shift
			;;
		*) mode=normal ;;
	esac
	[[ $color == "rgb" ]] && rgb="$1 $2 $3"
	shift 3

	next=$1
	shift
	out="$("__$next" "$@")"
	echo "$("__color_${mode}_${side}" "$("__color_${color}" "$rgb")")${out:+;${out}}"
}

function __black() {
	echo "$(__color black "$@")"
}

function __red() {
	echo "$(__color red "$@")"
}

function __green() {
	echo "$(__color green "$@")"
}

function __yellow() {
	echo "$(__color yellow "$@")"
}

function __blue() {
	echo "$(__color blue "$@")"
}

function __magenta() {
	echo "$(__color magenta "$@")"
}

function __cyan() {
	echo "$(__color cyan "$@")"
}

function __white() {
	echo "$(__color white "$@")"
}

function __rgb() {
	echo "$(__color rgb "$@")"
}

function __color_parse() {
	next=$1
	shift
	echo "$("__$next" "$@")"
}

function color() {
	echo "$(__color_parse make_ansi "$@")"
}

function echo_color() {
	echo "$(__color_parse make_echo "$@")"
}
