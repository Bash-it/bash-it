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

  # make zsh do word splitting inside this function
  [ "$ZSH_VERSION" ] && emulate sh && setopt localoptions

  case $1 in
  --init) shift
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
          [ -z "$_FASD_IGNORE" ] && _FASD_IGNORE="fasd ls echo"
          [ -z "$_FASD_SINK" ] && _FASD_SINK=/dev/null
          [ -z "$_FASD_TRACK_PWD" ] && _FASD_TRACK_PWD=1
          [ -z "$_FASD_MAX" ] && _FASD_MAX=2000
          [ -z "$_FASD_BACKENDS" ] && _FASD_BACKENDS=native
          [ -z "$_FASD_FUZZY" ] && _FASD_FUZZY=2
          [ -z "$_FASD_VIMINFO" ] && _FASD_VIMINFO="$HOME/.viminfo"
          [ -z "$_FASD_RECENTLY_USED_XBEL" ] && \
            _FASD_RECENTLY_USED_XBEL="$HOME/.local/share/recently-used.xbel"

          if [ -z "$_FASD_AWK" ]; then
            # awk preferences
            local awk; for awk in mawk gawk original-awk nawk awk; do
              $awk "" && _FASD_AWK=$awk && break
            done
          fi
        } >> "${_FASD_SINK:-/dev/null}" 2>&1
        ;;

      auto) cat <<EOS
{ if [ "\$ZSH_VERSION" ] && compctl; then # zsh
    eval "\$(fasd --init posix-alias zsh-hook zsh-ccomp zsh-ccomp-install \\
      zsh-wcomp zsh-wcomp-install)"
  elif [ "\$BASH_VERSION" ] && complete; then # bash
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
fasd_cd() {
  if [ \$# -le 1 ]; then
    fasd "\$@"
  else
    local _fasd_ret="\$(fasd -e 'printf %s' "\$@")"
    [ -z "\$_fasd_ret" ] && return
    [ -d "\$_fasd_ret" ] && cd "\$_fasd_ret" || printf %s\\n "\$_fasd_ret"
  fi
}
alias z='fasd_cd -d'
alias zz='fasd_cd -d -i'

EOS
        ;;

      tcsh-alias) cat <<EOS
;alias a 'fasd -a';
alias s 'fasd -si';
alias sd 'fasd -sid';
alias sf 'fasd -sif';
alias d 'fasd -d';
alias f 'fasd -f';
alias z 'cd "\`fasd -d -e printf\\ %s \\!*\`" >& /dev/null || fasd -d';
EOS
        ;;

      zsh-hook) cat <<EOS
# add zsh hook
_fasd_preexec() {
  { eval "fasd --proc \$(fasd --sanitize \$2)"; } >> "$_FASD_SINK" 2>&1
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _fasd_preexec

EOS
        ;;

      bash-hook) cat <<EOS
_fasd_prompt_func() {
  eval "fasd --proc \$(fasd --sanitize \$(history 1 | \\
    sed "s/^[ ]*[0-9]*[ ]*//"))" >> "$_FASD_SINK" 2>&1
}

# add bash hook
case \$PROMPT_COMMAND in
  *_fasd_prompt_func*) ;;
  *) PROMPT_COMMAND="_fasd_prompt_func;\$PROMPT_COMMAND";;
esac

EOS
        ;;

      posix-hook) cat <<EOS
_fasd_ps1_func() {
  { eval "fasd --proc \$(fasd --sanitize \$(fc -nl -1))"; } \\
    >> "$_FASD_SINK" 2>&1
}
case \$PS1 in
  *_fasd_ps1_func*) ;;
  *) export PS1="\\\$(_fasd_ps1_func)\$PS1";;
esac

EOS
        ;;

      tcsh-hook) cat <<EOS
;alias fasd-prev-cmd 'fasd --sanitize \`history -h 1\`';
set pprecmd="\`alias precmd\`";
alias precmd '\$pprecmd; eval "fasd --proc \`fasd-prev-cmd\`" >& /dev/null';
EOS

        ;;

      zsh-ccomp) cat <<EOS
# zsh command mode completion
_fasd_zsh_cmd_complete() {
  local compl
  read -c compl
  (( \$+compstate )) && compstate[insert]=menu # no expand if compsys loaded
  reply=(\${(f)"\$(fasd --complete "\$compl")"})
}

EOS
        ;;

      zsh-wcomp) cat <<EOS
(( \$+functions[compdef] )) && {
  # zsh word mode completion
  _fasd_zsh_word_complete() {
    [ "\$2" ] && local _fasd_cur="\$2"
    [ -z "\$_fasd_cur" ] && local _fasd_cur="\${words[CURRENT]}"
    local fnd="\${_fasd_cur//,/ }"
    local typ=\${1:-e}
    fasd --query \$typ "\$fnd" 2>> "$_FASD_SINK" | \\
      sort -nr | sed 's/^[^ ]*[ ]*//' | while read -r line; do
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
  zle -C fasd-complete complete-word _generic
  zstyle ':completion:fasd-complete:*' completer _fasd_zsh_word_complete
  zstyle ':completion:fasd-complete:*' menu-select

  zle -C fasd-complete-f complete-word _generic
  zstyle ':completion:fasd-complete-f:*' completer _fasd_zsh_word_complete_f
  zstyle ':completion:fasd-complete-f:*' menu-select

  zle -C fasd-complete-d complete-word _generic
  zstyle ':completion:fasd-complete-d:*' completer _fasd_zsh_word_complete_d
  zstyle ':completion:fasd-complete-d:*' menu-select
}

EOS
        ;;

      zsh-ccomp-install) cat <<EOS
# enable command mode completion
compctl -U -K _fasd_zsh_cmd_complete -V fasd -x 'C[-1,-*e],s[-]n[1,e]' -c - \\
  'c[-1,-A][-1,-D]' -f -- fasd fasd_cd

EOS
        ;;

      zsh-wcomp-install) cat <<EOS
(( \$+functions[compdef] )) && {
  # enable word mode completion
  orig_comp="\$(zstyle -L ':completion:\\*' completer 2>> "$_FASD_SINK")"
  if [ "\$orig_comp" ]; then
    case \$orig_comp in
      *_fasd_zsh_word_complete_trigger*);;
      *) eval "\$orig_comp _fasd_zsh_word_complete_trigger";;
    esac
  else
    zstyle ':completion:*' completer _complete _fasd_zsh_word_complete_trigger
  fi
  unset orig_comp
}

EOS
        ;;

      bash-ccomp) cat <<EOS
# bash command mode completion
_fasd_bash_cmd_complete() {
  # complete command after "-e"
  local cur=\${COMP_WORDS[COMP_CWORD]}
  [[ \${COMP_WORDS[COMP_CWORD-1]} == -*e ]] && \\
    COMPREPLY=( \$(compgen -A command \$cur) ) && return
  # complete using default readline complete after "-A" or "-D"
  case \${COMP_WORDS[COMP_CWORD-1]} in
    -A|-D) COMPREPLY=( \$(compgen -o default \$cur) ) && return;;
  esac
  # get completion results using expanded aliases
  local RESULT=\$( fasd --complete "\$(alias -p \$COMP_WORDS \\
    2>> "$_FASD_SINK" | sed -n "\\\$s/^.*'\\\\(.*\\\\)'/\\\\1/p")
    \${COMP_LINE#* }" | while read -r line; do
      quote_readline "\$line" 2>/dev/null || \\
        printf %q "\$line" 2>/dev/null  && \\
        printf \\\\n
    done)
  local IFS=\$'\\n'; COMPREPLY=( \$RESULT )
}
_fasd_bash_hook_cmd_complete() {
  for cmd in \$*; do
    complete -F _fasd_bash_cmd_complete \$cmd
  done
}

EOS
        ;;

      bash-ccomp-install) cat <<EOS
# enable bash command mode completion
_fasd_bash_hook_cmd_complete fasd a s d f sd sf z zz

EOS
        ;;
      esac; shift
    done
    ;;

  # if "$_fasd_cur" or "$2" is a query, then output shell code to be eval'd
  --word-complete-trigger)
    shift; [ "$2" ] && local _fasd_cur="$2" || return
    case $_fasd_cur in
      ,*) printf %s\\n "$1 e $_fasd_cur";;
      f,*) printf %s\\n "$1 f ${_fasd_cur#?}";;
      d,*) printf %s\\n "$1 d ${_fasd_cur#?}";;
      *,,) printf %s\\n "$1 e $_fasd_cur";;
      *,,f) printf %s\\n "$1 f ${_fasd_cur%?}";;
      *,,d) printf %s\\n "$1 d ${_fasd_cur%?}";;
    esac
    ;;

  --sanitize) shift; printf %s\\n "$*" | \
      sed 's/\([^\]\)$( *[^ ]* *\([^)]*\)))*/\1\2/g
        s/\([^\]\)[|&;<>$`{}]\{1,\}/\1 /g'
    ;;

  --proc) shift # process commands
    # stop if we don't own $_FASD_DATA or $_FASD_RO is set
    [ -f "$_FASD_DATA" -a ! -O "$_FASD_DATA" ] || [ "$_FASD_RO" ] && return

    # blacklists
    local each; for each in $_FASD_BLACKLIST; do
      case " $* " in *\ $each\ *) return;; esac
    done

    # shifts
    while true; do
      case " $_FASD_SHIFT " in
        *\ $1\ *) shift;;
        *) break;;
      esac
    done

    # ignores
    case " $_FASD_IGNORE " in
      *\ $1\ *) return;;
    esac

    shift; fasd --add "$@" # add all arguments except command
    ;;

  --add|-A) shift # add entries
    # stop if we don't own $_FASD_DATA or $_FASD_RO is set
    [ -f "$_FASD_DATA" -a ! -O "$_FASD_DATA" ] || [ "$_FASD_RO" ] && return

    # find all valid path arguments, convert them to simplest absolute form
    local paths="$(while [ "$1" ]; do
      [ -e "$1" ] && printf %s\\n "$1"; shift
    done | sed '/^[^/]/s@^@'"$PWD"'/@
      s@/\.\.$@/../@;s@/\(\./\)\{1,\}@/@g;:0
      s@[^/][^/]*//*\.\./@/@;t 0
      s@^/*\.\./@/@;s@//*@/@g;s@/\.\{0,1\}$@@;s@^$@/@' 2>> "$_FASD_SINK" \
      | tr '\n' '|')"

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
          rank[$1] = $2 + 1 / $2
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
    # stop if we don't own $_FASD_DATA or $_FASD_RO is set
    [ -f "$_FASD_DATA" -a ! -O "$_FASD_DATA" ] || [ "$_FASD_RO" ] && return

    # turn valid arguments into entry-deleting sed commands
    local sed_cmd="$(while [ "$1" ]; do printf %s\\n "$1"; shift; done | \
      sed '/^[^/]/s@^@'"$PWD"'/@;s@/\.\.$@/../@;s@/\(\./\)\{1,\}@/@g;:0
        s@[^/][^/]*//*\.\./@/@;t 0
        s@^/*\.\./@/@;s@//*@/@g;s@/\.\{0,1\}$@@
        s@^$@/@;s@\([.[\/*^$]\)@\\\1@g;s@^\(.*\)$@/^\1|/d@' 2>> "$_FASD_SINK")"

    # maintain the file
    local tempfile
    tempfile="$(mktemp "$_FASD_DATA".XXXXXX)" || return

    sed "$sed_cmd" "$_FASD_DATA" 2>> "$_FASD_SINK" >| "$tempfile"

    if [ $? -ne 0 -a -f "$_FASD_DATA" ]; then
      env rm -f "$tempfile"
    else
      env mv -f "$tempfile" "$_FASD_DATA"
    fi
    ;;

  --query) shift # query the db, --query [$typ ["$fnd" [$mode]]]
    [ -f "$_FASD_DATA" ] || return # no db yet
    [ "$1" ] && local typ="$1"
    [ "$2" ] && local fnd="$2"
    [ "$3" ] && local mode="$3"

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

    if [ "$fnd" ]; then # dafault matching
      local bre="$(printf %s\\n "$fnd" | sed 's/\([*\.\\\[]\)/\\\1/g
        s@ @[^|]*@g;s/\$$/|/')"
      bre='^[^|]*'"$bre"'[^|/]*|'
      local _ret="$(printf %s\\n "$_fasd_data" | grep "$bre")"
      [ "$_ret" ] && _ret="$(printf %s\\n "$_ret" | while read -r line; do
        [ -${typ:-e} "${line%%\|*}" ] && printf %s\\n "$line"
      done)"
      if [ "$_ret" ]; then
        _fasd_data="$_ret"
      else # no case mathcing
        _ret="$(printf %s\\n "$_fasd_data" | grep -i "$bre")"
        [ "$_ret" ] && _ret="$(printf %s\\n "$_ret" | while read -r line; do
          [ -${typ:-e} "${line%%\|*}" ] && printf %s\\n "$line"
        done)"
        if [ "$_ret" ]; then
          _fasd_data="$_ret"
        elif [ "${_FASD_FUZZY:-0}" -gt 0 ]; then # fuzzy matching
          local fuzzy_bre="$(printf %s\\n "$fnd" | \
            sed 's/\([*\.\\\[]\)/\\\1/g;s/\$$/|/
              s@\(\\\{0,1\}[^ ]\)@\1[^|/]\\{0,'"$_FASD_FUZZY"'\\}@g
              s@ @[^|]*@g')"
          fuzzy_bre='^[^|]*'"$fuzzy_bre"'[^|/]*|'
          _ret="$(printf %s\\n "$_fasd_data" | grep -i "$fuzzy_bre")"
          [ "$_ret" ] && _ret="$(printf %s\\n "$_ret" | while read -r line; do
            [ -${typ:-e} "${line%%\|*}" ] && printf %s\\n "$line"
          done)"
          [ "$_ret" ] && _fasd_data="$_ret" || _fasd_data=
        fi
      fi
    else # no query arugments
      _fasd_data="$(printf %s\\n "$_fasd_data" | while read -r line; do
        [ -${typ:-e} "${line%%\|*}" ] && printf %s\\n "$line"
      done)"
    fi

    # query the database
    [ "$_fasd_data" ] && printf %s\\n "$_fasd_data" | \
      $_FASD_AWK -v t="$(date +%s)" -F"|" '
      function frecent(time) {
        dx = t-time
        if( dx < 3600 ) return 6
        if( dx < 86400 ) return 4
        if( dx < 604800 ) return 2
        return 1
      }
      {
        if(!paths[$1]) {
          times[$1] = $2
          la[$1] = $3
          paths[$1] = 1
        } else {
          times[$1] += $2
          if($3 > la[$1]) la[$1] = $3
        }
      }
      END {
        for(i in paths) printf "%-10s %s\n", '"$prior"', i
      }' - 2>> "$_FASD_SINK"
    ;;

  --backend)
    case $2 in
      native) cat "$_FASD_DATA";;
      viminfo)
        < "$_FASD_VIMINFO" sed -n '/^>/{s@~@'"$HOME"'@
          s/^..//
          p
          }' | $_FASD_AWK -v t="$(date +%s)" '{
            t -= 60
            print $0 "|1|" t
          }'
        ;;
      recently-used)
        local nl="$(printf '\\\nX')"; nl="${nl%X}" # slash newline for sed
        tr -d '\n' < "$_FASD_RECENTLY_USED_XBEL" | \
          sed 's@file:/@'"$nl"'@g;s@count="@'"$nl"'@g' | sed '1d;s/".*$//' | \
          tr '\n' '|' | sed 's@|/@'"$nl"'@g' | $_FASD_AWK -F'|' '{
            sum = 0
            for( i=2; i<=NF; i++ ) sum += $i
            print $1 "|" sum
          }'
        ;;
      current)
        for path in *; do
          printf "$PWD/%s|1\\n" "$path"
        done
        ;;
      spotlight)
        mdfind '(kMDItemFSContentChangeDate >= $time.today) ||
          kMDItemLastUsedDate >= $time.this_month' \
          | sed '/Library\//d
            /\.app$/d
            s/$/|2/'
        ;;
      *) eval "$2";;
    esac
    ;;

  *) # parsing logic and processing
    local fnd= last= _FASD_BACKENDS="$_FASD_BACKENDS" _fasd_data= comp= exec=
    while [ "$1" ]; do case $1 in
      --complete) [ "$2" = "--" ] && shift; set -- $2; local lst=1 r=r comp=1;;
      --query|--add|--delete|-A|-D) fasd "$@"; return $?;;
      --version) [ -z "$comp" ] && echo "1.0.1" && return;;
      --) while [ "$2" ]; do shift; fnd="$fnd $1"; last="$1"; done;;
      -*) local o="${1#-}"; while [ "$o" ]; do case $o in
          s*) local show=1;;
          l*) local lst=1;;
          i*) [ -z "$comp" ] && local interactive=1 show=1;;
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
          R*) local r=r;;
      [0-9]*) local _fasd_i="$o"; break;;
          h*) [ -z "$comp" ] && echo "fasd [options] [query ...]
[f|a|s|d|z] [options] [query ...]
  options:
    -s         list paths with scores
    -l         list paths without scores
    -i         interactive mode
    -e <cmd>   set command to execute on the result file
    -b <name>  only use <name> backend
    -B <name>  add additional backend <name>
    -a         match files and directories
    -d         match directories only
    -f         match files only
    -r         match by rank only
    -t         match by recent access only
    -R         reverse listing order
    -h         show a brief help message
    -[0-9]     select the nth entry

fasd [-A|-D] [paths ...]
    -A    add paths
    -D    delete paths" >&2 && return;;
        esac; o="${o#?}"; done;;
      *) fnd="$fnd $1"; last="$1";;
    esac; shift; done

    # guess whether the last query is selected from tab completion
    case $last in
      /?*) if [ -z "$show$lst" -a -${typ:-e} "$last" -a "$exec" ]; then
             $exec "$last"
             return
           fi;;
    esac

    local R; [ -z "$r" ] && R=r || R= # let $R be the opposite of $r
    fnd="${fnd# }"

    local res
    res="$(fasd --query 2>> "$_FASD_SINK")" # query the database
    [ $? -gt 0 ] && return
    if [ 0 -lt ${_fasd_i:-0} ] 2>> "$_FASD_SINK"; then
      res="$(printf %s\\n "$res" | sort -n${R} | \
        sed -n "$_fasd_i"'s/^[^ ]*[ ]*//p')"
    elif [ "$interactive" ] || [ "$exec" -a -z "$fnd$lst$show" -a -t 1 ]; then
      if [ "$(printf %s "$res" | sed -n '$=')" -gt 1 ]; then
        res="$(printf %s\\n "$res" | sort -n${R})"
        printf %s\\n "$res" | sed = | sed 'N;s/\n/	/' | sort -nr >&2
        printf "> " >&2
        local i; read i; [ 0 -lt "${i:-0}" ] 2>> "$_FASD_SINK" || return 1
      fi
      res="$(printf %s\\n "$res" | sed -n "${i:-1}"'s/^[^ ]*[ ]*//p')"
    elif [ "$lst" ]; then
      [ "$res" ] && printf %s\\n "$res" | sort -n${r} | sed 's/^[^ ]*[ ]*//'
      return
    elif [ "$show" ]; then
      [ "$res" ] && printf %s\\n "$res" | sort -n${r}
      return
    elif [ "$fnd" ] && [ "$exec" -o ! -t 1 ]; then # exec or subshell
      res="$(printf %s\\n "$res" | sort -n | sed -n '$s/^[^ ]*[ ]*//p')"
    else # no args, show
      [ "$res" ] && printf %s\\n "$res" | sort -n${r}
      return
    fi
    if [ "$res" ]; then
      fasd --add "$res"
      [ -z "$exec" ] && exec='printf %s\n'
      $exec "$res"
    fi
    ;;
  esac
}

fasd --init env

case $- in
  *i*) ;; # assume being sourced, do nothing
  *) # assume being executed as an executable
    if [ -x "$_FASD_SHELL" -a -z "$_FASD_SET" ]; then
      _FASD_SET=1 exec $_FASD_SHELL "$0" "$@"
    else
      fasd "$@"
    fi;;
esac

