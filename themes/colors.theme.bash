#!/bin/bash

function __make_ansi {
  echo "\[\e[$1m\]"
}

function __make_echo {
  echo "\033[$1m"
}


function __reset {
  echo "0${1:+;$1}"
}

function __bold {
  echo "${1:+$1;}1"
}

function __faint {
  echo "${1:+$1;}2"
}

function __italic {
  echo "${1:+$1;}3"
}

function __underline {
  echo "${1:+$1;}4"
}

function __negative {
  echo "${1:+$1;}7"
}

function __crossed {
  echo "${1:+$1;}8"
}


function __normal_fg {
  echo "3$1"
}

function __normal_bg {
  echo "4$1"
}

function __bright_fg {
  echo "9$1"
}

function __bright_bg {
  echo "10$1"
}


function __color_black   {
  echo "0"
}

function __color_red   {
  echo "1"
}

function __color_green   {
  echo "2"
}

function __color_yellow  {
  echo "3"
}

function __color_blue  {
  echo "4"
}

function __color_magenta {
  echo "5"
}

function __color_cyan  {
  echo "6"
}

function __color_white   {
  echo "7"
}

function __color_rgb {
  r=$1
  g=$2
  b=$3

  [[ r == g && g == b ]] && echo $(( $r / 11 + 232 )) && return # gray range above 232
  echo "8;5;$(( ($r * 36  + $b * 6 + $g) / 51 + 16 ))"
}

function __color {
  color=$1
  side=${2:-fg}
  mode=${3:-normal}
  echo "$(__${mode}_${side} $(__color_${color} $@))"
}

function __color_parse {
  while [ $# -gt 0 ]
  do
    case "$1" in
      reset|bold|faint|italic|underline|negative|crossed)
        output="$(__$1 $output)"
        shift

        ;;

      black|red|green|yellow|blue|magenta|cyan|white|rgb)
        color="$1"
        shift

        case "$1" in
          fg|bg)
            side="$1"
            shift

            case "$1" in
              normal|bright)
                mode="$1"
                shift
              ;;
            esac

          ;;
        esac

        [[ $color == "rgb" ]] && params="$1 $2 $3" && shift 3
        output=${output:+$output;}$(__color $color $side $mode $params)

      ;;

      *) shift;;
    esac
  done

  echo ${output}
}

function color {
  echo $(__make_ansi $(__color_parse $@))
}

function echo_color {
  echo $(__make_echo $(__color_parse $@))
}

black="$(color black)"
red="$(color red)"
green="$(color green)"
yellow="$(color yellow)"
blue="$(color blue)"
purple="$(color magenta)"
cyan="$(color cyan)"
white="$(color white bold)"
orange="$(color red fg bright)"

bold_black="$(color black bold)"
bold_red="$(color red bold)"
bold_green="$(color green bold)"
bold_yellow="$(color yellow bold)"
bold_blue="$(color blue bold)"
bold_purple="$(color magenta bold)"
bold_cyan="$(color cyan bold)"
bold_white="$(color white bold)"
bold_orange="$(color red fg bright bold)"

underline_black="$(color black underline)"
underline_red="$(color red underline)"
underline_green="$(color green underline)"
underline_yellow="$(color yellow underline)"
underline_blue="$(color blue underline)"
underline_purple="$(color magenta underline)"
underline_cyan="$(color cyan underline)"
underline_white="$(color white underline)"
underline_orange="$(color red fg bright underline)"

background_black="$(color black bg)"
background_red="$(color red bg)"
background_green="$(color green bg)"
background_yellow="$(color yellow bg)"
background_blue="$(color blue bg)"
background_purple="$(color magenta bg)"
background_cyan="$(color cyan bg)"
background_white="$(color white bold bg)"
background_orange="$(color red bg bright)"

normal="$(color reset)"
reset_color="$(__make_ansi 39)"

# These colors are meant to be used with `echo -e`
echo_black="$(echo_color black)"
echo_red="$(echo_color red)"
echo_green="$(echo_color green)"
echo_yellow="$(echo_color yellow)"
echo_blue="$(echo_color blue)"
echo_purple="$(echo_color magenta)"
echo_cyan="$(echo_color cyan)"
echo_white="$(echo_color white bold)"
echo_orange="$(echo_color red fg bright)"

echo_bold_black="$(echo_color black bold)"
echo_bold_red="$(echo_color red bold)"
echo_bold_green="$(echo_color green bold)"
echo_bold_yellow="$(echo_color yellow bold)"
echo_bold_blue="$(echo_color blue bold)"
echo_bold_purple="$(echo_color magenta bold)"
echo_bold_cyan="$(echo_color cyan bold)"
echo_bold_white="$(echo_color white bold)"
echo_bold_orange="$(echo_color red fg bright bold)"

echo_underline_black="$(echo_color black underline)"
echo_underline_red="$(echo_color red underline)"
echo_underline_green="$(echo_color green underline)"
echo_underline_yellow="$(echo_color yellow underline)"
echo_underline_blue="$(echo_color blue underline)"
echo_underline_purple="$(echo_color magenta underline)"
echo_underline_cyan="$(echo_color cyan underline)"
echo_underline_white="$(echo_color white underline)"
echo_underline_orange="$(echo_color red fg bright underline)"

echo_background_black="$(echo_color black bg)"
echo_background_red="$(echo_color red bg)"
echo_background_green="$(echo_color green bg)"
echo_background_yellow="$(echo_color yellow bg)"
echo_background_blue="$(echo_color blue bg)"
echo_background_purple="$(echo_color magenta bg)"
echo_background_cyan="$(echo_color cyan bg)"
echo_background_white="$(echo_color white bold bg)"
echo_background_orange="$(echo_color red bg bright)"

echo_normal="$(echo_color reset)"
echo_reset_color="$(__make_ansi 39)"
