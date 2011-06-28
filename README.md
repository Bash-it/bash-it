# Bash it

'Bash it' is a mash up of my own bash commands and scripts, other bash stuff I have found and a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh). :)

Includes some autocompletion tools, theming support, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

## Install

Check a clone of this repo:

	git clone http://github.com/revans/bash-it.git bash_it

Then run the `install.sh` file, it will backup your `~/.bash_profile`
file and move the template one into it's place (the template file is at
`~/.bash_it/template/bash_profile.template.bash`). Be sure to edit this
template file in order to customize bash-it.

The install script will also prompt
you asking if you use [Jekyll](https://github.com/mojombo/jekyll). This
is to set up the `.jekyllconfig` file, the file that stores the
information needed to use the Jekyll plugin supplied with bash it.


## Help Screens

	bash-it (will show all the help commands)
	aliases-help
	rails-help
	git-help
    plugins-help

## Your Custom scripts, aliases, and functions

For custom scripts, and aliases, you can create the following files and they will be ignored by the git repo:

* `aliases/custom.aliases.bash`
* `lib/custom.bash`
* `plugins/custom.plugins.bash`

and anything in the custom directory will be ignored with the exception of `custom/example.bash`.

## Themes

There are a few bash it themes, but I'm hoping the community will jump in and create their own custom prompts and share their creations with everyone else by submitting a pull request to me (revans).

## Help out

I think all of us have our own custom scripts that we have added over time and so following in the footsteps of oh-my-zsh, bash it was created as a framework for those who choose to use bash as their shell. As a community, I'm excited to see what everyone else has in their custom toolbox and am hoping that they'll share it with everyone by submitting a pull request to bash it.

So, if you have contributions to bash it, please send me a pull request and I'll take a look at it and commit it to the repo as long as it looks good. If you do change an existing command, please give an explanation as to why. That will help a lot when I merge your changes in. Thanks, and happing bashing!


## Contributors

* [List of contributors][contribute]

[contribute]: https://github.com/revans/bash-it/contributors
