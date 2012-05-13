#!/usr/bin/env sh

# Fasd (this file) can be sourced or executed by any POSIX compatible shell.

# Fasd is originally written based on code from z (https://github.com/rupa/z)
# by rupa deadwyler under the WTFPL license. Most if not all of the code has
# been rewritten.

# Copyright (C) 2011, 2012 by Wei Dai. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

fasd() {

  case "$1" in
  --init)
    shift
    while [ "$1" ]; do
      case $1 in
        env)
          { # source rc files if present
          [ -s "/etc/fasdrc" ] && . "/etc/fasdrc"
          [ -s "$HOME/.fasdrc" ] && . "$HOME/.fasdrc"

          # set default options
          [ -z "$_FASD_DATA" ] && _FASD_DATA="$HOME/.fasd"
          [ -z "$_FASD_BLACKLIST" ] && _FASD_BLACKLIST="--help"
          [ -z "$_FASD_SHIFT" ] && _FASD_SHIFT="sudo busybox"
          [ -z "$_FASD_IGNORE" ] && _FASD_IGNORE="fasd cd ls echo"
          [ -z "$_FASD_SINK" ] && _FASD_SINK=/dev/null
          [ -z "$_FASD_TRACK_PWD" ] && _FASD_TRACK_PWD=1
          [ -z "$_FASD_MAX" ] && _FASD_MAX=2000
          [ -z "$_FASD_BACKENDS" ] && _FASD_BACKENDS=native

          if [ -z "$_FASD_AWK" ]; then
            # awk preferences
            local awk; for awk in mawk gawk original-awk nawk awk; do
              $awk "" && _FASD_AWK=$awk && break
            done
          fi
        } >> "${_FASD_SINK:-/dev/null}" 2>&1
        ;;

      auto) cat <<EOS
{ if compctl; then # zsh
    eval "\$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \
      zsh-wcomp zsh-wcomp-install)"
  elif complete; then # bash
    eval "\$(fasd --init posix-alias bash-hook bash-ccomp bash-ccomp-install)"
  else # posix shell
    eval "\$(fasd --init posix-alias posix-hook)"
  fi
} >> "$_FASD_SINK" 2>&1

EOS
        ;;

      posix-alias) cat <<EOS
alias a='fasd -a'
alias s='fasd -si'
alias sd='fasd -sid'
alias sf='fasd -sif'
alias d='fasd -d'
alias f='fasd -f'
# function to execute built-in cd
fasd_cd() { [ \$# -gt 1 ] && cd "\$(fasd -e echo "\$@")" || fasd "\$@"; }
alias z='fasd_cd -d'

EOS
        ;;

      zsh-hook) cat <<EOS
# add zsh hook
_fasd_preexec() {
  { eval "fasd --proc \$(fasd --sanitize \$3)"; } >> "$_FASD_SINK" 2>&1
}
autoload -U add-zsh-hook
add-zsh-hook preexec _fasd_preexec

EOS
        ;;

      bash-hook) cat <<EOS
# add bash hook
echo \$PROMPT_COMMAND | grep -v -q "fasd --proc" && \
  PROMPT_COMMAND='eval "fasd --proc \$(fasd --sanitize \$(history 1 | \
  sed -e "s/^[ ]*[0-9]*[ ]*//"))" >> "$_FASD_SINK" 2>&1;'"\$PROMPT_COMMAND"

EOS
        ;;

      posix-hook) cat <<EOS
_fasd_ps1_func() {
  { eval "fasd --proc \$(fasd --sanitize \
      \$(fc -nl -0 | sed -n '\$s/\s*\(.*\)/\1/p'))"; } >> "$_FASD_SINK" 2>&1
}
echo "\$PS1" | grep -v -q "_fasd_ps1_func" && \
export PS1="\\\$(_fasd_ps1_func)\$PS1"

EOS
        ;;

      zsh-ccomp) cat <<EOS
# zsh command mode completion
_fasd_zsh_cmd_complete() {
  local compl
  read -c compl
  compstate[insert]=menu # no expand
  reply=(\${(f)"\$(fasd --complete "\$compl")"})
}

EOS
        ;;

      zsh-wcomp) cat <<EOS
# zsh word mode completion
_fasd_zsh_word_complete() {
  [ "\$2" ] && local _fasd_cur="\$2"
  [ -z "\$_fasd_cur" ] && local _fasd_cur="\${words[CURRENT]}"
  local fnd="\${_fasd_cur//,/ }"
  local typ=\${1:-e}
  fasd --query \$typ \$fnd | sort -nr | sed 's/^[0-9.]*[ ]*//' | \
    while read line; do
      compadd -U -V fasd "\$line"
    done
  compstate[insert]=menu # no expand
}
_fasd_zsh_word_complete_f() { _fasd_zsh_word_complete f ; }
_fasd_zsh_word_complete_d() { _fasd_zsh_word_complete d ; }
_fasd_zsh_word_complete_trigger() {
  local _fasd_cur="\${words[CURRENT]}"
  eval \$(fasd --word-complete-trigger _fasd_zsh_word_complete \$_fasd_cur)
}
# define zle widgets
zle -C fasd-complete 'menu-select' _fasd_zsh_word_complete
zle -C fasd-complete-f 'menu-select' _fasd_zsh_word_complete_f
zle -C fasd-complete-d 'menu-select' _fasd_zsh_word_complete_d

EOS
        ;;

      zsh-ccomp-install) cat <<EOS
# enbale command mode completion
compctl -U -K _fasd_zsh_cmd_complete -V fasd -x 'C[-1,-*e],s[-]n[1,e]' -c - \
  'c[-1,-A][-1,-D]' -f -- fasd fasd_cd

EOS
        ;;

      zsh-wcomp-install) cat <<EOS
# enable word mode completion
zstyle ':completion:*' completer _complete _ignored \
  _fasd_zsh_word_complete_trigger

EOS
        ;;

      bash-ccomp) cat <<EOS
# bash command mode completion
_fasd_bash_cmd_complete() {
  # complete command after "-e"
  local cur=\${COMP_WORDS[COMP_CWORD]}
  [[ \${COMP_WORDS[COMP_CWORD-1]} == -*e ]] && \
    COMPREPLY=( \$(compgen -A command \$cur) ) && return
  # complete using default readline complete after "-A" or "-D"
  case \${COMP_WORDS[COMP_CWORD-1]} in
    -A|-D) COMPREPLY=( \$(compgen -o default \$cur) ) && return
  esac
  # get completion results using expanded aliases
  local RESULT=\$( fasd -q --complete "\$(alias -p \$COMP_WORDS \
    2>> "$_FASD_SINK" | sed -n "\\\$s/^.*'\(.*\)'/\1/p") \${COMP_LINE#* }" )
  IFS=\$'\n' COMPREPLY=( \$RESULT )
}
_fasd_bash_hook_cmd_complete() {
  for cmd in \$*; do
    complete -F _fasd_bash_cmd_complete \$cmd
  done
}

EOS
        ;;

      bash-wcomp) cat <<EOS
# bash word mode completion
_fasd_bash_word_complete() {
  [ "\$2" ] && local _fasd_cur="\$2"
  [ "\$_fasd_cur" ] || local _fasd_cur="\${COMP_WORDS[COMP_CWORD]}"
  local typ=\${1:-e}
  local fnd="\${_fasd_cur//,/ }"
  local RESULT=\$(fasd -q --query \$typ \$fnd | sed 's/^[0-9.]*[ ]*//')
  IFS=\$'\n' COMPREPLY=( \$RESULT )
} >> "$_FASD_SINK" 2>&1
_fasd_bash_word_complete_trigger() {
  [ "\$_fasd_cur" ] || local _fasd_cur="\${COMP_WORDS[COMP_CWORD]}"
  eval "\$(fasd --word-complete-trigger _fasd_bash_word_complete \$_fasd_cur)"
} >> "$_FASD_SINK" 2>&1
_fasd_bash_word_complete_wrap() {
  local _fasd_cur="\${COMP_WORDS[COMP_CWORD]}"
  _fasd_bash_word_complete_trigger
  local z=\${COMP_WORDS[0]}
  # try original comp func
  [ "\$COMPREPLY" ] || eval "\$( echo "\$_FASD_BASH_COMPLETE_P" | \
    sed -n "/ \$z\$/"'s/.*-F \(.*\) .*/\1/p' )"
  # fall back on original complete options
  local cmd="\$(echo "\$_FASD_BASH_COMPLETE_P" | \
    sed -n "/ \$z\$/"'s/complete/compgen/') \$_fasd_cur"
  [ "\$COMPREPLY" ] || COMPREPLY=( \$(eval \$cmd) )
} >> "$_FASD_SINK" 2>&1

EOS
        ;;

      bash-ccomp-install) cat <<EOS
# enable bash command mode completion
_fasd_bash_hook_cmd_complete fasd a s d f sd sf z

EOS
        ;;

      bash-wcomp-install) cat <<EOS
_FASD_BASH_COMPLETE_P="\$(complete -p)"
for cmd in \$(complete -p | awk '{print \$NF}' | tr '\n' ' '); do
  complete -o default -o bashdefault -F _fasd_bash_word_complete_wrap \$cmd
done
# enable word mode completion as default completion
complete -o default -o bashdefault -D -F _fasd_bash_word_complete_trigger \
  >> "$_FASD_SINK" 2>&1

EOS
        ;;
      esac; shift
    done
    ;;

  --init-alias)
    fasd --init posix-alias
    ;;

  --init-zsh)
    fasd --init zsh-hook zsh-ccomp zsh-ccomp-install zsh-wcomp zsh-wcomp-install
    ;;

  --init-bash)
    fasd --init bash-hook bash-ccomp bash-ccomp-install
    ;;

  --init-posix)
    fasd --init posix-hook
    ;;

  # if "$_fasd_cur" is a query, then eval all the arguments
  --word-complete-trigger)
    shift; [ "$2" ] && local _fasd_cur="$2" || return
    case "$_fasd_cur" in
      ,*) echo "$1" e "$_fasd_cur";;
      f,*) echo "$1" f "${_fasd_cur#?}";;
      d,*) echo "$1" d "${_fasd_cur#?}";;
      *,,) echo "$1" e "$_fasd_cur";;
      *,,f) echo "$1" f "${_fasd_cur%?}";;
      *,,d) echo "$1" d "${_fasd_cur%?}";;
    esac
    ;;

  --sanitize)
    shift; echo "$@" | \
      sed 's/\([^\]\)$([^ ]*\([^)]*\)))*/\1\2/g;s/\([^\]\)[|&;<>$`]\{1,\}/\1 /g'
    ;;

  --proc) shift # process commands
    # stop if we don't own ~/.fasd (we're another user but our ENV is still set)
    [ -f "$_FASD_DATA" -a ! -O "$_FASD_DATA" ] && return

    # make zsh do word splitting for the for loop to work
    [ "$ZSH_VERSION" ] && emulate sh && setopt localoptions

    # blacklists
    local each; for each in $_FASD_BLACKLIST; do
      case " $* " in *\ $each\ *) return;; esac
    done

    # shifts
    while true; do
      case " $_FASD_SHIFT " in
        *\ $1\ *) shift;;
        *) break
      esac
    done

    # ignores
    case " $_FASD_IGNORE " in
      *\ $1\ *) return
    esac

    shift; fasd --add "$@" # add all arguments except command
    ;;

  --add|-A) shift # add entries
    # find all valid path arguments, convert them to simplest absolute form
    local paths="$(while [ "$1" ]; do
      [ -e "$1" ] && echo "$1"; shift
    done | sed '/^[^/]/s@^@'"$PWD"'/@
      s@/\.\.$@/\.\./@;s@/\(\./\)\{1,\}@/@g;: 0;s@[^/][^/]*//*\.\./@/@;t 0
      s@^/*\.\./@/@;s@//*@/@g;s@/\.\{0,1\}$@@;s@^$@/@' | tr '\n' '|')"

    # add current pwd if the option is set
    [ "$_FASD_TRACK_PWD" = "1" -a "$PWD" != "$HOME" ] && paths="$paths|$PWD"

    [ -z "${paths##\|}" ] && return # stop if we have nothing to add

    # maintain the file
    local tempfile
    tempfile="$(mktemp "$_FASD_DATA".XXXXXX)" || return
    $_FASD_AWK -v list="$paths" -v now="$(date +%s)" -v max="$_FASD_MAX" -F"|" '
      BEGIN {
        split(list, files, "|")
        for(i in files) {
          path = files[i]
          if(path == "") continue
          paths[path] = path # array for checking
          rank[path] = 1
          time[path] = now
        }
      }
      $2 >= 1 {
        if($1 in paths) {
          rank[$1] = $2 + 1
          time[$1] = now
        } else {
          rank[$1] = $2
          time[$1] = $3
        }
        count += $2
      }
      END {
        if(count > max)
          for(i in rank) print i "|" 0.9*rank[i] "|" time[i] # aging
        else
          for(i in rank) print i "|" rank[i] "|" time[i]
      }' "$_FASD_DATA" 2>> "$_FASD_SINK" >| "$tempfile"
    if [ $? -ne 0 -a -f "$_FASD_DATA" ]; then
      env rm -f "$tempfile"
    else
      env mv -f "$tempfile" "$_FASD_DATA"
    fi
    ;;

  --delete|-D) shift # delete entries
    # turn valid arguments into entry-deleting sed commands
    local sed_cmd="$(while [ "$1" ]; do echo "$1"; shift; done | \
      sed '/^[^/]/s@^@'"$PWD"'/@;s@/\.\.$@/\.\./@;s@/\(\./\)\{1,\}@/@g
        : 0;s@[^/][^/]*//*\.\./@/@;t 0;s@^/*\.\./@/@;s@//*@/@g;s@/\.\{0,1\}$@@
        s@^$@/@;s@\([.[/*^$]\)@\\\1@g;s@^\(.*\)$@/^\1|/d@')"

    # maintain the file
    local tempfile
    tempfile="$(mktemp "$_FASD_DATA".XXXXXX)" || return

    sed -e "$sed_cmd" "$_FASD_DATA" 2>> "$_FASD_SINK" >| "$tempfile"

    if [ $? -ne 0 -a -f "$_FASD_DATA" ]; then
      env rm -f "$tempfile"
    else
      env mv -f "$tempfile" "$_FASD_DATA"
    fi
    ;;

  --query) shift # query the db, --query [$typ ["$fnd" [$mode [$quote]]]]
    [ -f "$_FASD_DATA" ] || return # no db yet
    [ "$1" ] && local typ="$1"
    [ "$2" ] && local fnd="$2"
    [ "$3" ] && local mode="$3"
    [ "$4" ] && local quote="$4"
    [ "$quote" ] && local qts='"\""' || local qts=

    # make zsh do word spliting for the for loop to work
    [ "$ZSH_VERSION" ] && emulate sh && setopt localoptions

    # cat all backends
    local each _fasd_data; for each in $_FASD_BACKENDS; do
      _fasd_data="$_fasd_data
$(fasd --backend $each)"
    done
    [ "$_fasd_data" ] || _fasd_data="$(cat "$_FASD_DATA")"

    # set mode specific code for calculating the prior
    case $mode in
      rank) local prior='times[i]';;
      recent) local prior='sqrt(100000/(1+t-la[i]))';;
      *) local prior='times[i] * frecent(la[i])';;
    esac

    # query the database
    echo "$_fasd_data" | while read line; do
      [ -${typ:-e} "${line%%\|*}" ] && echo "$line"
    done | $_FASD_AWK -v t="$(date +%s)" -v q="$fnd" -F"|" '
      function frecent(time) {
        dx = t-time
        if( dx < 3600 ) return 6
        if( dx < 86400 ) return 4
        if( dx < 604800 ) return 2
        return 1
      }
      function likelihood(pattern, path) {
        m = gsub("/+", "/", path)
        r = 1
        for(i in pattern) {
          tmp = path
          gsub(".*" pattern[i], "", tmp)
          n = gsub("/+", "/", tmp)
          if(n == m)
            return 0
          else if(n == 0)
            r *= 20 # F
          else
            r *= 1 - (n / m)
        }
        return r
      }
      BEGIN {
        split(q, pattern, " ")
        for(i in pattern) pattern_lower[i] = tolower(pattern[i]) # nocase
      }
      {
        if(!wcase[$1]) {
          times[$1] = $2
          la[$1] = $3
          wcase[$1] = likelihood(pattern, $1)
          if(!cx) nocase[$1] = likelihood(pattern_lower, tolower($1))
        } else {
          times[$1] += $2
          if($3 > la[$1]) la[$1] = $3
        }
        cx = cx || wcase[$1]
        ncx = ncx || nocase[$1]
      }
      END {
        if(cx) {
          for(i in wcase) {
            if(wcase[i])
              printf "%-10s %s\n", '"$prior"' * wcase[i], '"$qts"' i '"$qts"'
          }
        } else if(ncx) {
          for(i in nocase) {
            if(nocase[i])
              printf "%-10s %s\n", '"$prior"' * nocase[i], '"$qts"' i '"$qts"'
          }
        }
      }' - 2>> "$_FASD_SINK"
    ;;

  --backend)
    case $2 in
      native) cat "$_FASD_DATA";;
      viminfo)
        local t="$(date +%s)"
        < "$HOME/.viminfo" sed -n '/^>/{s@~@'"$HOME"'@;p}' | \
          while IFS=" " read line; do
            t=$((t-60)); echo "${line#??}|1|$t"
          done
        ;;
      recently-used)
        tr -d '\n' < "$HOME/.local/share/recently-used.xbel" | \
          sed 's@file:/@\n@g;s@count="@\n@g' | sed '1d;s/".*$//' | \
          tr '\n' '|' | sed 's@|/@\n@g' | $_FASD_AWK -F'|' '{
            sum = 0
            for( i=2; i<=NF; i++ ) sum += $i
            print $1 "|" sum
          }'
        ;;
      *) eval "$2";;
    esac
    ;;

  *) # parsing logic and processing
    local fnd last _FASD_BACKENDS="$_FASD_BACKENDS" _fasd_data
    while [ "$1" ]; do case "$1" in
      --complete) [ "$2" = "--" ] && shift; set -- $(echo $2); local lst=1 r=r;;
      --query|--add|--delete|-A|-D) fasd "$@"; return $?;;
      --version) echo "0.5.4"; return 0;;
      --) while [ "$2" ]; do shift; fnd="$fnd$1 "; last="$1"; done;;
      -*) local o="${1#-}"; while [ "$o" ]; do case "$o" in
          s*) local show=1;;
          l*) local lst=1;;
          i*) local interactive=1 show=1;;
          r*) local mode=rank;;
          t*) local mode=recent;;
          e*) o="${o#?}"; if [ "$o" ]; then # there are characters after "-e"
                local exec="$o" # anything after "-e"
              else # use the next argument
                local exec="${2:?"-e: Argument needed "}"
                shift
              fi; break;;
          b*) o="${o#?}"; if [ "$o" ]; then
                _FASD_BACKENDS="$o"
              else
                _FASD_BACKENDS="${2:?"-b: Argument needed"}"
                shift
              fi; break;;
          B*) o="${o#?}"; if [ "$o" ]; then
                _FASD_BACKENDS="$_FASD_BACKENDS $o"
              else
                _FASD_BACKENDS="$_FASD_BACKENDS ${2:?"-B: Argument needed"}"
                shift
              fi; break;;
          a*) local typ=e;;
          d*) local typ=d;;
          f*) local typ=f;;
          q*) local quote=1;;
          h*) echo "fasd [options] [query ...]
[f|a|s|d|z] [opions] [query ...]
  options:
    -s         show list of files with their ranks
    -l         list paths only
    -i         interactive mode
    -e <cmd>   set command to execute on the result file
    -b <name>  only use <name> backend
    -b <name>  add additional backend <name>
    -a         match files and directories
    -d         match directories only
    -f         match files only
    -r         match by rank only
    -t         match by recent access only
    -h         show a brief help message

fasd [-A|-D] [paths ...]
    -A    add paths
    -D    delete paths" >&2; return;;
        esac; o="${o#?}"; done;;
      *) fnd="$fnd $1"; last="$1";;
    esac; shift; done

    # if we hit enter on a completion just execute
    case "$last" in
     # completions will always start with /
     /*) [ -z "$show$lst" -a -${typ:-e} "$last" -a "$exec" ] \
       && eval $exec "\"$last\"" && return;;
    esac

    local result
    result="$(fasd --query 2>> "$_FASD_SINK")" # query the database
    [ $? -gt 0 ] && return
    if [ "$interactive" ] || [ "$exec" -a -z "$fnd$lst$show" -a -t 1 ]; then
      result="$(echo "$result" | sort -nr)"
      echo "$result" | sed = | sed 'N;s/\n/	/' | sort -nr >&2; printf "> " >&2
      local i; read i; [ 0 -lt "${i:-0}" ] 2>> "$_FASD_SINK" || return 1
      result="$(echo "$result" | sed -n "${i:-1}"'s/^[0-9.]*[ ]*//p')"
      if [ "$result" ]; then
        fasd --add "$result"; eval ${exec:-echo} "\"$result\""
      fi
    elif [ "$lst" ]; then
      echo "$result" | sort -n${r} | sed 's/^[0-9.]*[ ]*//'
    elif [ "$show" ]; then
      echo "$result" | sort -n
    elif [ "$fnd" -a "$exec" ]; then # exec
      result="$(echo "$result" | sort -n | sed -n '$s/^[0-9.]*[ ]*//p')"
      fasd --add "$result"; eval $exec "\"$result\""
    elif [ "$fnd" -a ! -t 1 ]; then # echo if output is not terminal
      result="$(echo "$result" | sort -n | sed -n '$s/^[0-9.]*[ ]*//p')"
      fasd --add "$result"; echo "$result"
    else # no args, show
      echo "$result" | sort -n
    fi

  esac
}

fasd --init env

case $- in
  *i*) cite about-plugin
       about-plugin 'navigate "frecently" used files and directories'
       eval "$(fasd --init auto)"
      ;;
  *) # assume being executed as an executable
    if [ -x "$_FASD_SHELL" -a -z "$_FASD_SET" ]; then
      _FASD_SET=1 exec $_FASD_SHELL "$0" "$@"
    else
      fasd "$@"
    fi
esac

