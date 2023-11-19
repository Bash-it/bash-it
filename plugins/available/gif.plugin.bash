# shellcheck shell=bash
about-plugin 'video to gif, gif to WebM helper functions'

# Based loosely on:
#  https://gist.github.com/SlexAxton/4989674#comment-1199058
#  https://linustechtips.com/main/topic/343253-tutorial-convert-videogifs-to-webm/
#  and other sources
# Renamed gifify to v2gif to go avoid clobbering https://github.com/jclem/gifify
# Requirements (Mac OS X using Homebrew): brew install ffmpeg giflossy imagemagick
# Requirements on Ubuntu: sudo apt install ffmpeg imagemagick ; plus install https://github.com/pornel/giflossy
# Optional: install mediainfo for autodetection of original video FPS.
# Optional: if lossy is not important, Ubuntu has gifsicle packaged for apt-get, instead of giflossy
# Optional: gifski (from `brew install gifski` or github.com/ImageOptim/gifski)
#           for high quality huge files.
function v2gif() {
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
	param '9: -m       ; Optional: Also create a WebM file (will one day replace GIF, Smaller and higher quality than mp4)'
	example '$ v2gif foo.mov'
	example '$ v2gif foo.mov -w 600'
	example '$ v2gif -l 100 -d *.mp4'
	example '$ v2gif -dh *.avi'
	example '$ v2gif -thw 600 *.avi *.mov'

	local convert ffmpeg mediainfo gifsicle getopt args gifski out_size

	convert="$(type -p convert)"
	[[ -x "$convert" ]] || {
		echo "No convert found!"
		return 2
	}
	ffmpeg="$(type -p ffmpeg)"
	[[ -x "$ffmpeg" ]] || {
		echo "No ffmpeg found!"
		return 2
	}
	mediainfo="$(type -p mediainfo)"
	[[ -x "$mediainfo" ]] || {
		echo "No mediainfo found!"
		return 2
	}
	gifsicle="$(type -p gifsicle)"
	[[ -x "$gifsicle" ]] || {
		echo "No gifsicle found!"
		return 2
	}
	getopt="$(type -p getopt)"

	if [[ "$OSTYPE" == "darwin"* ]]; then
		# Getopt on BSD is incompatible with GNU
		getopt=/usr/local/opt/gnu-getopt/bin/getopt
		[[ -x "$getopt" ]] || {
			echo "No GNU-getopt found!"
			return 2
		}
	fi

	# Parse the options
	args=$("$getopt" -l "alert:" -l "lossy:" -l "width:" -l del,delete -l high -l help -l tag -l "fps:" -l webm -o "a:l:w:f:dhmt" -- "$@") || {
		echo 'Terminating...' >&2
		return 2
	}

	eval set -- "$args"
	local use_gifski=""
	local opt_del_after=""
	local maxsize=()
	local lossiness=()
	local maxwidthski=()
	local giftagopt=""
	local giftag=""
	local defaultfps=10
	local infps=""
	local fps=""
	local make_webm=""
	local alert=5000
	local printhelp=""
	while [[ $# -ge 1 ]]; do
		case "$1" in
			--)
				# No more options left.
				shift
				break
				;;
			-d | --del | --delete)
				# Delete after
				opt_del_after="true"
				shift
				;;
			--help)
				# Print Help
				printhelp="true"
				shift
				;;
			-h | --high)
				#High Quality, use gifski
				gifski="$(type -p gifski)"
				[[ -x "$gifski" ]] || {
					echo "No gifski found!"
					return 2
				}
				use_gifski=true
				giftag="${giftag}-h"
				shift
				;;
			-w | --width)
				maxsize=(-vf "scale=$2:-1")
				maxwidthski=(-W "$2")
				giftag="${giftag}-w$2"
				shift 2
				;;
			-t | --tag)
				# mark with a quality tag
				giftagopt="true"
				shift
				;;
			-l | --lossy)
				# Use giflossy parameter
				lossiness=("--lossy=$2")
				giftag="${giftag}-l$2"
				shift 2
				;;
			-f | --fps)
				# select fps
				infps="$2"
				giftag="${giftag}-f$2"
				shift 2
				;;
			-a | --alert)
				# set size alert
				alert="$2"
				shift 2
				;;
			-m | --webm)
				# set size alert
				make_webm="true"
				shift
				;;
		esac
	done

	if [[ -z "$*" || "$printhelp" ]]; then
		echo "$(tput setaf 1)No input files given. Example: v2gif file [file...] [-w <max width (pixels)>] [-l <lossy level>] $(tput sgr 0)"
		echo "-d/--del/--delete Delete original vid if done suceessfully (and file not over the size limit)"
		echo "-h/--high         High Quality - use Gifski instead of gifsicle"
		echo "-w/--width N      Lock maximum gif width to N pixels, resize if necessary"
		echo "-t/--tag          Add a tag to the output gif describing the options used (useful for comparing several options)"
		echo "-l/--lossy N      Use the Giflossy parameter for gifsicle (If your version supports it)"
		echo "-f/--fps N        Override autodetection of incoming vid FPS (useful for downsampling)"
		echo "-a/--alert N      Alert if over N kilobytes (Defaults to 5000)"
		echo "-m/--webm         Also create a webm file"
		return 1
	fi

	# Prepare the quality tag if requested.
	[[ -z "$giftag" ]] && giftag="-default"
	[[ -z "$giftagopt" ]] && giftag=""

	for file; do

		local output_file="${file%.*}${giftag}.gif"
		local del_after=$opt_del_after

		if [[ -n "$make_webm" ]]; then
			$ffmpeg -loglevel warning -i "$file" \
				-c:v libvpx -crf 4 -threads 0 -an -b:v 2M -auto-alt-ref 0 \
				-quality best -loop 0 "${file%.*}.webm" || return 2
		fi

		# Set FPS to match the video if possible, otherwise fallback to default.
		if [[ -n "$infps" ]]; then
			fps=$infps
		else
			fps=$defaultfps
			if [[ -x "$mediainfo" ]]; then
				fps=$($mediainfo "$file" | grep "Frame rate   " | sed 's/.*: \([0-9.]\+\) .*/\1/' | head -1)
				[[ -z "$fps" ]] && fps=$($mediainfo "$file" | grep "Minimum frame rate" | sed 's/.*: \([0-9.]\+\) .*/\1/' | head -1)
			fi
		fi

		echo "$(tput setaf 2)Creating '$output_file' at $fps FPS ...$(tput sgr 0)"

		if [[ "$use_gifski" = "true" ]]; then
			# I trust @pornel to do his own resizing optimization choices
			$ffmpeg -loglevel warning -i "$file" -r "$fps" -vcodec png v2gif-tmp-%05d.png \
				&& $gifski "${maxwidthski[@]}" --fps "$(printf "%.0f" "$fps")" -o "$output_file" v2gif-tmp-*.png || return 2
		else
			$ffmpeg -loglevel warning -i "$file" "${maxsize[@]}" -r "$fps" -vcodec png v2gif-tmp-%05d.png \
				&& $convert +dither -layers Optimize v2gif-tmp-*.png GIF:- \
				| $gifsicle "${lossiness[@]}" --no-warnings --colors 256 --delay="$(echo "100/$fps" | bc)" --loop --optimize=3 --multifile - > "$output_file" || return 2
		fi

		rm v2gif-tmp-*.png

		# Checking if the file is bigger than Twitter likes and warn
		if [[ $alert -gt 0 ]]; then
			out_size=$(wc --bytes < "$output_file")
			if [[ $out_size -gt $((alert * 1000)) ]]; then
				echo "$(tput setaf 3)Warning: '$output_file' is $((out_size / 1000))kb.$(tput sgr 0)"
				[[ "$del_after" == "true" ]] && echo "$(tput setaf 3)Warning: Keeping '$file' even though --del requested.$(tput sgr 0)"
				del_after=""
			fi
		fi

		[[ "$del_after" = "true" ]] && rm "$file"

	done

	echo "$(tput setaf 2)Done.$(tput sgr 0)"
}

function any2webm() {
	about 'Converts an movies and Animated GIF files into an into a modern quality WebM video.'
	group 'gif'
	param '1: GIF/video file name(s)'
	param '2: -s <WxH> ; Optional: set <W>idth and <H>eight in pixels'
	param '3: -d       ; Optional: delete the original file if succeeded'
	param '4: -t       ; Optional: Tag the result with quality stamp for comparison use'
	param '5: -f <num> ; Optional: Change number of frames per second'
	param '6: -b <num> ; Optional: Set Bandwidth (quality/size of resulting file), Defaults to 2M (bits/sec, accepts fractions)"'
	param '7: -a <num> ; Optional: Alert if resulting file is over <num> kilobytes (default is 5000, 0 turns off)'
	example '$ any2webm foo.gif'
	example '$ any2webm *.mov -b 1.5M -s 600x480'

	local args out_size

	# Parse the options
	args=$(getopt -l alert -l "bandwidth:" -l "width:" -l del,delete -l tag -l "fps:" -l webm -o "a:b:w:f:dt" -- "$@") || {
		echo 'Terminating...' >&2
		return 2
	}

	eval set -- "$args"
	local opt_del_after=""
	local size=""
	local webmtagopt=""
	local webmtag=""
	local defaultfps=10
	local fps=""
	local bandwidth="2M"
	local alert=5000
	while [[ $# -ge 1 ]]; do
		case "$1" in
			--)
				# No more options left.
				shift
				break
				;;
			-d | --del | --delete)
				# Delete after
				opt_del_after="true"
				shift
				;;
			-s | --size)
				size="-s $2"
				webmtag="${webmtag}-s$2"
				shift 2
				;;
			-t | --tag)
				# mark with a quality tag
				webmtagopt="true"
				shift
				;;
			-f | --fps)
				# select fps
				fps="-r $2"
				webmtag="${webmtag}-f$2"
				shift 2
				;;
			-b | --bandwidth)
				# select bandwidth
				bandwidth="$2"
				webmtag="${webmtag}-b$2"
				shift 2
				;;
			-a | --alert)
				# set size alert
				alert="$2"
				shift 2
				;;
		esac
	done

	if [[ -z "$*" ]]; then
		echo "$(tput setaf 1)No input files given. Example: any2webm file [file...] [-w <max width (pixels)>] < $(tput sgr 0)"
		return 1
	fi

	# Prepare the quality tag if requested.
	[[ -z "$webmtag" ]] && webmtag="-default"
	[[ -z "$webmtagopt" ]] && webmtag=""

	for file; do

		local output_file="${file%.*}${webmtag}.webm"
		local del_after=$opt_del_after

		echo "$(tput setaf 2)Creating '$output_file' ...$(tput sgr 0)"

		$ffmpeg -loglevel warning -i "$file" \
			-c:v libvpx -crf 4 -threads 0 -an -b:v "$bandwidth" -auto-alt-ref 0 \
			-quality best "$fps" "$size" -loop 0 -pix_fmt yuva420p "$output_file" || return 2

		# Checking if the file is bigger than Twitter likes and warn
		if [[ $alert -gt 0 ]]; then
			out_size=$(wc --bytes < "$output_file")
			if [[ $out_size -gt $((alert * 1000)) ]]; then
				echo "$(tput setaf 3)Warning: '$output_file' is $((out_size / 1000))kb.$(tput sgr 0)"
				[[ "$del_after" == "true" ]] && echo "$(tput setaf 3)Warning: Keeping '$file' even though --del requested.$(tput sgr 0)"
				del_after=""
			fi
		fi

		[[ "$del_after" = "true" ]] && rm "$file"

	done

	echo "$(tput setaf 2)Done.$(tput sgr 0)"
}
