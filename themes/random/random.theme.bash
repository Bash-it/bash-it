# Random theme - a fake theme that randomly chooses one of the existing themes and loads it.
# Yet another Oh-My-zsh feature

# pick a theme:
export BASH_IT_THEME=$( ls -w1 ${BASH_IT}/themes/  | grep -v .bash | grep -v random | sort -R | head -1 )
echo "using theme: ${BASH_IT_THEME}"
source "${BASH_IT}/themes/${BASH_IT_THEME}/${BASH_IT_THEME}.theme.bash"
