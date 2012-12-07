# Bash it

**Bash it** is a mash up of my own bash commands and scripts, other bash stuff I have found.

(And a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh). :)

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

## Install

There are currently two recommended ways you can employ to install Bash it

### Direct install

Using bash and curl automagically install Bash it directly from the master repository on github.

Copy and paste the following command (without the $) anywhere into a shell. Curl will retrieve the install script which then gets parsed and executed by bash. On detection of the direct installation process `install.sh` will first clone the repository into `~/.bash_it` before continuing with the installation.

1. Execute the install script directly from github:
```
$ bash -c "$(curl -s https://raw.github.com/revans/bash-it/master/install.sh)"
```

2. Edit your `~/.bash_profile` file in order to customize Bash it.

### Manual install

Using the same `install.sh` script by which the direct install is accomplished after manually cloning the repository first. You would probably want to check bash-it out into the folder `~/.bash_it` but anywhere else you choose also dosen't matter. The `install.sh` script will detect the location it is executed from, if this is not `~/.bash_it` a copy of the checked out folder  will automatically be copied to `~/.bash_it` on your behalf.

1. Check out a clone of the bash-it repository:
```
$ git clone http://github.com/revans/bash-it.git ~/.bash_it
```

2. Run the `install.sh` script (it automatically backs up your `~/.bash_profile`):
```
$ `~/.bash_it/install.sh
```

3. Edit your `~/.bash_profile` file in order to customize Bash it.

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
