# ------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ------------------------------------------------------------

# Programmable completion for the Subversion svn command under bash. Source
# this file (or on some systems add it to ~/.bash_completion and start a new
# shell) and bash's completion mechanism will know all about svn's options!
# Provides completion for the svnadmin, svndumpfilter, svnlook and svnsync
# commands as well.  Who wants to read man pages/help text...

# Known to work with bash 3.* with programmable completion and extended
# pattern matching enabled (use 'shopt -s extglob progcomp' to enable
# these if they are not already enabled).

shopt -s extglob

# Tree helper functions which only use bash, to ease readability.

# look for value associated to key from stdin in K/V hash file format
# val=$(_svn_read_hashfile svn:realmstring < some/file)
function _svn_read_hashfile()
{
  local tkey=$1 key= val=
  while true; do
    read tag len
    [ $tag = 'END' ] && break
    [ $tag != 'K' ] && {
      #echo "unexpected tag '$tag' instead of 'K'" >&2
      return
    }
    read -r -n $len key ; read
    read tag len
    [ $tag != 'V' ] && {
      #echo "unexpected tag '$tag' instead of 'V'" >&2
      return
    }
    read -r -n $len val ; read
    if [[ $key = $tkey ]] ; then
      echo "$val"
      return
    fi
  done
  #echo "target key '$tkey' not found" >&2
}

# _svn_grcut shell-regular-expression
# extract filenames from 'svn status' output
function _svn_grcut()
{
    local re=$1 line= old_IFS
    # fix IFS, so that leading spaces are not ignored by next read.
    # (there is a leading space in svn status output if only a prop is changed)
    old_IFS="$IFS"
    IFS=$'\n'
    while read -r line ; do
	[[ ! $re || $line == $re ]] && echo "${line/????????/}"
    done
    IFS="$old_IFS"
}

# extract stuff from svn info output
# _svn_info (URL|Repository Root)
function _svn_info()
{
  local what=$1 line=
  LANG=C LC_MESSAGES=C svn info --non-interactive 2> /dev/null | \
  while read line ; do
    [[ $line == *"$what: "* ]] && echo ${line#*: }
  done
}

# _svn_lls (dir|file|all) files...
# list svn-managed files from list
# some 'svn status --all-files' would be welcome here?
function _svn_lls()
{
    local opt=$1 f=
    shift
    for f in "$@" ; do
	# could try to check in .svn/entries? hmmm...
	if [[ $opt == @(dir|all) && -d "$f" ]] ; then
	    echo "$f/"
	elif [[ $opt == @(file|all) ]] ; then
	    # split f in directory/file names
	    local dn= fn="$f"
	    [[ "$f" == */* ]] && dn=${f%\/*}/ fn=${f##*\/}
	    # ??? this does not work for just added files, because they
	    # do not have a content reference yet...
	    [ -f "${dn}.svn/text-base/${fn}.svn-base" ] && echo "$f"
	fi
    done
}

# This completion guides the command/option order along the one suggested
# by "svn help", although other syntaxes are allowed.
#
# - there is a "real" parser to check for what is available and deduce what
#   can be suggested further.
# - the syntax should be coherent with subversion/svn/{cl.h,main.c}
# - although it is not a good practice, mixed options and arguments
#   is supported by the completion as it is by the svn command.
# - the completion works in the middle of a line,
#   but not really in the middle of an argument or option.
# - property names are completed: see comments about issues related to handling
#   ":" within property names although it is a word completion separator.
# - unknown properties are assumed to be simple file properties.
# - --revprop and --revision options are forced to revision properties
#   as they are mandatory in this case.
# - argument values are suggested to some other options, eg directory names
#   for --config-dir.
# - values for some options can be extended with environment variables:
#   SVN_BASH_FILE_PROPS: other properties on files/directories
#   SVN_BASH_REV_PROPS: other properties on revisions
#   SVN_BASH_ENCODINGS: encodings to be suggested
#   SVN_BASH_MIME_TYPE: mime types to be suggested
#   SVN_BASH_KEYWORDS: "svn:keywords" substitutions to be suggested
#   SVN_BASH_USERNAME: usernames suggested for --username
#   SVN_BASH_COMPL_EXT: completion extensions for file arguments, based on the
#      current subcommand, so that for instance only modified files are
#      suggested for 'revert', only not svn-managed files for 'add', and so on.
#      Possible values are:
#      - username: guess usernames from ~/.subversion/auth/...
#      - urls: guess urls from ~/.subversion/auth/... or others
#      - svnstatus: use 'svn status' for completion
#      - recurse: allow recursion (expensive)
#      - externals: recurse into externals (very expensive)
#     Former options are reasonable, but beware that both later options
#     may be unadvisable if used on large working copies.
#     None of these costly completions are activated by default.
#     Argument completion outside a working copy results in an error message.
#     Filenames with spaces are not completed properly.
#
# TODO
# - other options?
# - obsolete options could be removed from auto-comp? (e.g. -N)
# - obsolete commands could be removed? (e.g. resolved)
# - completion does not work properly when editing in the middle of the line
#   status/previous are those at the end of the line, not at the entry position
# - url completion should select more cases where it is relevant
# - url completion of http:// schemas could suggest sub directories?
# - add completion for experimental 'obliterate' feature?
_svn()
{
	local cur cmds cmdOpts pOpts mOpts rOpts qOpts nOpts optsParam opt

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# Possible expansions, without pure-prefix abbreviations such as "up".
	cmds='add blame annotate praise cat changelist cl checkout co cleanup'
	cmds="$cmds commit ci copy cp delete remove rm diff export help import"
	cmds="$cmds info list ls lock log merge mergeinfo mkdir move mv rename"
	cmds="$cmds patch propdel pdel propedit pedit propget pget proplist"
	cmds="$cmds plist propset pset relocate resolve resolved revert status"
	cmds="$cmds  switch unlock update upgrade"

	# help options have a strange command status...
	local helpOpts='--help -h'
	# all special options that have a command status
	local specOpts="--version $helpOpts"

	# options that require a parameter
	# note: continued lines must end '|' continuing lines must start '|'
	optsParam="-r|--revision|--username|--password|--targets"
	optsParam="$optsParam|-x|--extensions|-m|--message|-F|--file"
	optsParam="$optsParam|--encoding|--diff-cmd|--diff3-cmd|--editor-cmd"
	optsParam="$optsParam|--old|--new|--config-dir|--config-option"
	optsParam="$optsParam|--native-eol|-l|--limit|-c|--change"
	optsParam="$optsParam|--depth|--set-depth|--with-revprop"
	optsParam="$optsParam|--cl|--changelist|--accept|--show-revs"

	# svn:* and other (env SVN_BASH_*_PROPS) properties
	local svnProps revProps allProps psCmds propCmds

	# svn and user configured "file" (or directory) properties
	# the "svn:mergeinfo" prop is not included by default because it is
	# managed automatically, so there should be no need to edit it by hand.
	svnProps="svn:keywords svn:executable svn:needs-lock svn:externals
	          svn:ignore svn:eol-style svn:mime-type $SVN_BASH_FILE_PROPS"

	# svn and user configured revision properties
	revProps="svn:author svn:log svn:date $SVN_BASH_REV_PROPS"

	# all properties as an array variable
	allProps=( $svnProps $revProps )

	# subcommands that expect property names
	psCmds='propset|pset|ps'
	propCmds="$psCmds|propget|pget|pg|propedit|pedit|pe|propdel|pdel|pd"

	# possible URL schemas to access a subversion server
	local urlSchemas='file:/// http:// https:// svn:// svn+ssh://'

	# Parse arguments and set various variables about what was found.
	#
	# cmd: the current command if available
	#    isPropCmd: whether it expects a property name argument
	#    isPsCmd: whether it also expects a property value argument
	#    isHelpCmd: whether it is about help
	#    nExpectArgs: how many arguments are expected by the command
	# help: help requested about this command (if cmd=='help')
	# prop: property name (if appropriate)
	#    isRevProp: is it a special revision property
	# val: property value (if appropriate, under pset)
	# options: all options encountered
	#    hasRevPropOpt: is --revprop set
	#    hasRevisionOpt: is --revision set
	#    hasRelocateOpt: is --relocate set
	#    hasReintegrateOpt: is --reintegrate set
	#    acceptOpt: the value of --accept
	# nargs: how many arguments were found
	# stat: status of parsing at the 'current' word
	#
	# prev: previous command in the loop
	# last: status of last parameter analyzed
	# i: index
	local cmd= isPropCmd= isPsCmd= isHelpCmd= nExpectArgs= isCur= i=0
	local prev= help= prop= val= isRevProp= last='none' nargs=0 stat=
	local options= hasRevPropOpt= hasRevisionOpt= hasRelocateOpt=
	local acceptOpt= URL= hasReintegrateOpt=

	for opt in "${COMP_WORDS[@]}"
	do
	    # get status of current word (from previous iteration)
	    [[ $isCur ]] && stat=$last

	    # are we processing the current word
	    isCur=
	    [[ $i -eq $COMP_CWORD ]] && isCur=1
	    let i++

	    # FIRST must be the "svn" command
	    [ $last = 'none' ] && { last='first'; continue ; }

	    # SKIP option arguments
	    if [[ $prev == @($optsParam) ]] ; then

		# record accept value
		[[ $prev = '--accept' ]] && acceptOpt=$opt

		prev=''
		last='skip'
		continue ;
	    fi

	    # Argh...  This looks like a bash bug...
	    # Redirections are passed to the completion function
	    # although it is managed by the shell directly...
	    # It matters because we want to tell the user when no more
	    # completion is available, so it does not necessary
	    # fallback to the default case.
	    if [[ $prev == @(<|>|>>|[12]>|[12]>>) ]] ; then
		prev=''
		last='skip'
		continue ;
	    fi
	    prev=$opt

	    # get the subCoMmanD
	    if [[ ! $cmd && $opt \
               && ( $opt != -* || $opt == @(${specOpts// /|}) ) ]]
            then
		cmd=$opt
		[[ $cmd == @($propCmds) ]] && isPropCmd=1
		[[ $cmd == @($psCmds) ]] && isPsCmd=1
		[[ $cmd == @(${helpOpts// /|}) ]] && cmd='help'
		[[ $cmd = 'help' ]] && isHelpCmd=1
	        # HELP about a command asked with an option
		if [[ $isHelpCmd && $cmd && $cmd != 'help' && ! $help ]]
		then
		    help=$cmd
		    cmd='help'
		fi
		last='cmd'
		continue
	    fi

	    # HELP about a command
	    if [[ $isHelpCmd && ! $help && $opt && $opt != -* ]]
	    then
		help=$opt
		last='help'
		continue
	    fi

	    # PROPerty name
	    if [[ $isPropCmd && ! $prop && $opt && $opt != -* ]]
	    then
		prop=$opt
		[[ $prop == @(${revProps// /|}) ]] && isRevProp=1
		last='prop'
		continue
	    fi

	    # property VALue
	    if [[ $isPsCmd && $prop && ! $val && $opt != -* ]] ;
	    then
		val=$opt
		last='val'
		continue
	    fi

	    if [[ $last != 'onlyarg' ]]
	    then
	      # more OPTions
	      case $opt in
		  -r|--revision|--revision=*)
		      hasRevisionOpt=1
		      ;;
		  --revprop)
		      hasRevPropOpt=1
		      # restrict to revision properties!
		      allProps=( $revProps )
		      # on revprops, only one URL is expected
		      nExpectArgs=1
		      ;;
		  -h|--help)
		      isHelpCmd=1
		      ;;
		  -F|--file)
		      val='-F'
		      ;;
		  --relocate)
		      hasRelocateOpt=1
		      ;;
		  --reintegrate)
		      hasReintegrateOpt=1
		      ;;
	      esac

	      # no more options, only arguments, whatever they look like.
	      if [[ $opt = '--' && ! $isCur ]] ; then
		  last='onlyarg'
		  continue
	      fi

	      # options are recorded...
	      if [[ $opt == -* ]] ; then
		  # but not the current one!
		  [[ ! $isCur ]] && options="$options $opt "
		  last='opt'
		  continue
	      fi
	    else
		# onlyarg
		let nargs++
		continue
	    fi

	    # then we have an argument
	    if [[ $cmd = 'merge' && ! $URL ]] ; then
              # fist argument is the source URL for the merge
	      URL=$opt
	    fi

	    last='arg'
	    let nargs++
	done
	# end opt option processing...
	[[ $stat ]] || stat=$last

	# suggest all subcommands, including special help
	if [[ ! $cmd || $stat = 'cmd' ]]
	then
	    COMPREPLY=( $( compgen -W "$cmds $specOpts" -- $cur ) )
	    return 0
	fi

	# suggest all subcommands
	if [[ $stat = 'help' || ( $isHelpCmd && ! $help ) ]]
	then
	    COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
	    return 0
	fi

	# URL completion
	if [[ $cmd == @(co|checkout|ls|list) && $stat = 'arg' && \
			$SVN_BASH_COMPL_EXT == *urls* ]]
	then
		# see about COMP_WORDBREAKS workaround in prop completion
		if [[ $cur == file:* ]]
		then
			# file completion for file:// urls
			local where=${cur/file:/}
			COMPREPLY=( $(compgen -d -S '/' -X '*/.*' -- $where ) )
			return
		elif [[ $cur == *:* ]]
		then
			# get known urls
			local urls= file=
			for file in ~/.subversion/auth/svn.simple/* ; do
				if [ -r $file ] ; then
					local url=$(_svn_read_hashfile svn:realmstring < $file)
					url=${url/*</}
					url=${url/>*/}
					urls="$urls $url"
				fi
			done

			# only suggest/show possible suffixes
			local prefix=${cur%:*} suffix=${cur#*:} c= choices=
			for c in $urls ; do
				[[ $c == $prefix:* ]] && choices="$choices ${c#*:}"
			done

			COMPREPLY=( $(compgen -W "$choices" -- $suffix ) )
			return
		else
			# show schemas
			COMPREPLY=( $(compgen -W "$urlSchemas" -- $cur) )
			return
		fi
	fi

	if [[ $cmd = 'merge' || $cmd = 'mergeinfo' ]]
	then
	  local here=$(_svn_info URL)
	  # suggest a possible URL for merging
	  if [[ ! $URL && $stat = 'arg' ]] ; then
	    # we assume a 'standard' repos with branches and trunk
	    if [[ "$here" == */branches/* ]] ; then
	      # we guess that it is a merge from the trunk
	      COMPREPLY=( $(compgen -W ${here/\/branches\/*/\/trunk} -- $cur ) )
	      return 0
	    elif [[ "$here" == */trunk* ]] ; then
	      # we guess that it is a merge from a branch
	      COMPREPLY=( $(compgen -W ${here/\/trunk*/\/branches\/} -- $cur ) )
	      return 0
	    else
	      # no se, let us suggest the repository root...
	      COMPREPLY=( $(compgen -W $(_svn_info Root) -- $cur ) )
	      return 0
	    fi
	  elif [[ $URL == */branches/* && $here == */trunk* && \
	        ! $hasReintegrateOpt && $cur = '' && $stat = 'arg' ]] ; then
	    # force --reintegrate only if the current word is empty
	    COMPREPLY=( $(compgen -W '--reintegrate' -- $cur ) )
	    return 0
	  fi
	fi

	# help about option arguments
	if [[ $stat = 'skip' ]]
	then
	    local previous=${COMP_WORDS[COMP_CWORD-1]}
	    local values= dirs= beep= exes=

	    [[ $previous = '--config-dir' ]] && dirs=1

	    # external editor, diff, diff3...
	    [[ $previous = --*-cmd ]] && exes=1

	    [[ $previous = '--native-eol' ]] && values='LF CR CRLF'

	    # just to suggest that a number is expected. hummm.
	    [[ $previous = '--limit' ]] && values='0 1 2 3 4 5 6 7 8 9'

            # some special partial help about --revision option.
	    [[ $previous = '--revision' || $previous = '-r' ]] && \
		values='HEAD BASE PREV COMMITTED 0 {'

	    [[ $previous = '--encoding' ]] && \
		values="latin1 utf8 $SVN_BASH_ENCODINGS"

	    [[ $previous = '--extensions' || $previous = '-x' ]] && \
		values="--unified --ignore-space-change \
		   --ignore-all-space --ignore-eol-style --show-c-functions"

	    [[ $previous = '--depth' ]] && \
		values='empty files immediates infinity'

	    [[ $previous = '--set-depth' ]] && \
		values='empty exclude files immediates infinity'

	    [[ $previous = '--accept' ]] && \
	    {
	        # the list is different for 'resolve'
                if [[ $cmd = 'resolve' ]] ; then
		    # from svn help resolve
		    values='base working mine-full theirs-full'
		else # checkout merge switch update
		    values="postpone base mine-full theirs-full edit launch \
			mine-conflict theirs-conflict"
		fi
	    }

	    [[ $previous = '--show-revs' ]] && values='merged eligible'

	    if [[ $previous = '--username' ]] ; then
	      values="$SVN_BASH_USERNAME"
	      if [[ $SVN_BASH_COMPL_EXT == *username* ]] ; then
		local file=
		# digest? others?
		for file in ~/.subversion/auth/svn.simple/* ; do
		  if [ -r $file ] ; then
		    values="$values $(_svn_read_hashfile username < $file)"
		  fi
		done
	      fi
	      [[ ! "$values" ]] && beep=1
	    fi

	    # could look at ~/.subversion/ ?
	    # hmmm... this option should not exist
	    [[ $previous = '--password' ]] && beep=1

	    # TODO: provide help about other options such as:
	    # --old --new --with-revprop

	    # if the previous option required a parameter, do something
	    # or fallback on ordinary filename expansion
	    [[ $values ]] && COMPREPLY=( $( compgen -W "$values" -- $cur ) )
	    [[ $dirs ]] && COMPREPLY=( $( compgen -o dirnames -- $cur ) )
	    [[ $exes ]] && COMPREPLY=( $( compgen -c -- $cur ) )
	    [[ $beep ]] &&
	    {
		# 'no known completion'. hummm.
		echo -en "\a"
		COMPREPLY=( '' )
	    }
	    return 0
	fi

	# provide allowed property names after property commands
	if [[ $isPropCmd && ( ! $prop || $stat = 'prop' ) && $cur != -* ]]
	then
	    #
	    # Ok, this part is pretty ugly.
	    #
	    # The issue is that ":" is a completion word separator,
	    # which is a good idea for file:// urls but not within
	    # property names...
	    #
	    # The first idea was to remove locally ":" from COMP_WORDBREAKS
	    # and then put it back in all cases but in property name
	    # completion.  It does not always work.  There is a strange bug
	    # where one may get "svn:svn:xxx" in some unclear cases.
	    #
	    # Thus the handling is reprogrammed here...
	    # The code assumes that property names look like *:*,
	    # but it also works reasonably well with simple names.
	    #
	    # This hack is broken in bash4... not sure what to do about it,
            # especially while keeping the bash3 compatibility:-(
	    local choices=

	    if [[ $cur == *:* ]]
	    then
		# only suggest/show possible suffixes
		local prefix=${cur%:*} suffix=${cur#*:} c=
		for c in ${allProps[@]} ; do
		    [[ $c == $prefix:* ]] && choices="$choices ${c#*:}"
		done
		# everything will be appended to the prefix because ':' is
		# a separator, so cur is restricted to the suffix part.
		cur=$suffix
	    else
		# only one choice is fine
		COMPREPLY=( $( compgen -W "${allProps[*]}" -- $cur ) )
		[ ${#COMPREPLY[@]} -eq 1 ] && return 0

		# no ':' so only suggest prefixes?
		local seen= n=0 last= c=
		for c in ${allProps[@]%:*} ; do
		    # do not put the same prefix twice...
		    if [[ $c == $cur* && ( ! $seen || $c != @($seen) ) ]]
		    then
			let n++
			last=$c
			choices="$choices $c:"
			if [[ $seen ]]
			then
			    seen="$seen|$c*"
			else
			    seen="$c*"
			fi
		    fi
		done

		# supply two choices to force a partial completion and a beep
		[[ $n -eq 1 ]] && choices="$last:1 $last:2"
	    fi

	    COMPREPLY=( $( compgen -W "$choices" -- $cur ) )
	    return 0
	fi

	# force mandatory --revprop option on revision properties
	if [[ $isRevProp && ! $hasRevPropOpt ]]
	then
	    COMPREPLY=( $( compgen -W '--revprop' -- $cur ) )
	    return 0
	fi

	# force mandatory --revision option on revision properties
	if [[ $isRevProp && $hasRevPropOpt && ! $hasRevisionOpt ]]
	then
	    COMPREPLY=( $( compgen -W '--revision' -- $cur ) )
	    return 0
	fi

	# possible completion when setting property values
	if [[ $isPsCmd && $prop && ( ! $val || $stat = 'val' ) ]]
	then
	    # ' is a reminder for an arbitrary value
	    local values="\' --file"
	    case $prop in
		svn:keywords)
		    # just a subset?
		    values="Id Rev URL Date Author Header \' $SVN_BASH_KEYWORDS"
		    ;;
		svn:executable|svn:needs-lock)
		    # hmmm... canonical value * is special to the shell.
		    values='\\*'
		    ;;
		svn:eol-style)
		    values='native LF CR CRLF'
		    ;;
		svn:mime-type)
		    # could read /etc/mime.types if available. overkill.
		    values="text/ text/plain text/html text/xml text/rtf
                       image/ image/png image/gif image/jpeg image/tiff
                       audio/ audio/midi audio/mpeg
                       video/ video/mpeg video/mp4
                       application/ application/octet-stream
                       $SVN_BASH_MIME_TYPE"
		    ;;
	    esac

	    COMPREPLY=( $( compgen -W "$values" -- $cur ) )
	    # special case for --file... return even if within an option
	    [[ ${COMPREPLY} ]] && return 0
	fi

	# maximum number of additional arguments expected in various forms
	case $cmd in
	    merge)
		nExpectArgs=3
		;;
	    mergeinfo)
		nExpectArgs=1
		;;
	    copy|cp|move|mv|rename|ren|export|import)
		nExpectArgs=2
		;;
	    switch|sw)
		[[ ! $hasRelocateOpt ]] && nExpectArgs=2
		;;
	    help|h)
		nExpectArgs=0
		;;
	    --version)
		nExpectArgs=0
		;;
	esac

	# the maximum number of arguments is reached for a command
	if [[ $nExpectArgs && $nargs -gt $nExpectArgs ]]
	then
	    # some way to tell 'no completion at all'... is there a better one?
	    # Do not say 'file completion' here.
	    echo -en "\a"
	    COMPREPLY=( '' )
	    return 0
	fi

	# if not typing an option,
	# then fallback on filename expansion...
	if [[ $cur != -* || $stat = 'onlyarg' ]]  ; then

	    # do we allow possible expensive completion here?
	    if [[ $SVN_BASH_COMPL_EXT == *svnstatus* ]] ; then

		# build status command and options
		# "--quiet" removes 'unknown' files
		local status='svn status --non-interactive'

		[[ $SVN_BASH_COMPL_EXT == *recurse* ]] || \
		    status="$status --non-recursive"

		# I'm not sure that it can work with externals in call cases
		# the output contains translatable sentences (even with quiet)
		[[ $SVN_BASH_COMPL_EXT == *externals* ]] || \
		    status="$status --ignore-externals"

		local cs= files=
		# subtlety: must not set $cur* if $cur is empty in some cases
		[[ $cur ]] && cs=$cur*

		# 'files' is set according to the current subcommand
		case $cmd in
		    st*) # status completion must include all files
			files=$cur*
			;;
		    ci|commit|revert|di*) # anything edited
			files=$($status $cs| _svn_grcut '@([MADR!]*| M*|_M*)')
			;;
		    add) # unknown files
			files=$($status $cs| _svn_grcut '\?*')
			;;
		    unlock) # unlock locked files
			files=$($status $cs| _svn_grcut '@(??L*|?????[KOTB]*)')
			;;
		    resolve*) # files in conflict
			files=$($status $cs| _svn_grcut '@(?C*|C*)')
			;;
		    praise|blame|ann*) # any svn file but added
			files=$( _svn_lls all $cur* )
			;;
		    p*) # prop commands
			if [[ $cmd == @($propCmds) && \
			      $prop == @(svn:ignore|svn:externals) ]] ; then
			    # directory specific props
			    files=$( _svn_lls dir . $cur* )
			else
			    # ??? added directories appear twice: foo foo/
			    files="$( _svn_lls all $cur* )
                                   $($status $cs | _svn_grcut 'A*' )"
			fi
			;;
		    info) # information on any file
			files="$( _svn_lls all $cur* )
                               $($status $cs | _svn_grcut 'A*' )"
			;;
		    remove|rm|del*|move|mv|rename) # changing existing files
			files=$( _svn_lls all $cur* )
			;;
		    mkdir) # completion in mkdir can only be for subdirs?
			files=$( _svn_lls dir $cur* )
			;;
		    log|lock|up*|cl*|switch) # misc, all but added files
			files=$( _svn_lls all $cur* )
			;;
		    merge) # may do a better job? URL/WCPATH
			files=$( _svn_lls all $cur* )
			;;
		    ls|list) # better job? what about URLs?
			files=$( _svn_lls all $cur* )
			;;
		    *) # other commands: changelist export import cat mergeinfo
			local fallback=1
			;;
		esac

		# when not recursive, some relevant files may exist
		# within subdirectories, so they are added here.
		# should it be restricted to svn-managed subdirs? no??
		if [[ $SVN_BASH_COMPL_EXT != *recurse* ]] ; then
		    files="$files $( _svn_lls dir $cur* )"
		fi

		# set completion depending on computed 'files'
		if [[ $files ]] ; then
		    COMPREPLY=( $( compgen -W "$files" -- $cur ) )
		    # if empty, set to nope?
		    [[ "${COMPREPLY[*]}" ]] || COMPREPLY=( '' )
		elif [[ ! $fallback ]] ; then
		    # this suggests no completion...
		    echo -en "\a"
		    COMPREPLY=( '' )
		fi
	    fi
	    # else fallback to ordinary filename completion...
	    return 0
	fi

	# otherwise build possible options for the command
	pOpts="--username --password --no-auth-cache --non-interactive \
	       --trust-server-cert --force-interactive"
	mOpts="-m --message -F --file --encoding --force-log --with-revprop"
	rOpts="-r --revision"
	qOpts="-q --quiet"
	nOpts="-N --non-recursive --depth"
	gOpts="-g --use-merge-history"
	cOpts="--cl --changelist"

	cmdOpts=
	case $cmd in
	--version)
		cmdOpts="$qOpts"
		;;
	add)
		cmdOpts="--auto-props --no-auto-props --force --targets \
		         --no-ignore --parents $nOpts $qOpts $pOpts"
		;;
	blame|annotate|ann|praise)
		cmdOpts="$rOpts $pOpts -v --verbose --incremental --xml \
		         -x --extensions --force $gOpts"
		;;
	cat)
		cmdOpts="$rOpts $pOpts"
		;;
	changelist|cl)
		cmdOpts="--targets $pOpts $qOpts $cOpts \
                         -R --recursive --depth --remove"
		;;
	checkout|co)
		cmdOpts="$rOpts $qOpts $nOpts $pOpts --ignore-externals \
                         --force"
		;;
	cleanup)
		cmdOpts="--diff3-cmd $pOpts"
		;;
	commit|ci)
		cmdOpts="$mOpts $qOpts $nOpts --targets --editor-cmd $pOpts \
		         --no-unlock $cOpts --keep-changelists \
		         --include-externals"
		;;
	copy|cp)
		cmdOpts="$mOpts $rOpts $qOpts --editor-cmd $pOpts --parents \
		         --ignore-externals"
		;;
	delete|del|remove|rm)
		cmdOpts="--force $mOpts $qOpts --targets --editor-cmd $pOpts \
                         --keep-local"
		;;
	diff|di)
		cmdOpts="$rOpts -x --extensions --diff-cmd --no-diff-deleted \
		         $nOpts $pOpts --force --old --new --notice-ancestry \
		         -c --change --summarize $cOpts --xml --git \
		         --internal-diff --show-copies-as-adds \
		         --ignore-properties --properties-only --no-diff-added \
		         --patch-compatible"
		;;
	export)
		cmdOpts="$rOpts $qOpts $pOpts $nOpts --force --native-eol \
                         --ignore-externals --ignore-keywords"
		;;
	help|h|\?)
		cmdOpts=
		;;
	import)
		cmdOpts="--auto-props --no-auto-props $mOpts $qOpts $nOpts \
		         --no-ignore --editor-cmd $pOpts --force"
		;;
	info)
		cmdOpts="$pOpts $rOpts --targets -R --recursive --depth \
                         --incremental --xml $cOpts"
		;;
	list|ls)
		cmdOpts="$rOpts -v --verbose -R --recursive $pOpts \
                         --incremental --xml --depth --include-externals"
		;;
	lock)
		cmdOpts="-m --message -F --file --encoding --force-log \
                         --targets --force $pOpts"
		;;
	log)
		cmdOpts="$rOpts -v --verbose --targets $pOpts --stop-on-copy \
		         --incremental --xml $qOpts -l --limit -c --change \
                         $gOpts --with-all-revprops --with-revprop --depth \
		         --diff --diff-cmd -x --extensions --internal-diff \
		         --with-no-revprops --search --search-and"
		;;
	merge)
		cmdOpts="$rOpts $nOpts $qOpts --force --dry-run --diff3-cmd \
		         $pOpts --ignore-ancestry -c --change -x --extensions \
                         --record-only --accept --reintegrate \
		         --allow-mixed-revisions -v --verbose"
		;;
	mergeinfo)
	        cmdOpts="$rOpts $pOpts --depth --show-revs -R --recursive"
		;;
	mkdir)
		cmdOpts="$mOpts $qOpts --editor-cmd $pOpts --parents"
		;;
	move|mv|rename|ren)
		cmdOpts="$mOpts $rOpts $qOpts --force --editor-cmd $pOpts \
                         --parents --allow-mixed-revisions"
		;;
	patch)
		cmdOpts="$qOpts $pOpts --dry-run --ignore-whitespace \
			--reverse-diff --strip"
		;;
	propdel|pdel|pd)
		cmdOpts="$qOpts -R --recursive $rOpts $pOpts $cOpts \
                         --depth"
		[[ $isRevProp || ! $prop ]] && cmdOpts="$cmdOpts --revprop"
		;;
	propedit|pedit|pe)
		cmdOpts="--editor-cmd $pOpts $mOpts --force"
		[[ $isRevProp || ! $prop ]] && \
		    cmdOpts="$cmdOpts --revprop $rOpts"
		;;
	propget|pget|pg)
	        cmdOpts="-v --verbose -R --recursive $rOpts --strict \
		         $pOpts $cOpts --depth --xml --show-inherited-props"
		[[ $isRevProp || ! $prop ]] && cmdOpts="$cmdOpts --revprop"
		;;
	proplist|plist|pl)
		cmdOpts="-v --verbose -R --recursive $rOpts --revprop $qOpts \
		         $pOpts $cOpts --depth --xml --show-inherited-props"
		;;
	propset|pset|ps)
		cmdOpts="$qOpts --targets -R --recursive \
		         --encoding $pOpts --force $cOpts --depth"
		[[ $isRevProp || ! $prop ]] && \
		    cmdOpts="$cmdOpts --revprop $rOpts"
		[[ $val ]] || cmdOpts="$cmdOpts -F --file"
		;;
        relocate)
		cmdOpts="--ignore-externals $pOpts"
		;;
        resolve)
                cmdOpts="--targets -R --recursive $qOpts $pOpts --accept \
                         --depth"
                ;;
	resolved)
		cmdOpts="--targets -R --recursive $qOpts $pOpts --depth"
		;;
	revert)
		cmdOpts="--targets -R --recursive $qOpts $cOpts \
                         --depth $pOpts"
		;;
	status|stat|st)
		cmdOpts="-u --show-updates -v --verbose $nOpts $qOpts $pOpts \
		         --no-ignore --ignore-externals --incremental --xml \
                         $cOpts"
		;;
	switch|sw)
		cmdOpts="--relocate $rOpts $nOpts $qOpts $pOpts --diff3-cmd \
                         --force --accept --ignore-externals --set-depth \
		         --ignore-ancestry"
		;;
	unlock)
		cmdOpts="--targets --force $pOpts"
		;;
	update|up)
		cmdOpts="$rOpts $nOpts $qOpts $pOpts --diff3-cmd \
                         --ignore-externals --force --accept $cOpts \
                         --parents --editor-cmd --set-depth"
		;;
	upgrade)
		cmdOpts="$qOpts $pOpts"
		;;
	*)
		;;
	esac

	# add options that are nearly always available
	[[ "$cmd" != "--version" ]] && cmdOpts="$cmdOpts $helpOpts"
	cmdOpts="$cmdOpts --config-dir --config-option"

        # --accept (edit|launch) incompatible with --non-interactive
	if [[ $acceptOpt == @(edit|launch) ]] ;
	then
	    cmdOpts=${cmdOpts/ --non-interactive / }
	fi

	# take out options already given
	for opt in $options
	do
		local optBase

		# remove leading dashes and arguments
		case $opt in
		--*)    optBase=${opt/=*/} ;;
		-*)     optBase=${opt:0:2} ;;
		esac

		cmdOpts=" $cmdOpts "
		cmdOpts=${cmdOpts/ ${optBase} / }

		# take out alternatives and mutually exclusives
		case $optBase in
		-v)              cmdOpts=${cmdOpts/ --verbose / } ;;
		--verbose)       cmdOpts=${cmdOpts/ -v / } ;;
		-N)              cmdOpts=${cmdOpts/ --non-recursive / } ;;
		--non-recursive) cmdOpts=${cmdOpts/ -N / } ;;
		-R)              cmdOpts=${cmdOpts/ --recursive / } ;;
		--recursive)     cmdOpts=${cmdOpts/ -R / } ;;
		-x)              cmdOpts=${cmdOpts/ --extensions / } ;;
		--extensions)    cmdOpts=${cmdOpts/ -x / } ;;
		-q)              cmdOpts=${cmdOpts/ --quiet / } ;;
		--quiet)         cmdOpts=${cmdOpts/ -q / } ;;
		-h)              cmdOpts=${cmdOpts/ --help / } ;;
		--help)          cmdOpts=${cmdOpts/ -h / } ;;
		-l)              cmdOpts=${cmdOpts/ --limit / } ;;
		--limit)         cmdOpts=${cmdOpts/ -l / } ;;
		-r)              cmdOpts=${cmdOpts/ --revision / } ;;
		--revision)      cmdOpts=${cmdOpts/ -r / } ;;
		-c)              cmdOpts=${cmdOpts/ --change / } ;;
		--change)        cmdOpts=${cmdOpts/ -c / } ;;
		--auto-props)    cmdOpts=${cmdOpts/ --no-auto-props / } ;;
		--no-auto-props) cmdOpts=${cmdOpts/ --auto-props / } ;;
		-g)              cmdOpts=${cmdOpts/ --use-merge-history / } ;;
		--use-merge-history)
                                 cmdOpts=${cmdOpts/ -g / } ;;
		-m|--message|-F|--file)
			cmdOpts=${cmdOpts/ --message / }
			cmdOpts=${cmdOpts/ -m / }
			cmdOpts=${cmdOpts/ --file / }
			cmdOpts=${cmdOpts/ -F / }
			;;
		esac

		# remove help options within help subcommand
		if [ $isHelpCmd ] ; then
		    cmdOpts=${cmdOpts/ -h / }
		    cmdOpts=${cmdOpts/ --help / }
		fi
	done

	# provide help about available options
	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )
	return 0
}
complete -F _svn -o default -X '@(*/.svn|*/.svn/|.svn|.svn/)' svn

_svnadmin ()
{
	local cur cmds cmdOpts optsParam opt helpCmds optBase i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# Possible expansions, without pure-prefix abbreviations such as "h".
	cmds='crashtest create deltify dump freeze help hotcopy list-dblogs \
	      list-unused-dblogs load lock lslocks lstxns pack recover rmlocks \
	      rmtxns setlog setrevprop setuuid unlock upgrade verify --version'

	if [[ $COMP_CWORD -eq 1 ]] ; then
		COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
		return 0
	fi

	# options that require a parameter
	# note: continued lines must end '|' continuing lines must start '|'
	optsParam="-r|--revision|--parent-dir|--fs-type|-M|--memory-cache-size"
	optsParam="$optsParam|-F|--file"

	# if not typing an option, or if the previous option required a
	# parameter, then fallback on ordinary filename expansion
	helpCmds='help|--help|h|\?'
	if [[ ${COMP_WORDS[1]} != @($helpCmds) ]] && \
	   [[ "$cur" != -* ]] || \
	   [[ ${COMP_WORDS[COMP_CWORD-1]} == @($optsParam) ]] ; then
		return 0
	fi

	cmdOpts=
	case ${COMP_WORDS[1]} in
	create)
		cmdOpts="--bdb-txn-nosync --bdb-log-keep --config-dir \
		         --fs-type --pre-1.4-compatible --pre-1.5-compatible \
		         --pre-1.6-compatible --compatible-version"
		;;
	deltify)
		cmdOpts="-r --revision -q --quiet"
		;;
	dump)
		cmdOpts="-r --revision --incremental -q --quiet --deltas \
		         -M --memory-cache-size"
		;;
	freeze)
		cmdOpts="-F --file"
		;;
	help|h|\?)
		cmdOpts="$cmds"
		;;
	hotcopy)
		cmdOpts="--clean-logs"
		;;
	load)
		cmdOpts="--ignore-uuid --force-uuid --parent-dir -q --quiet \
		         --use-pre-commit-hook --use-post-commit-hook \
		         --bypass-prop-validation -M --memory-cache-size"
		;;
	lock|unlock)
		cmdOpts="--bypass-hooks"
		;;
	recover)
		cmdOpts="--wait"
		;;
	rmtxns)
		cmdOpts="-q --quiet"
		;;
	setlog)
		cmdOpts="-r --revision --bypass-hooks"
		;;
	setrevprop)
		cmdOpts="-r --revision --use-pre-revprop-change-hook \
		         --use-post-revprop-change-hook"
		;;
	verify)
		cmdOpts="-r --revision -q --quiet"
		;;
	*)
		;;
	esac

	cmdOpts="$cmdOpts --help -h"

	# take out options already given
	for (( i=2; i<=$COMP_CWORD-1; ++i )) ; do
		opt=${COMP_WORDS[$i]}

		case $opt in
		--*)    optBase=${opt/=*/} ;;
		-*)     optBase=${opt:0:2} ;;
		esac

		cmdOpts=" $cmdOpts "
		cmdOpts=${cmdOpts/ ${optBase} / }

		# take out alternatives
		case $optBase in
		-q)              cmdOpts=${cmdOpts/ --quiet / } ;;
		--quiet)         cmdOpts=${cmdOpts/ -q / } ;;
		-h)              cmdOpts=${cmdOpts/ --help / } ;;
		--help)          cmdOpts=${cmdOpts/ -h / } ;;
		-r)              cmdOpts=${cmdOpts/ --revision / } ;;
		--revision)      cmdOpts=${cmdOpts/ -r / } ;;
		-F)              cmdOpts=${cmdOpts/ --file / } ;;
		--file)          cmdOpts=${cmdOpts/ -F / } ;;
		-M)              cmdOpts=${cmdOpts/ --memory-cache-size / } ;;
		--memory-cache-size) cmdOpts=${cmdOpts/ --M / } ;;
		esac

		# skip next option if this one requires a parameter
		if [[ $opt == @($optsParam) ]] ; then
			((++i))
		fi
	done

	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )

	return 0
}
complete -F _svnadmin -o default svnadmin

_svndumpfilter ()
{
	local cur cmds cmdOpts optsParam opt helpCmds optBase i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# Possible expansions, without pure-prefix abbreviations such as "h".
	cmds='exclude help include --version'

	if [[ $COMP_CWORD -eq 1 ]] ; then
		COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
		return 0
	fi

	# options that require a parameter
	# note: continued lines must end '|' continuing lines must start '|'
	optsParam="--targets"

	# if not typing an option, or if the previous option required a
	# parameter, then fallback on ordinary filename expansion
	helpCmds='help|--help|h|\?'
	if [[ ${COMP_WORDS[1]} != @($helpCmds) ]] && \
	   [[ "$cur" != -* ]] || \
	   [[ ${COMP_WORDS[COMP_CWORD-1]} == @($optsParam) ]] ; then
		return 0
	fi

	cmdOpts=
	case ${COMP_WORDS[1]} in
	exclude|include)
		cmdOpts="--drop-empty-revs --renumber-revs
		         --skip-missing-merge-sources --targets
		         --preserve-revprops --quiet"
		;;
	help|h|\?)
		cmdOpts="$cmds"
		;;
	*)
		;;
	esac

	cmdOpts="$cmdOpts --help -h"

	# take out options already given
	for (( i=2; i<=$COMP_CWORD-1; ++i )) ; do
		opt=${COMP_WORDS[$i]}

		case $opt in
		--*)    optBase=${opt/=*/} ;;
		-*)     optBase=${opt:0:2} ;;
		esac

		cmdOpts=" $cmdOpts "
		cmdOpts=${cmdOpts/ ${optBase} / }

		# take out alternatives
		case $optBase in
		-h)              cmdOpts=${cmdOpts/ --help / } ;;
		--help)          cmdOpts=${cmdOpts/ -h / } ;;
		esac

		# skip next option if this one requires a parameter
		if [[ $opt == @($optsParam) ]] ; then
			((++i))
		fi
	done

	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )

	return 0
}
complete -F _svndumpfilter -o default svndumpfilter

_svnlook ()
{
	local cur cmds cmdOpts optsParam opt helpCmds optBase i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# Possible expansions, without pure-prefix abbreviations such as "h".
	cmds='author cat changed date diff dirs-changed help history info \
	      lock log propget proplist tree uuid youngest --version'

	if [[ $COMP_CWORD -eq 1 ]] ; then
		COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
		return 0
	fi

	# options that require a parameter
	# note: continued lines must end '|' continuing lines must start '|'
	optsParam="-r|--revision|-t|--transaction|-l|--limit|-x|--extensions"

	# if not typing an option, or if the previous option required a
	# parameter, then fallback on ordinary filename expansion
	helpCmds='help|--help|h|\?'
	if [[ ${COMP_WORDS[1]} != @($helpCmds) ]] && \
	   [[ "$cur" != -* ]] || \
	   [[ ${COMP_WORDS[COMP_CWORD-1]} == @($optsParam) ]] ; then
		return 0
	fi

	cmdOpts=
	case ${COMP_WORDS[1]} in
	author)
		cmdOpts="-r --revision -t --transaction"
		;;
	cat)
		cmdOpts="-r --revision -t --transaction"
		;;
	changed)
		cmdOpts="-r --revision -t --transaction --copy-info"
		;;
	date)
		cmdOpts="-r --revision -t --transaction"
		;;
	diff)
		cmdOpts="-r --revision -t --transaction --diff-copy-from \
		         --no-diff-added --no-diff-deleted -x --extensions"
		;;
	dirs-changed)
		cmdOpts="-r --revision -t --transaction"
		;;
	help|h|\?)
		cmdOpts="$cmds"
		;;
	history)
		cmdOpts="-r --revision -l --limit --show-ids"
		;;
	info)
		cmdOpts="-r --revision -t --transaction"
		;;
	lock)
		cmdOpts=
		;;
	log)
		cmdOpts="-r --revision -t --transaction"
		;;
	propget|pget|pg)
		cmdOpts="-r --revision -t --transaction --revprop"
		;;
	proplist|plist|pl)
		cmdOpts="-r --revision -t --transaction --revprop -v --verbose --xml"
		;;
	tree)
		cmdOpts="-r --revision -t --transaction --full-paths -N --non-recursive --show-ids"
		;;
	uuid)
		cmdOpts=
		;;
	youngest)
		cmdOpts=
		;;
	*)
		;;
	esac

	cmdOpts="$cmdOpts --help -h"

	# take out options already given
	for (( i=2; i<=$COMP_CWORD-1; ++i )) ; do
		opt=${COMP_WORDS[$i]}

		case $opt in
		--*)    optBase=${opt/=*/} ;;
		-*)     optBase=${opt:0:2} ;;
		esac

		cmdOpts=" $cmdOpts "
		cmdOpts=${cmdOpts/ ${optBase} / }

		# take out alternatives
		case $optBase in
		-N)              cmdOpts=${cmdOpts/ --non-recursive / } ;;
		--non-recursive) cmdOpts=${cmdOpts/ -N / } ;;
		-h)              cmdOpts=${cmdOpts/ --help / } ;;
		--help)          cmdOpts=${cmdOpts/ -h / } ;;
		-l)              cmdOpts=${cmdOpts/ --limit / } ;;
		--limit)         cmdOpts=${cmdOpts/ -l / } ;;
		-r)              cmdOpts=${cmdOpts/ --revision / } ;;
		--revision)      cmdOpts=${cmdOpts/ -r / } ;;
		-t)              cmdOpts=${cmdOpts/ --transaction / } ;;
		--transaction)   cmdOpts=${cmdOpts/ -t / } ;;
		-v)              cmdOpts=${cmdOpts/ --verbose / } ;;
		--verbose)       cmdOpts=${cmdOpts/ -v / } ;;
		-x)              cmdOpts=${cmdOpts/ --extensions / } ;;
		--extensions)    cmdOpts=${cmdOpts/ -x / } ;;
		esac

		# skip next option if this one requires a parameter
		if [[ $opt == @($optsParam) ]] ; then
			((++i))
		fi
	done

	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )

	return 0
}
complete -F _svnlook -o default svnlook

_svnsync ()
{
	local cur cmds cmdOpts optsParam opt helpCmds optBase i

	COMPREPLY=()
	cur=${COMP_WORDS[COMP_CWORD]}

	# Possible expansions, without pure-prefix abbreviations such as "h".
	cmds='copy-revprops help info initialize synchronize --version'

	if [[ $COMP_CWORD -eq 1 ]] ; then
		COMPREPLY=( $( compgen -W "$cmds" -- $cur ) )
		return 0
	fi

	# options that require a parameter
	# note: continued lines must end '|' continuing lines must start '|'
	optsParam="--config-dir|--config-option|--source-username|--source-password"
	optsParam="$optsParam|--sync-username|--sync-password"

	# if not typing an option, or if the previous option required a
	# parameter, then fallback on ordinary filename expansion
	helpCmds='help|--help|h|\?'
	if [[ ${COMP_WORDS[1]} != @($helpCmds) ]] && \
	   [[ "$cur" != -* ]] || \
	   [[ ${COMP_WORDS[COMP_CWORD-1]} == @($optsParam) ]] ; then
		return 0
	fi

	cmdOpts=
	case ${COMP_WORDS[1]} in
	copy-revprops|initialize|init|synchronize|sync)
		cmdOpts="--non-interactive --no-auth-cache --trust-server-cert \
		         --source-username --source-password --sync-username \
		         --sync-password --config-dir --config-option -q --quiet"
		;;
	help|h|\?)
		cmdOpts="$cmds"
		;;
	info)
		cmdOpts="--non-interactive --no-auth-cache --trust-server-cert \
		         --source-username --source-password --sync-username \
		         --sync-password --config-dir --config-option"
		;;
	*)
		;;
	esac

	cmdOpts="$cmdOpts --help -h"

	# take out options already given
	for (( i=2; i<=$COMP_CWORD-1; ++i )) ; do
		opt=${COMP_WORDS[$i]}

		case $opt in
		--*)    optBase=${opt/=*/} ;;
		-*)     optBase=${opt:0:2} ;;
		esac

		cmdOpts=" $cmdOpts "
		cmdOpts=${cmdOpts/ ${optBase} / }

		# take out alternatives
		case $optBase in
		-h)              cmdOpts=${cmdOpts/ --help / } ;;
		--help)          cmdOpts=${cmdOpts/ -h / } ;;
		-q)              cmdOpts=${cmdOpts/ --quiet / } ;;
		--quiet)         cmdOpts=${cmdOpts/ -q / } ;;
		esac

		# skip next option if this one requires a parameter
		if [[ $opt == @($optsParam) ]] ; then
			((++i))
		fi
	done

	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )

	return 0
}
complete -F _svnsync -o default svnsync

# reasonable completion for 'svnversion'
_svnversion ()
{
	local cmdOpts=" -n --no-newline -c --committed -h --help --version "
	local cur=${COMP_WORDS[COMP_CWORD]}

	COMPREPLY=()

	# parse current options
	local options= wcpath= trailurl= last='none' stat= opt= i=-1 isCur=
	for opt in ${COMP_WORDS[@]}
	do
		[[ $i -eq $COMP_CWORD ]] && stat=$last
		let i++

		# are we processing the current word?
		isCur=
		[[ $i -eq $COMP_CWORD ]] && isCur=1

		# skip first command, should be 'svnversion'
		if [ $last = 'none' ] ; then
			last='first'
			continue
		fi

		# get options
		if [[ $last != 'arg' && $opt == -* ]]
		then
			# if '--' is at the current position, it means that we are looking
			# for '--*' options, and not the end of option processing.
			if [[ $opt = '--' && ! $isCur ]]
			then
				last='arg'
			else
				options="$options $opt "
				last='opt'
			fi
			continue
		fi
		# get arguments
		if [[ $opt != -* ]]
		then
			last='arg'
			if [[ ! $wcpath ]]
			then
				wcpath=$opt
			elif [[ ! $trailurl ]]
			then
				trailurl=$opt
			fi
		fi
	done
	[[ $stat ]] || stat=$last

	# argument part
	if [[ $cur != -* || $stat = 'arg' ]]
	then
		[[ $wcpath && $trailurl ]] && COMPREPLY=( '' )
		return 0
	fi

	# suggest options, and  take out already given options
	for opt in $options
	do
		# take out options
		cmdOpts=${cmdOpts/ $opt / }

		# take out alternatives
		case $opt in
			-n)              cmdOpts=${cmdOpts/ --no-newline / } ;;
			--no-newline)    cmdOpts=${cmdOpts/ -n / } ;;
			-h)              cmdOpts=${cmdOpts/ --help / } ;;
			--help)          cmdOpts=${cmdOpts/ -h / } ;;
			-c)              cmdOpts=${cmdOpts/ --committed / } ;;
			--committed)     cmdOpts=${cmdOpts/ -c / } ;;
		esac
	done

	COMPREPLY=( $( compgen -W "$cmdOpts" -- $cur ) )

	return 0
}
# -X option does not seem to work?
complete -F _svnversion -o dirnames -X '*.svn*' svnversion
