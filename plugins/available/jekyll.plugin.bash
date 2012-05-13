cite about-plugin
about-plugin 'manage your jekyll site'

editpost() {
  about 'edit a post'
  param '1: site directory'
  group 'jekyll'

  unset SITE
  if [ -z "$1" ]
  then
    echo "Error: no site specified."
    echo "The site is the name of the directory your project is in."
    return 1
  fi

  for site in ${SITES[@]}
  do
    if [ "$(basename $site)" = "$1" ]
    then
      SITE=$site
      break
    fi
  done

  if [ -z "$SITE" ]
  then
    echo "No such site."
    return 1
  fi

  builtin cd "$SITE/_posts"

  COUNTER=1
  NUMBER="$RANDOM"
  TMPFILE="/tmp/editpost-$NUMBER"

  for POST in *
  do
    DATE=`echo $POST | grep -oE "[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}"`
    TITLE=`cat $POST | grep -oE "title: (.+)"`
    TITLE=`echo $TITLE | sed 's/title: //'`
    echo "$COUNTER) 	$DATE	$TITLE" >> "$TMPFILE"
    POSTS[$COUNTER]=$POST
    COUNTER=`expr $COUNTER + 1`
  done
  less $TMPFILE
  read -p "Number of post to edit: " POST_TO_EDIT
  if [ -z "$JEKYLL_EDITOR" ]
  then
    nano "${POSTS[$POST_TO_EDIT]}"
  else
    "$JEKYLL_EDITOR" "${POSTS[$POST_TO_EDIT]}"
  fi
}

newpost() {
  about 'create a new post'
  param '1: site directory'
  group 'jekyll'

  unset SITE
  if [ -z "$1" ]
  then
    echo "Error: no site specified."
    echo "The site is the name of the directory your project is in."
    return 1
  fi

  if [ -z "$SITE" ]
  then
    echo "No such site."
    return 1
  fi

  loc=0

  for site in ${SITES[@]}
  do
    if [ "$(basename $site)" = "$1" ]
    then
      SITE=$site
      JEKYLL_FORMATTING=${MARKUPS[$loc]}
      break
    fi
    loc=$(($loc+1))
  done

  # 'builtin cd' into the local jekyll root

  builtin cd "$SITE/_posts"

  # Get the date for the new post's filename

  FNAME_DATE=$(date "+%Y-%m-%d")

  # If the user is using markdown or textile formatting, let them choose what type of post they want. Sort of like Tumblr.

  OPTIONS="Text Quote Image Audio Video Link"

  if [ $JEKYLL_FORMATTING = "markdown" -o $JEKYLL_FORMATTING = "textile" ]
  then
    select OPTION in $OPTIONS
    do
      if [[ $OPTION = "Text" ]]
      then
        POST_TYPE="Text"
        break
      fi

      if [[ $OPTION = "Quote" ]]
      then
        POST_TYPE="Quote"
        break
      fi

      if [[ $OPTION = "Image" ]]
      then
        POST_TYPE="Image"
        break
      fi

      if [[ $OPTION = "Audio" ]]
      then
        POST_TYPE="Audio"
        break
      fi

      if [[ $OPTION = "Video" ]]
      then
        POST_TYPE="Video"
        break
      fi

      if [[ $OPTION = "Link" ]]
      then
        POST_TYPE="Link"
        break
      fi
    done
  fi

  # Get the title for the new post

  read -p "Enter title of the new post: " POST_TITLE

  # Convert the spaces in the title to hyphens for use in the filename

  FNAME_POST_TITLE=`echo $POST_TITLE | tr ' ' "-"`

  # Now, put it all together for the full filename

  FNAME="$FNAME_DATE-$FNAME_POST_TITLE.$JEKYLL_FORMATTING"

  # And, finally, create the actual post file. But we're not done yet...

  touch "$FNAME"

  # Write a little stuff to the file for the YAML Front Matter

  echo "---" >> $FNAME

  # Now we have to get the date, again. But this time for in the header (YAML Front Matter) of
  # the file

  YAML_DATE=$(date "+%B %d %Y %X")

  # Echo the YAML Formatted date to the post file

  echo "date: $YAML_DATE" >> $FNAME

  # Echo the original post title to the YAML Front Matter header

  echo "title: $POST_TITLE" >> $FNAME

  # And, now, echo the "post" layout to the YAML Front Matter header

  echo "layout: post" >> $FNAME

  # Close the YAML Front Matter Header

  echo "---" >> $FNAME
  echo >> $FNAME

  # Generate template text based on the post type

  if [[ $JEKYLL_FORMATTING = "markdown" ]]
  then
    if [[ $POST_TYPE = "Text" ]]
    then
      true
    fi

    if [[ $POST_TYPE = "Quote" ]]
    then
      echo "> Quote" >> $FNAME
      echo >> $FNAME
      echo "&mdash; Author" >> $FNAME
    fi

    if [[ $POST_TYPE = "Image" ]]
    then
      echo "![Alternate Text](/path/to/image/or/url)" >> $FNAME
    fi

    if [[ $POST_TYPE = "Audio" ]]
    then
      echo "<html><audio src=\"/path/to/audio/file\" controls=\"controls\"></audio></html>" >> $FNAME
    fi

    if [[ $POST_TYPE = "Video" ]]
    then
      echo "<html><video src=\"/path/to/video\" controls=\"controls\"></video></html>" >> $FNAME
    fi

    if [[ $POST_TYPE = "Link" ]]
    then
      echo "[link][1]" >> $FNAME
      echo >> $FNAME
      echo "> Quote" >> $FNAME
      echo >> $FNAME
      echo "[1]: url" >> $FNAME
    fi
  fi

  if [[ $JEKYLL_FORMATTING = "textile" ]]
  then
    if [[ $POST_TYPE = "Text" ]]
    then
      true
    fi

    if [[ $POST_TYPE = "Quote" ]]
    then
      echo "bq. Quote" >> $FNAME
      echo >> $FNAME
      echo "&mdash; Author" >> $FNAME
    fi

    if [[ $POST_TYPE = "Image" ]]
    then
      echo "!url(alt text)" >> $FNAME
    fi

    if [[ $POST_TYPE = "Audio" ]]
    then
      echo "<html><audio src=\"/path/to/audio/file\" controls=\"controls\"></audio></html>" >> $FNAME
    fi

    if [[ $POST_TYPE = "Video" ]]
    then
      echo "<html><video src=\"/path/to/video\" controls=\"controls\"></video></html>" >> $FNAME
    fi

    if [[ $POST_TYPE = "Link" ]]
    then
      echo "\"Site\":url" >> $FNAME
      echo >> $FNAME
      echo "bq. Quote" >> $FNAME
    fi
  fi

  # Open the file in your favorite editor

  "$JEKYLL_EDITOR" $FNAME
}

function testsite() {
  about 'launches local jekyll server'
  param '1: site directory'
  group 'jekyll'

  unset SITE
  if [ -z "$1" ]
  then
    echo "Error: no site specified."
    echo "The site is the name of the directory your project is in."
    return 1
  fi

  for site in ${SITES[@]}
  do
    if [ "$(basename $site)" = "$1" ]
    then
      SITE=$site
      break
    fi
  done

  if [ -z "$SITE" ]
  then
    echo "No such site."
    return 1
  fi

  builtin cd $SITE
  jekyll --server --auto
}

function buildsite() {
  about 'builds site'
  param '1: site directory'
  group 'jekyll'

  unset SITE
  if [ -z "$1" ]
  then
    echo "Error: no site specified."
    echo "The site is the name of the directory your project is in."
    return 1
  fi

  for site in ${SITES[@]}
  do
    if [ "$(basename $site)" = "$1" ]
    then
      SITE=$site
      break
    fi
  done

  if [ -z "$SITE" ]
  then
    echo "No such site."
    return 1
  fi

  builtin cd $SITE
  rm -rf _site
  jekyll --no-server
}

function deploysite() {
  about 'rsyncs site to remote host'
  param '1: site directory'
  group 'jekyll'

  unset SITE
  if [ -z "$1" ]
  then
    echo "Error: no site specified."
    echo "The site is the name of the directory your project is in."
    return 1
  fi

  loc=0

  for site in ${SITES[@]}
  do
    if [ "$(basename $site)" = "$1" ]
    then
      SITE=$site
      REMOTE=${REMOTES[$loc]}
      break
    fi
    loc=$(($loc+1))
  done

  if [ -z "$SITE" ]
  then
    echo "No such site."
    return 1
  fi

  builtin cd $SITE
  rsync -rz $REMOTE
}
