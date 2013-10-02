# Bash it

**Bash it** is a mash up of my own bash commands and scripts, other bash stuff I have found.

(And a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh). :)

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

## Install

1. Check a clone of this repo: `git clone https://github.com/revans/bash-it.git ~/.bash_it`
2. Run `~/.bash_it/install.sh` (it automatically backs up your `~/.bash_profile`)
3. Edit your `~/.bash_profile` file in order to customize bash-it.

**NOTE:**
The install script will also prompt you asking if you use [Jekyll](https://github.com/mojombo/jekyll).
This is to set up the `.jekyllconfig` file, which stores info necessary to use the Jekyll plugin.


## Help Screens

```
bash-it show aliases        # shows installed and available aliases
bash-it show completions    # shows installed and available completions
bash-it show plugins        # shows installed and available plugins
bash-it help aliases        # shows help for installed aliases
bash-it help completions    # shows help for installed completions
bash-it help plugins        # shows help for installed plugins
```

## Your Custom scripts, aliases, and functions

For custom scripts, and aliases, just create the following files (they'll be ignored by the git repo):

* `aliases/custom.aliases.bash`
* `lib/custom.bash`
* `plugins/custom.plugins.bash`

Anything in the custom directory will be ignored, with the exception of `custom/example.bash`.

## Themes

There are a few bash it themes.  If you've created your own custom prompts, I'd love it if you shared with everyone else!  Just submit a Pull Request to me (revans).

## Help out

I think everyone has their own custom scripts accumulated over time.  And so, following in the footsteps of oh-my-zsh, bash it is a framework for easily customizing your bash shell. Everyone's got a custom toolbox, so let's start making them even better, **as a community!**

Send me a pull request and I'll merge it as long as it looks good. If you change an existing command, please give an explanation why. That will help a lot when I merge your changes in.

Thanks, and happing bashing!


## Contributors

* [List of contributors][contribute]

[contribute]: https://github.com/revans/bash-it/contributors
