cite about-plugin
about-plugin 'gif helper functions'

# From https://gist.github.com/SlexAxton/4989674#comment-1199058
# Requirements (Mac OS X using Homebrew): brew install ffmpeg gifsicle imagemagick
function gifify {
  about 'Converts a .mov file into an into an animated GIF.'
  group 'gif'
  param '1: MOV file name'
  param '2: max width in pixels (optional)'
  example '$ gifify foo.mov'
  example '$ gifify foo.mov 600'

  if [ -z "$1" ]; then
    echo "$(tput setaf 1)No input file given. Example: gifify example.mov [max width (pixels)]$(tput sgr 0)"
    return 1
  fi

  output_file="${1%.*}.gif"

  echo "$(tput setaf 2)Creating $output_file...$(tput sgr 0)"

  if [ ! -z "$2" ]; then
    maxsize="-vf scale=$2:-1"
  else
    maxsize=""
  fi

  ffmpeg -loglevel panic -i $1 $maxsize -r 10 -vcodec png gifify-tmp-%05d.png
  convert +dither -layers Optimize gifify-tmp-*.png GIF:- | gifsicle --no-warnings --colors 256 --delay=10 --loop --optimize=3 --multifile - > $output_file
  rm gifify-tmp-*.png

  echo "$(tput setaf 2)Done.$(tput sgr 0)"
}
