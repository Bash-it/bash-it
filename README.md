# Bash it

[![Build Status](https://travis-ci.org/Bash-it/bash-it.svg?branch=master)](https://travis-ci.org/Bash-it/bash-it) [![Join the chat at https://gitter.im/Bash-it/bash-it](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Bash-it/bash-it?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**Bash it** is a collection of community bash commands and scripts. (And a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) :smiley:)

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

Bash it provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work. If you're using the _Bourne Again Shell_ (Bash) on a regular basis and have been looking for an easy way on how to keep all of these nice little scripts and aliases under control, then Bash it is for you! Stop polluting your `~/bin` directory and your `.bashrc` file, fork/clone Bash it and start hacking away.

## Install

1. Check a clone of this repo: `git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it`
2. Run `~/.bash_it/install.sh` (it automatically backs up your `~/.bash_profile` or `~/.bashrc`, depending on your OS)
3. Edit your modified config (`~/.bash_profile` or `~/.bashrc`) file in order to customize Bash it.
4. Check out available aliases, completions and plugins and enable the ones you want to use (see the next section for more details).

**INSTALL OPTIONS:**
The install script can take the following options:

* `--interactive`: Asks the user which aliases, completions and plugins to enable.

When run without the `--interactive` switch, Bash it only enables a sane default set of functionality to keep your shell lean and to avoid issues with missing dependencies. Feel free to enable the tools you want to use after the installation.

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
* `completion/custom.completion.bash`
* `lib/custom.bash`
* `plugins/custom.plugins.bash`

Anything in the custom directory will be ignored, with the exception of `custom/example.bash`.

## Themes

There are a few bash it themes. If you've created your own custom prompts, I'd love it if you shared with everyone else! Just submit a Pull Request.

You can see the theme screenshots [here](https://github.com/Bash-it/bash-it/wiki/Themes)

Alternatively, you can preview the themes in your own shell using `BASH_PREVIEW=true reload`

## Uninstalling

To uninstall Bash it, run the `uninstall.sh` script found in the `$BASH_IT` directory:

```
cd $BASH_IT
./uninstall.sh
```

This will restore your previous Bash profile. After the uninstall script finishes, remove the Bash it directory from your machine (`rm -rf $BASH_IT`) and start a new shell.

## Misc

### Bash Profile Aliases

Bash it creates a `reload` alias that makes it convenient to reload
your bash profile when you make changes.

### Prompt Version Control Check

Bash it provides prompt themes the ability to check and display version control information for the current directory. The information is retrieved for each directory and can slow down the navigation of projects with a large number of files and folders. Turn version control checking off to prevent slow directory navigation within large projects.

Bash it provides a flag (`SCM_CHECK`) within the `~/.bash_profile` file that turns off/on version control information checking and display within all themes. Version control checking is on by default unless explicitly turned off.

Set `SCM_CHECK` to 'false' to **turn off** version control checks for all themes:

* `export SCM_CHECK=false`

Set `SCM_CHECK` to 'true' (the default value) to **turn on** version control checks for all themes:

* `export SCM_CHECK=true`

**NOTE:**
It is possible for themes to ignore the `SCM_CHECK` flag and query specific version control information directly. For example, themes that use functions like `git_prompt_vars` skip the `SCM_CHECK` flag to retrieve and display git prompt information. If you turned version control checking off and you still see version control information within your prompt, then functions like `git_prompt_vars` are most likely the reason why.

### Git prompt

Bash it has some nice features related to Git, continue reading to know more about these features.

#### Repository info in the prompt

Bash it can show some information about Git repositories in the shell prompt: the current branch, tag or commit you are at, how many commits the local branch is ahead or behind from the remote branch, and if you have changes stashed.

Additionally, you can view the status of your working copy and get the count of *staged*, *unstaged* and *untracked* files. This feature is controlled through the flag `SCM_GIT_SHOW_DETAILS` as follows:

Set `SCM_GIT_SHOW_DETAILS` to 'true' (the default value) to **show** the working copy details in your prompt:

* `export SCM_GIT_SHOW_DETAILS=true`

Set `SCM_GIT_SHOW_DETAILS` to 'false' to **don't show** it:

* `export SCM_GIT_SHOW_DETAILS=false`

#### Remotes and remote branches

In some git workflows you must work with various remotes, for this reason, Bash it can provide some useful information about your remotes and your remote branches, for example, the remote on you are working, or if your local branch is tracking a remote branch.

You can control this feature with the flag `SCM_GIT_SHOW_REMOTE_INFO` as follows:

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'auto' (the default value) to activate it only when more than one remote is configured in the current repo:

* `export SCM_GIT_SHOW_REMOTE_INFO=auto`

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'true' to always activate the feature:

* `export SCM_GIT_SHOW_REMOTE_INFO=true`

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'false' to **disable the feature**:

* `export SCM_GIT_SHOW_REMOTE_INFO=false`

#### Untracked files

By default, `git status` command shows information about *untracked* files, this behavior can be controlled through command line flags or git configuration files, for big repositories, ignoring *untracked* files can make git faster. Bash it uses `git status` to gather the repo information it shows in the prompt, so in some circumstances, can be useful to instruct Bash it to ignore these files. You can control this behavior with the flag `SCM_GIT_IGNORE_UNTRACKED`:

Set `SCM_GIT_IGNORE_UNTRACKED` to 'false' (the default value) to get information about *untracked* files:

* `export SCM_GIT_IGNORE_UNTRACKED=false`

Set `SCM_GIT_IGNORE_UNTRACKED` to 'true' to **ignore** *untracked* files:

* `export SCM_GIT_IGNORE_UNTRACKED=true`

also, with this flag to false, Bash it will not show the repository as dirty when the repo have *untracked* files, and will not display the count of *untracked* files.

**NOTE:** If you set in git configuration file the option to ignore *untracked* files, this flag has no effect, and Bash it will ignore *untracked* files always.

### pass function renamed to passgen

The Bash it `pass` function has been renamed to `passgen` in order to avoid a naming conflict with the [pass password manager]. In order to minimize the impact on users of the legacy Bash it `pass` function, Bash it will create the alias `pass` that calls the new `passgen` function if the `pass` password manager command is not found on the `PATH` (default behavior).

This behavior can be overridden with the `BASH_IT_LEGACY_PASS` flag as follows:

Set `BASH_IT_LEGACY_PASS` to 'true' to force Bash it to always **create** the `pass` alias to `passgen`:

* `export BASH_IT_LEGACY_PASS=true`

Unset `BASH_IT_LEGACY_PASS` to have Bash it **return to default behavior**:

* `unset BASH_IT_LEGACY_PASS`

### Proxy Support

If you are working in a corporate environment where you have to go through a proxy server for internet access, then you know how painful it is to configure the OS proxy variables in the shell, especially if you are switching between environments, e.g. office (with proxy) and home (without proxy).

The Bash shell (and many shell tools) use the following variables to define the proxy to use:

* `HTTP_PROXY` (and `http_proxy`): Defines the proxy server for HTTP requests
* `HTTPS_PROXY` (and `https_proxy`): Defines the proxy server for HTTPS requests
* `ALL_PROXY` (and `all_proxy`): Used by some tools for the same purpose as above
* `NO_PROXY` (and `no_proxy`): Comma-separated list of hostnames that don't have to go through the proxy

Bash it's `proxy` plugin allows to enable and disable these variables with a simple command. To start using the `proxy` plugin, run the following:

```bash
bash-it enable plugin proxy
```

Bash it also provides support for enabling/disabling proxy settings for various shell tools. The following backends are currently supported (in addition to the shell's environment variables): Git, SVN, npm, ssh. The `proxy` plugin changes the configuration files of these tools to enable or disable the proxy settings.

Bash-it uses the following variables to set the shell's proxy settings when you call `enable-proxy`.
These variables are best defined in a custom script in Bash-it's custom script folder (`$BASH_IT/custom`), e.g. `$BASH_IT/custom/proxy.env.bash`
* `BASH_IT_HTTP_PROXY` and `BASH_IT_HTTPS_PROXY`: Define the proxy URL to be used, e.g. 'http://localhost:1234'
* `BASH_IT_NO_PROXY`: A comma-separated list of proxy exclusions, e.g. `127.0.0.1,localhost`

Once you have defined these variables (and have run `reload` to load the changes), you can use the following commands to enable or disable the proxy settings in your current shell:

* `enable-proxy`: This sets the shell's proxy environment variables and configures proxy support in your SVN, npm and SSH configuration files.
* `disable-proxy`: This unsets the shell's proxy environment variables and disables proxy support in your SVN, npm and SSH configuration files.

There are many more proxy commands, e.g. for changing the local Git project's proxy settings. Run `glossary proxy` to show the available proxy functions with a short description.

## Help out

We think everyone has their own custom scripts accumulated over time. And so, following in the footsteps of oh-my-zsh, Bash it is a framework for easily customizing your bash shell. Everyone's got a custom toolbox, so let's start making them even better, **as a community!**

Send us a pull request and we'll merge it as long as it looks good. If you change an existing command, please give an explanation why. That will help a lot when we merge your changes in.

Thanks, and happing bashing!


## Contributors

* [List of contributors][contribute]

[contribute]: https://github.com/Bash-it/bash-it/contributors
[pass password manager]: http://www.passwordstore.org/
