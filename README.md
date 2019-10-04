# Bash-it

[![Build Status](https://travis-ci.org/Bash-it/bash-it.svg?branch=master)](https://travis-ci.org/Bash-it/bash-it) [![Join the chat at https://gitter.im/Bash-it/bash-it](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Bash-it/bash-it?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

**Bash-it** is a collection of community Bash commands and scripts for Bash 3.2+.
(And a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) :smiley:)

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

Bash-it provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work.
If you're using the _Bourne Again Shell_ (Bash) regularly and have been looking for an easy way on how to keep all of these nice little scripts and aliases under control, then Bash-it is for you!
Stop polluting your `~/bin` directory and your `.bashrc` file, fork/clone Bash-it and start hacking away.

- [Contributing](#contributing)
- [Installation](#installation)
  - [Install Options](#install-options)
  - [via Docker](#install-using-docker)
  - [Updating](#updating)
- [Help](#help-screens)
- [Search](#search)
  - [Syntax](#syntax)
  - [Searching with Negations](#searching-with-negations)
  - [Using Search to Enable or Disable Components](#using-search-to-enable-or-disable-components)
  - [Disabling ASCII Color](#disabling-ascii-color)
- [Custom scripts, aliases, themes, and functions](#custom-scripts-aliases-themes-and-functions)
- [Themes](#themes)
- [Uninstalling](#uninstalling)
- [Misc](#misc)
- [Help Out](#help-out)
- [Contributors](#contributors)

## Contributing

Please take a look at the [Contribution Guidelines](CONTRIBUTING.md) before reporting a bug or providing a new feature.

The [Development Guidelines](DEVELOPMENT.md) have more information on some of the internal workings of Bash-it,
please feel free to read through this page if you're interested in how Bash-it loads its components.

## Installation

1. Check out a clone of this repo to a location of your choice, such as
   `git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it`
2. Run `~/.bash_it/install.sh` (it automatically backs up your `~/.bash_profile` or `~/.bashrc`, depending on your OS)
3. Edit your modified config (`~/.bash_profile` or `~/.bashrc`) file in order to customize Bash-it.
4. Check out available aliases, completions, and plugins and enable the ones you want to use (see the next section for more details).

### Install Options

The install script can take the following options:

* `--interactive`: Asks the user which aliases, completions and plugins to enable.
* `--silent`: Ask nothing and install using default settings.
* `--no-modify-config`: Do not modify the existing config file (`~/.bash_profile` or `~/.bashrc`).

When run without the `--interactive` switch, Bash-it only enables a sane default set of functionality to keep your shell clean and to avoid issues with missing dependencies.
Feel free to enable the tools you want to use after the installation.

When you run without the `--no-modify-config` switch, the Bash-it installer automatically modifies/replaces your existing config file.
Use the `--no-modify-config` switch to avoid unwanted modifications, e.g. if your Bash config file already contains the code that loads Bash-it.

**NOTE**: Keep in mind how Bash loads its configuration files,
`.bash_profile` for login shells (and in macOS in terminal emulators like [Terminal.app](http://www.apple.com/osx/apps/) or
[iTerm2](https://www.iterm2.com/)) and `.bashrc` for interactive shells (default mode in most of the GNU/Linux terminal emulators),
to ensure that Bash-it is loaded correctly.
A good "practice" is sourcing `.bashrc` into `.bash_profile` to keep things working in all the scenarios.
To achieve this, you can add this snippet in your `.bash_profile`:

```
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
```

Refer to the official [Bash documentation](https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files) to get more info.


### Install using Docker

You can try Bash-it in an isolated environment without changing any local files via a [Docker](https://www.docker.com/) Container.
(Bash Shell v4.4 with Bash-it, [bats](https://github.com/sstephenson/bats),and bash-completion based on [Alpine Linux](https://alpinelinux.org/)).

`docker pull ellerbrock/bash-it`

Have a look at our [bash-it-docker repository](https://github.com/Bash-it/bash-it-docker) for further information.


### Updating

To update Bash-it to the latest version, simply run:

```bash
bash-it update
```

that's all.

If you are using an older version of Bash-it, it's possible that some functionality has changed, or that the internal structure of how Bash-it organizes its functionality has been updated.
For these cases, we provide a `migrate` command:

```bash
bash-it migrate
```

This command will automatically migrate the Bash-it structure to the latest version.
The `migrate` command is run automatically if you run the `update`, `enable` or `disable` commands.

## Help Screens

```bash
bash-it show aliases        # shows installed and available aliases
bash-it show completions    # shows installed and available completions
bash-it show plugins        # shows installed and available plugins
bash-it help aliases        # shows help for installed aliases
bash-it help completions    # shows help for installed completions
bash-it help plugins        # shows help for installed plugins
```

## Search

If you need to quickly find out which of the plugins, aliases or completions are available for a specific framework, programming language, or an environment, you can _search_ for multiple terms related to the commands you use frequently.
Search will find and print out modules with the name or description matching the terms provided.

### Syntax

```bash
  bash-it search term1 [[-]term2] [[-]term3]....
```

As an example, a ruby developer might want to enable everything related to the commands such as `ruby`, `rake`, `gem`, `bundler`, and `rails`.
Search command helps you find related modules so that you can decide which of them you'd like to use:

```bash
❯ bash-it search ruby rake gem bundle irb rails
      aliases:  bundler rails
      plugins:  chruby chruby-auto ruby
  completions:  bundler gem rake
```

Currently enabled modules will be shown in green.

### Searching with Negations

You can prefix a search term with a "-" to exclude it from the results.
In the above example, if we wanted to hide `chruby` and `chruby-auto`,
we could change the command as follows:

```bash
❯ bash-it search ruby rake gem bundle irb rails -chruby
      aliases:  bundler rails
      plugins:  ruby
  completions:  bundler gem rake
```

### Using Search to Enable or Disable Components

By adding a `--enable` or `--disable` to the search command, you can automatically enable all modules that come up as a result of a search query.
This could be quite handy if you like to enable a bunch of components related to the same topic.

### Disabling ASCII Color

To remove non-printing non-ASCII characters responsible for the coloring of the search output, you can set environment variable `NO_COLOR`.
Enabled components will then be shown with a checkmark:

```bash
❯ NO_COLOR=1 bash-it search ruby rake gem bundle irb rails -chruby
      aliases  =>   ✓bundler ✓rails
      plugins  =>   ✓ruby
  completions  =>   bundler gem rake
```

## Custom scripts, aliases, themes, and functions

For custom scripts, and aliases, just create the following files (they'll be ignored by the git repo):

* `aliases/custom.aliases.bash`
* `completion/custom.completion.bash`
* `lib/custom.bash`
* `plugins/custom.plugins.bash`
* `custom/themes/<custom theme name>/<custom theme name>.theme.bash`

Anything in the custom directory will be ignored, with the exception of `custom/example.bash`.

Alternately, if you would like to keep your custom scripts under version control, you can set `BASH_IT_CUSTOM` in your `~/.bashrc` to another location outside of the `$BASH_IT` folder.
In this case, any `*.bash` file under every directory below `BASH_IT_CUSTOM` folder will be used.

## Themes

There are over 50+ Bash-it themes to pick from in `$BASH_IT/themes`.
The default theme is `bobby`.
Set `BASH_IT_THEME` to the theme name you want, or if you've developed your own custom theme outside of `$BASH_IT/themes`,
point the `BASH_IT_THEME` variable directly to the theme file.
To disable theming completely, leave the variable empty.

Examples:

```bash
# Use the "powerline-multiline" theme
export BASH_IT_THEME="powerline-multiline"

# Use a theme outside of the Bash-it folder
export BASH_IT_THEME="/home/foo/my_theme/my_theme.theme.bash"

# Disable theming
export BASH_IT_THEME=""
```

You can easily preview the themes in your own shell using `BASH_PREVIEW=true bash-it reload`.

If you've created your own custom prompts, we'd love it if you shared them with everyone else! Just submit a Pull Request.
You can see theme screenshots on [wiki/Themes](https://github.com/Bash-it/bash-it/wiki/Themes).

**NOTE**: Bash-it and some themes use UTF-8 characters, so to avoid strange behavior in your terminal, set your locale to `LC_ALL=en_US.UTF-8` or the equivalent to your language if it isn't American English.

## Uninstalling

To uninstall Bash-it, run the `uninstall.sh` script found in the `$BASH_IT` directory:

```
cd $BASH_IT
./uninstall.sh
```

This will restore your previous Bash profile.
After the uninstall script finishes, remove the Bash-it directory from your machine (`rm -rf $BASH_IT`) and start a new shell.

## Misc

### Bash Profile Aliases

Bash-it creates a `reload` alias that makes it convenient to reload
your Bash profile when you make changes.

Additionally, if you export `BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE` as a non-null value,
Bash-it will automatically reload itself after activating or deactivating plugins, aliases, or completions.

### Prompt Version Control Check

Bash-it provides prompt themes with the ability to check and display version control information for the current directory.
The information is retrieved for each directory and can slow down the navigation of projects with a large number of files and folders.
Turn version control checking off to prevent slow directory navigation within large projects.

Bash-it provides a flag (`SCM_CHECK`) within the `~/.bash_profile` file that turns off/on version control information checking and display within all themes.
Version control checking is on by default unless explicitly turned off.

Set `SCM_CHECK` to 'false' to **turn off** version control checks for all themes:

* `export SCM_CHECK=false`

Set `SCM_CHECK` to 'true' (the default value) to **turn on** version control checks for all themes:

* `export SCM_CHECK=true`

**NOTE:**
It is possible for themes to ignore the `SCM_CHECK` flag and query specific version control information directly.
For example, themes that use functions like `git_prompt_vars` skip the `SCM_CHECK` flag to retrieve and display git prompt information.
If you turned version control checking off and you still see version control information within your prompt, then functions like `git_prompt_vars` are most likely the reason why.

### Git prompt

Bash-it has some nice features related to Git, continue reading to know more about these features.

### Repository info in the prompt

Bash-it can show some information about Git repositories in the shell prompt: the current branch, tag or commit you are at, how many commits the local branch is ahead or behind from the remote branch, and if you have changes stashed.

Additionally, you can view the status of your working copy and get the count of *staged*, *unstaged* and *untracked* files.
This feature is controlled through the flag `SCM_GIT_SHOW_DETAILS` as follows:

Set `SCM_GIT_SHOW_DETAILS` to 'true' (the default value) to **show** the working copy details in your prompt:

* `export SCM_GIT_SHOW_DETAILS=true`

Set `SCM_GIT_SHOW_DETAILS` to 'false' to **don't show** it:

* `export SCM_GIT_SHOW_DETAILS=false`

**NOTE:** If using `SCM_GIT_SHOW_MINIMAL_INFO=true`, then the value of `SCM_GIT_SHOW_DETAILS` is ignored.

### Remotes and remote branches

In some git workflows, you must work with various remotes, for this reason, Bash-it can provide some useful information about your remotes and your remote branches, for example, the remote on you are working, or if your local branch is tracking a remote branch.

You can control this feature with the flag `SCM_GIT_SHOW_REMOTE_INFO` as follows:

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'auto' (the default value) to activate it only when more than one remote is configured in the current repo:

* `export SCM_GIT_SHOW_REMOTE_INFO=auto`

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'true' to always activate the feature:

* `export SCM_GIT_SHOW_REMOTE_INFO=true`

Set `SCM_GIT_SHOW_REMOTE_INFO` to 'false' to **disable the feature**:

* `export SCM_GIT_SHOW_REMOTE_INFO=false`

**NOTE:** If using `SCM_GIT_SHOW_MINIMAL_INFO=true`, then the value of `SCM_GIT_SHOW_REMOTE_INFO` is ignored.

### Untracked files

By default, the `git status` command shows information about *untracked* files.
This behavior can be controlled through command-line flags or git configuration files.
For big repositories, ignoring *untracked* files can make git faster.
Bash-it uses `git status` to gather the repo information it shows in the prompt, so in some circumstances, it can be useful to instruct Bash-it to ignore these files.
You can control this behavior with the flag `SCM_GIT_IGNORE_UNTRACKED`:

Set `SCM_GIT_IGNORE_UNTRACKED` to 'false' (the default value) to get information about *untracked* files:

* `export SCM_GIT_IGNORE_UNTRACKED=false`

Set `SCM_GIT_IGNORE_UNTRACKED` to 'true' to **ignore** *untracked* files:

* `export SCM_GIT_IGNORE_UNTRACKED=true`

Also, with this flag to false, Bash-it will not show the repository as dirty when the repo has *untracked* files, and will not display the count of *untracked* files.

**NOTE:** If you set in git configuration file the option to ignore *untracked* files, this flag has no effect, and Bash-it will ignore *untracked* files always.

### Stash item count

When `SCM_GIT_SHOW_DETAILS` is enabled, you can get the count of *stashed* items. This feature can be useful when a user has a lot of stash items.
This feature is controlled through the flag `SCM_GIT_SHOW_STASH_INFO` as follows:

Set `SCM_GIT_SHOW_STASH_INFO` to 'true' (the default value) to **show** the count of stashed items:

* `export SCM_GIT_SHOW_STASH_INFO=true`

Set `SCM_GIT_SHOW_STASH_INFO` to 'false' to **don't show** it:

* `export SCM_GIT_SHOW_STASH_INFO=false`

### Ahead/Behind Count

When displaying information regarding whether or not the local branch is ahead or behind its remote counterpart, you can opt to display the number of commits ahead/behind.
This is useful if you only care whether or not you are ahead or behind and do not care how far ahead/behind you are.

Set `SCM_GIT_SHOW_COMMIT_COUNT` to 'true' (the default value) to **show** the count of commits ahead/behind:

* `export SCM_GIT_SHOW_COMMIT_COUNT=true`

Set `SCM_GIT_SHOW_COMMIT_COUNT` to 'false' to **don't show** it:

* `export SCM_GIT_SHOW_COMMIT_COUNT=false`

### Git user

In some environments, it is useful to know the value of the current git user, which is used to mark all new commits.
For example, any organization that uses the practice of pair programming will typically author each commit with [combined names of the two authors](https://github.com/pivotal/git_scripts).
When another pair uses the same pairing station, the authors are changed at the beginning of the session.

To get up and running with this technique, run `gem install pivotal_git_scripts`, and then edit your `~/.pairs` file, according to the specification on the [gem's homepage](https://github.com/pivotal/git_scripts).
After that, you should be able to run `git pair kg as` to set the author to, eg. "Konstantin Gredeskoul and Alex Saxby", assuming they've been added to the `~/.pairs` file.
Please see gem's documentation for more information.

To enable the display of the current pair in the prompt, you must set `SCM_GIT_SHOW_CURRENT_USER` to `true`.
Once set, the `SCM_CURRENT_USER` variable will be automatically populated with the initials of the git author(s).
It will also be included in the default git prompt.
Even if you do not have `git pair` installed, as long as your `user.name` is set, your initials will be computed from your name and shown in the prompt.

You can control the prefix and the suffix of this component using the two variables:

* `export SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '`

And

* `export SCM_THEME_CURRENT_USER_SUFFIX=' ☺︎ '`

**NOTE:** If using `SCM_GIT_SHOW_MINIMAL_INFO=true`, then the value of `SCM_GIT_SHOW_CURRENT_USER` is ignored.

### Git show minimal status info

To speed up the prompt while still getting minimal git status information displayed such as the value of `HEAD` and whether there are any dirty objects, you can set:

```
export SCM_GIT_SHOW_MINIMAL_INFO=true
```

### Ignore repo status

When working in repos with a large codebase, Bash-it can slow down your prompt when checking the repo status.
To avoid it, there is an option you can set via Git config to disable checking repo status in Bash-it.

To disable checking the status in the current repo:

```
$ git config --add bash-it.hide-status 1
```

But if you would like to disable it globally, and stop checking the status for all of your repos:

```
$ git config --global --add bash-it.hide-status 1
```

Setting this flag globally has the same effect as `SCM_CHECK=true`, but only for Git repos.

### Pass function renamed to passgen

The Bash-it `pass` function has been renamed to `passgen` in order to avoid a naming conflict with the [pass password manager](https://www.passwordstore.org/).
In order to minimize the impact on users of the legacy Bash-it `pass` function, Bash-it will create the alias `pass` that calls the new `passgen` function if the `pass` password manager command is not found on the `PATH` (default behavior).

This behavior can be overridden with the `BASH_IT_LEGACY_PASS` flag as follows:

Set `BASH_IT_LEGACY_PASS` to 'true' to force Bash-it to always **create** the `pass` alias to `passgen`:

* `export BASH_IT_LEGACY_PASS=true`

Unset `BASH_IT_LEGACY_PASS` to have Bash-it **return to default behavior**:

* `unset BASH_IT_LEGACY_PASS`

### Proxy Support

If you are working in a corporate environment where you have to go through a proxy server for internet access,
then you know how painful it is to configure the OS proxy variables in the shell,
especially if you are switching between environments, e.g. office (with proxy) and home (without proxy).

The Bash shell (and many shell tools) use the following variables to define the proxy to use:

* `HTTP_PROXY` (and `http_proxy`): Defines the proxy server for HTTP requests
* `HTTPS_PROXY` (and `https_proxy`): Defines the proxy server for HTTPS requests
* `ALL_PROXY` (and `all_proxy`): Used by some tools for the same purpose as above
* `NO_PROXY` (and `no_proxy`): Comma-separated list of hostnames that don't have to go through the proxy

Bash-it's `proxy` plugin allows to enable and disable these variables with a simple command.
To start using the `proxy` plugin, run the following:

```bash
bash-it enable plugin proxy
```

Bash-it also provides support for enabling/disabling proxy settings for various shell tools.
The following backends are currently supported (in addition to the shell's environment variables): Git, SVN, npm, ssh.
The `proxy` plugin changes the configuration files of these tools to enable or disable the proxy settings.

Bash-it uses the following variables to set the shell's proxy settings when you call `enable-proxy`.
These variables are best defined in a custom script in Bash-it's custom script folder (`$BASH_IT/custom`), e.g. `$BASH_IT/custom/proxy.env.bash`
* `BASH_IT_HTTP_PROXY` and `BASH_IT_HTTPS_PROXY`: Define the proxy URL to be used, e.g. 'http://localhost:1234'
* `BASH_IT_NO_PROXY`: A comma-separated list of proxy exclusions, e.g. `127.0.0.1,localhost`

Once you have defined these variables (and have run `reload` to load the changes), you can use the following commands to enable or disable the proxy settings in your current shell:

* `enable-proxy`: This sets the shell's proxy environment variables and configures proxy support in your SVN, npm, and SSH configuration files.
* `disable-proxy`: This unsets the shell's proxy environment variables and disables proxy support in your SVN, npm, and SSH configuration files.

There are many more proxy commands, e.g. for changing the local Git project's proxy settings.
Run `glossary proxy` to show the available proxy functions with a short description.

## Help out

We think everyone has their own custom scripts accumulated over time.
And so, following in the footsteps of oh-my-zsh, Bash-it is a framework for easily customizing your Bash shell.
Everyone's got a custom toolbox, so let's start making them even better, **as a community!**

Send us a pull request and we'll merge it as long as it looks good.
If you change an existing command, please give an explanation why.
That will help a lot when we merge your changes in.

Please take a look at the [Contribution Guidelines](CONTRIBUTING.md) before reporting a bug or providing a new feature.

Thanks, and happing bashing!


## Contributors

* [List of contributors][contribute]

[contribute]: https://github.com/Bash-it/bash-it/contributors
[pass password manager]: http://www.passwordstore.org/
