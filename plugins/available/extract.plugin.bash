cite about-plugin
about-plugin 'one command to extract them all...'
extract () {
  if [ $# -ne 1 ]
  then
    echo "Error: No file specified."
    return 1
  fi
	if [ -f "$1" ] ; then
		case "$1" in
			*.tar.bz2)  tar xvjf "$1"             ;;
			*.tar.gz)   tar xvzf "$1"             ;;
			*.tar.xz|*.txz)
                                    xz -dc "$1" | tar xvf -   ;;
			*.tar.lzma) ( xz -dc "$1" || lzma -dc "$1" ) | tar xvf - ;;
			*.tar.lzop) lzop -d -c "$1" | tar xvf - ;;
			*.tar.lzip) lzip -d -c "$1" | tar xvf - ;;
			*.cpio.gz|*.cpio.Z)
				    gzip -dc "$1" | cpio -itvm ;;
			*.cpio.bz2) bzip2 -dc "$1" | cpio -itvm ;;
			*.cpio.xz)  xz -dc "$1" | cpio -itvm  ;;
			*.cpio)     cpio -itvm < "$1"         ;;
			*.bz2)      bunzip2 "$1"              ;;
			*.rar)      unrar x "$1"              ;;
			*.gz)       gunzip "$1"               ;;
			*.tar)      tar xvf "$1"              ;;
			*.tbz2)     tar xvjf "$1"             ;;
			*.tgz)      tar xvzf "$1"             ;;
			*.zip)      unzip "$1"                ;;
			*.jar)      unzip "$1"                ;;
			*.Z)        (uncompress "$1" || gzip -dc "$1") ;;
			*.7z)       7z x "$1"                 ;;
			*.lzma)     (xz -dc "$1" || lzma -d "$1") ;;
			*.lzop)     lzop -d "$1"              ;;
			*.lzip)     lzip -d "$1"              ;;
			*.xz)       xz -d "$1"                ;;
			*)          echo "'$1' cannot be extracted via extract" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}
