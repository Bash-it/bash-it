# youtube-dl bash completion start
__youtube_dl()
{
    local cur prev opts fileopts diropts keywords
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="--help --version --update --ignore-errors --abort-on-error --dump-user-agent --list-extractors --extractor-descriptions --force-generic-extractor --default-search --ignore-config --config-location --flat-playlist --mark-watched --no-mark-watched --no-color --proxy --socket-timeout --source-address --force-ipv4 --force-ipv6 --geo-verification-proxy --cn-verification-proxy --geo-bypass --no-geo-bypass --geo-bypass-country --geo-bypass-ip-block --playlist-start --playlist-end --playlist-items --match-title --reject-title --max-downloads --min-filesize --max-filesize --date --datebefore --dateafter --min-views --max-views --match-filter --no-playlist --yes-playlist --age-limit --download-archive --include-ads --limit-rate --retries --fragment-retries --skip-unavailable-fragments --abort-on-unavailable-fragment --keep-fragments --buffer-size --no-resize-buffer --http-chunk-size --test --playlist-reverse --playlist-random --xattr-set-filesize --hls-prefer-native --hls-prefer-ffmpeg --hls-use-mpegts --external-downloader --external-downloader-args --batch-file --id --output --autonumber-size --autonumber-start --restrict-filenames --auto-number --title --literal --no-overwrites --continue --no-continue --no-part --no-mtime --write-description --write-info-json --write-annotations --load-info-json --cookies --cache-dir --no-cache-dir --rm-cache-dir --write-thumbnail --write-all-thumbnails --list-thumbnails --quiet --no-warnings --simulate --skip-download --get-url --get-title --get-id --get-thumbnail --get-description --get-duration --get-filename --get-format --dump-json --dump-single-json --print-json --newline --no-progress --console-title --verbose --dump-pages --write-pages --youtube-print-sig-code --print-traffic --call-home --no-call-home --encoding --no-check-certificate --prefer-insecure --user-agent --referer --add-header --bidi-workaround --sleep-interval --max-sleep-interval --format --all-formats --prefer-free-formats --list-formats --youtube-include-dash-manifest --youtube-skip-dash-manifest --merge-output-format --write-sub --write-auto-sub --all-subs --list-subs --sub-format --sub-lang --username --password --twofactor --netrc --video-password --ap-mso --ap-username --ap-password --ap-list-mso --extract-audio --audio-format --audio-quality --recode-video --postprocessor-args --keep-video --no-post-overwrites --embed-subs --embed-thumbnail --add-metadata --metadata-from-title --xattrs --fixup --prefer-avconv --prefer-ffmpeg --ffmpeg-location --exec --convert-subs"
    keywords=":ytfavorites :ytrecommended :ytsubscriptions :ytwatchlater :ythistory"
    fileopts="-a|--batch-file|--download-archive|--cookies|--load-info"
    diropts="--cache-dir"

    if [[ ${prev} =~ ${fileopts} ]]; then
        COMPREPLY=( $(compgen -f -- ${cur}) )
        return 0
    elif [[ ${prev} =~ ${diropts} ]]; then
        COMPREPLY=( $(compgen -d -- ${cur}) )
        return 0
    fi

    if [[ ${cur} =~ : ]]; then
        COMPREPLY=( $(compgen -W "${keywords}" -- ${cur}) )
        return 0
    elif [[ ${cur} == * ]] ; then
        COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
        return 0
    fi
}

complete -F __youtube_dl youtube-dl
# youtube-dl bash completion start
