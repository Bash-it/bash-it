#!/bin/bash

function __ {
  echo "$@"
}

function __make_ansi {
  next=$1 && shift
  echo "\[\e[$(__$next $@)m\]"
}

function __make_echo {
  next=$1 && shift
  echo "\033[$(__$next $@)m"
}


function __reset {
  next=$1 && shift
  out="$(__$next $@)"
  echo "0${out:+;${out}}"
}

function __bold {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}1"
}

function __faint {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}2"
}

function __italic {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}3"
}

function __underline {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}4"
}

function __negative {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}7"
}

function __crossed {
  next=$1 && shift
  out="$(__$next $@)"
  echo "${out:+${out};}8"
}


function __color_normal_fg {
  echo "3$1"
}

function __color_normal_bg {
  echo "4$1"
}

function __color_bright_fg {
  echo "9$1"
}

function __color_bright_bg {
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
  r=$1 && g=$2 && b=$3
  [[ r == g && g == b ]] && echo $(( $r / 11 + 232 )) && return # gray range above 232
  echo "8;5;$(( ($r * 36  + $b * 6 + $g) / 51 + 16 ))"
}

function __color {
  color=$1 && shift
  case "$1" in
    fg|bg) side="$1" && shift ;;
    *) side=fg;;
  esac
  case "$1" in
    normal|bright) mode="$1" && shift;;
    *) mode=normal;;
  esac
  [[ $color == "rgb" ]] && rgb="$1 $2 $3" && shift 3

  next=$1 && shift
  out="$(__$next $@)"
  echo "$(__color_${mode}_${side} $(__color_${color} $rgb))${out:+;${out}}"
}


function __black   {
  echo "$(__color black $@)"
}

function __red   {
  echo "$(__color red $@)"
}

function __green   {
  echo "$(__color green $@)"
}

function __yellow  {
  echo "$(__color yellow $@)"
}

function __blue  {
  echo "$(__color blue $@)"
}

function __magenta {
  echo "$(__color magenta $@)"
}

function __cyan  {
  echo "$(__color cyan $@)"
}

function __white   {
  echo "$(__color white $@)"
}

function __rgb {
  echo "$(__color rgb $@)"
}


function __color_parse {
  next=$1 && shift
  echo "$(__$next $@)"
}

function color {
  echo "$(__color_parse make_ansi $@)"
}

function echo_color {
  echo "$(__color_parse make_echo $@)"
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
background_white="$(color white bg bold)"
background_orange="$(color red bg bright)"

normal="$(color reset)"
reset_color="$(__make_ansi '' 39)"

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
echo_background_white="$(echo_color white bg bold)"
echo_background_orange="$(echo_color red bg bright)"

echo_normal="$(echo_color reset)"
echo_reset_color="$(__make_echo '' 39)"
