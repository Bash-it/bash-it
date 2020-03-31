# BarbUk theme

A minimal theme with a clean git prompt

## Provided Information

* Current git remote tool logo (support: github, gitlab, bitbucket)
* Current path (red when user is root)
* Current git info
* Last command exit code (only shown when the exit code is greater than 0)

## Fonts and glyphs

A font with SCM glyphs is required to display the default tool/host logos.
You can use a font from https://www.nerdfonts.com/ or patch your own font with the tool
provided by https://github.com/ryanoasis/nerd-fonts.

You can also override the default variables if you want to use different glyphs or standard ASCII characters.

### Default theme glyphs

```bash
SCM_GIT_CHAR_GITLAB='  '
SCM_GIT_CHAR_BITBUCKET='  '
SCM_GIT_CHAR_GITHUB='  '
SCM_GIT_CHAR_DEFAULT='  '
SCM_GIT_CHAR_ICON_BRANCH=''
EXIT_CODE_ICON=' '
```

### Customize glyphs

Define your custom glyphs before sourcing bash-it:

```bash
SCM_GIT_CHAR_GITHUB='•'
source "$BASH_IT"/bash_it.sh
```

## Examples

### Clean

```bash
 ~ ❯ 
```

### Git

```bash
   ~/.dotfiles on  master ⤏  origin ↑2 •7 ✗ ❯
 ```

