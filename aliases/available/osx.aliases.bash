# shellcheck shell=bash
about-alias 'osx-specific aliases'

# Desktop Programs
alias fireworks='open -a "/Applications/Adobe Fireworks CS3/Adobe Fireworks CS3.app"'
alias photoshop='open -a "/Applications/Adobe Photoshop CS3/Adobe Photoshop.app"'
alias preview='open -a "${PREVIEW?}"'
alias xcode='open -a "/Applications/XCode.app"'
alias filemerge='open -a "/Developer/Applications/Utilities/FileMerge.app"'
alias safari='open -a safari'
alias firefox='open -a firefox'
alias chrome='open -a "Google Chrome"'
alias chromium='open -a chromium'
alias brave='open -a "Brave Browser"'
alias dashcode='open -a dashcode'
alias f='open -a Finder '
alias fh='open -a Finder .'
alias textedit='open -a TextEdit'
alias hex='open -a "Hex Fiend"'
alias skype='open -a Skype'
alias mou='open -a Mou'
alias subl='open -a "Sublime Text"'

if [[ -s /usr/bin/firefox ]]; then
	unalias firefox
fi

# Requires growlnotify, which can be found in the Growl DMG under "Extras"
alias grnot='growlnotify -s -t Terminal -m "Done"'

# Get rid of those pesky .DS_Store files recursively
alias dsclean='find . -type f -name .DS_Store -delete'

# Track who is listening to your iTunes music
alias whotunes='lsof -r 2 -n -P -F n -c iTunes -a -i TCP@`hostname`:3689'

# Flush your dns cache
alias flush='dscacheutil -flushcache'

# Show/hide hidden files (for Mac OS X Mavericks)
alias showhidden='defaults write com.apple.finder AppleShowAllFiles TRUE'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles FALSE'

# From http://apple.stackexchange.com/questions/110343/copy-last-command-in-terminal
# shellcheck disable=SC2142 # The quoting confuses `shellcheck`...
alias copyLastCmd="fc -ln -1 | awk '{\$1=\$1}1' ORS='' | pbcopy"

# Use Finder's Quick Look on a file (^C or space to close)
alias ql='qlmanage -p 2>/dev/null'

# Mute/Unmute the system volume. Plays nice with all other volume settings.
alias mute='osascript -e "set volume output muted true"'
alias unmute='osascript -e "set volume output muted false"'

# Pin to the tail of long commands for an audible alert after long processes
## curl http://downloads.com/hugefile.zip; lmk
alias lmk='say "Process complete."'
