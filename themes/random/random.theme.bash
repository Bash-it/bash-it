# Random theme - a fake theme that randomly chooses one of the existing themes and loads it.
# Yet another Oh-My-zsh feature

# pick a theme:
export BASH_IT_THEME=$( ls -w1 /home/cloudera/.bash_it/themes/  | grep -v .bash | grep -v random | sort -R | head -1 )
# load it the right way:
source "${BASH_IT}/lib/appearance.bash"
