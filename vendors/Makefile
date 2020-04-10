# Maybe this should be a bash script.
# This is however only ment to be run by developers.

help:
	@echo "make one of the following targets" 
	@echo
	@egrep "^[0-9a-zA-Z\-]+:$$" Makefile | grep -v "help:"

update-preexec:
	# - Maybe we should make this into a git-subtree(1) instead
	# - Maybe we should always supply a bash-it-init.bash file to the vendoer forlder so we have a 
	#   standardized way of loading vendor libs from bash_it.sh
	wget -q -O bash-preexec/preexec.bash https://github.com/rcaloras/bash-preexec/raw/master/bash-preexec.sh
	wget -q -O bash-preexec/LICENSE.md https://github.com/rcaloras/bash-preexec/raw/master/LICENSE.md
