cite about-plugin
about-plugin 'video to gif helper functions'

# From https://gist.github.com/SlexAxton/4989674#comment-1199058
# Renamed gifify to v2gif to go avoid clobbering https://github.com/jclem/gifify
# Requirements (Mac OS X using Homebrew): brew install ffmpeg giflossy imagemagick
# Requirements on Ubuntu: sudo apt install ffmpeg imagemagick ; plus install https://github.com/pornel/giflossy
# Optional: install mediainfo for autodetection of original video FPS.
# Optional: if lossy is not important, Ubuntu has gifsicle packaged for apt-get, instead of giflossy
# Optional: gifski (from `brew install gifski` or github.com/ImageOptim/gifski)
#           for high quality huge files.
function v2gif {
  about 'Converts a .mov/.avi/.mp4 file into an into an animated GIF.'
  group 'gif'
  param '1: MOV/AVI/MP4 file name(s)'
  param '2: -w <num> ; Optional: max width in pixels'
  param '3: -l <num> ; Optional: extra lossy level for smaller files (80-200 make sense, needs giflossy instead of gifsicle)'
  param '4: -h       ; Optional: high quality using gifski (installed seperately) - overrides "--lossy" above!'
  param '5: -d       ; Optional: delete the original video file if succeeded'
  param '6: -t       ; Optional: Tag the result with quality stamp for comparison use'
  param '7: -f <num> ; Optional: Change number of frames per second (default 10 or original FPS if mediainfo installed)'
  param '8: -a <num> ; Optional: Alert if resulting file is over <num> kilobytes (default is 5000, 0 turns off)'
  example '$ v2gif foo.mov'
  example '$ v2gif foo.mov -w 600'
  example '$ v2gif -l 100 -d *.mp4'
  example '$ v2gif -dh *.avi'
  example '$ v2gif -thw 600 *.avi *.mov'

  # Parse the options
  local args=$(getopt -l "alert:" -l "lossy:" -l "width:" -l del,delete -l high -l tag -l "fps:" -o "a:l:w:f:dht" -- "$@")

  local use_gifski=""
  local del_after=""
  local maxsize=""
  local lossiness=""
  local maxwidthski=""
  local giftagopt=""
  local giftag=""
  local defaultfps=10
  local infps=""
  local fps=""
  local alert=5000
  eval set -- "$args"
  while [ $# -ge 1 ]; do
    case "$1" in
      --)
        # No more options left.
        shift
        break
        ;;
      -d|--del|--delete)
        # Delete after
        del_after="true"
        shift
        ;;
      -h|--high)
        #High Quality, use gifski
        use_gifski=true
        giftag="${giftag}-h"
        shift
        ;;
      -w|--width)
        maxsize="-vf scale=$2:-1"
        maxwidthski="-W $2"
        giftag="${giftag}-w$2"
        shift 2
        ;;
      -t|--tag)
        # mark with a quality tag
        giftagopt="true"
        shift
        ;;
      -l|--lossy)
        # Use giflossy parameter
        lossiness="--lossy=$2"
        giftag="${giftag}-l$2"
        shift 2
        ;;
      -f|--fps)
        # select fps
        infps="$2"
        giftag="${giftag}-f$2"
        shift 2
        ;;
      -a|--alert)
        # set size alert
        alert="$2"
        shift 2
        ;;
    esac
  done

  # Done Parsing, all that's left are the filenames
  local movies="$*"

  if [[ -z "$movies" ]]; then
    echo "$(tput setaf 1)No input files given. Example: v2gif file [file...] [-w <max width (pixels)>] [-l <lossy level>] < $(tput sgr 0)"
    return 1
  fi

  # Prepare the quality tag if requested.
  [[ -z "$giftag" ]] && giftag="-default"
  [[ -z "$giftagopt" ]] && giftag=""

  for file in $movies ; do

    local output_file="${file%.*}${giftag}.gif"

    # Set FPS to match the video if possible, otherwise fallback to default.
    if [[ "$infps" ]] ; then
      fps=$infps
    else
      fps=$defaultfps
      if [[ -x /usr/bin/mediainfo ]] ; then
        if /usr/bin/mediainfo "$file" | grep -q "Frame rate mode *: Variable" ; then
          fps=$(/usr/bin/mediainfo "$file" | grep "Minimum frame rate" |sed 's/.*: \([0-9.]\+\) .*/\1/' | head -1)
        else
          fps=$(/usr/bin/mediainfo "$file" | grep "Frame rate   " |sed 's/.*: \([0-9.]\+\) .*/\1/' | head -1)
        fi
      fi
    fi

    echo "$(tput setaf 2)Creating '$output_file' at $fps FPS ...$(tput sgr 0)"

    if [[ "$use_gifski" = "true" ]] ; then
      # I trust @pornel to do his own resizing optimization choices
      ffmpeg -loglevel panic -i "$file" -r $fps -vcodec png v2gif-tmp-%05d.png && \
        gifski $maxwidthski --fps $(printf "%.0f" $fps) -o "$output_file" v2gif-tmp-*.png || return 2
    else
      ffmpeg -loglevel panic -i "$file" $maxsize -r $fps -vcodec png v2gif-tmp-%05d.png && \
        convert +dither -layers Optimize v2gif-tmp-*.png GIF:- | \
        gifsicle $lossiness --no-warnings --colors 256 --delay=$(echo "100/$fps"|bc) --loop --optimize=3 --multifile - > "$output_file" || return 2
    fi

    rm v2gif-tmp-*.png

    # Checking if the file is bigger than Twitter likes and warn
    if [[ $alert -gt 0 ]] ; then
      local out_size=$(wc --bytes < "$output_file")
      if [[ $out_size -gt $(( alert * 1000 )) ]] ; then
        echo "$(tput setaf 3)Warning: '$output_file' is $((out_size/1000))kb, keeping '$file' even if --del requested.$(tput sgr 0)"
        del_after=""
      fi
    fi

    [[ "$del_after" = "true" ]] && rm "$file"

  done

  echo "$(tput setaf 2)Done.$(tput sgr 0)"
}
