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
BARBUK_GITLAB_CHAR='  '
BARBUK_BITBUCKET_CHAR='  '
BARBUK_GITHUB_CHAR='  '
BARBUK_GIT_DEFAULT_CHAR='  '
BARBUK_GIT_BRANCH_ICON=''
BARBUK_HG_CHAR='☿ '
BARBUK_SVN_CHAR='⑆ '
BARBUK_NO_SCM_CHAR=''
BARBUK_EXIT_CODE_ICON=' '
```

### Customize glyphs

Define your custom glyphs before sourcing bash-it:

```bash
export BARBUK_GITHUB_CHAR='•'
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

