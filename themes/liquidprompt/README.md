# Liquidprompt

[Liquidprompt](https://github.com/liquidprompt/liquidprompt) is GPL-licensed.
Bash-it is MIT-licensed, so this repository cannot vendor Liquidprompt's code
or install it on your behalf.

`liquidprompt.theme.bash` is only a thin wrapper: it activates Liquidprompt
if you already have it installed and available on your `PATH`, and otherwise
prints a warning. It does not download, clone, or bundle Liquidprompt in any
way (this used to `git clone` it at runtime, which we no longer do).

## Installing Liquidprompt

Install it yourself following the instructions at the
[Liquidprompt project](https://github.com/liquidprompt/liquidprompt), then
enable this theme with:

```bash
export BASH_IT_THEME=liquidprompt
```
