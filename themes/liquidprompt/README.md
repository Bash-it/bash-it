# Liquidprompt

[Liquidprompt](https://github.com/liquidprompt/liquidprompt) is GPL-licensed,
while Bash-it is MIT-licensed. To keep the two separate, this theme does not
bundle, patch, or install Liquidprompt: it only sources a copy you installed
yourself and relies on nothing but its public interface.

`liquidprompt.theme.bash` is only a thin wrapper: it activates Liquidprompt
if you already have it installed, and otherwise prints a warning. It looks
for `~/liquidprompt/liquidprompt` (the location suggested in the Liquidprompt
installation docs) first, then for `liquidprompt` on your `PATH`. If you
installed it elsewhere, `source` it from your own configuration instead. It does not download, clone, or bundle Liquidprompt in any
way (this used to `git clone` it at runtime, which we no longer do).

## Installing Liquidprompt

Install it yourself following the instructions at the
[Liquidprompt project](https://github.com/liquidprompt/liquidprompt), then
enable this theme with:

```bash
export BASH_IT_THEME=liquidprompt
```
