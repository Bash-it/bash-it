# Contribution Guidelines

When contributing a new feature, a bug fix, a new theme, or any other change to Bash-it, please consider the following guidelines. Most of this is common sense, but please try to stick to the conventions listed here.

## Issues

* When opening a new issue in the issue tracker, please include information about which _Operating System_ you're using, and which version of _Bash_.
* In many cases, it also makes sense to show which Bash-it plugins you are using. This information can be obtained using `bash-it show plugins`.
* If the issue happens while loading Bash-it, please also include your `~/.bash_profile` or `~/.bashrc` file, as well as the install location of Bash-it (default should be `~/.bash_it`).
* When reporting a bug or requesting a new feature, consider providing a Pull Request that fixes the issue or can be used as a starting point for the new feature. Don't be afraid, most things aren't that complex...

## Pull Requests

* Fork the Bash-it repo, create a new feature branch from _master_ and apply your changes there. Create a _Pull Request_ from your feature branch against Bash-it's _master_ branch.
* Limit each Pull Request to one feature. Don't bundle multiple features/changes (e.g. a new _Theme_ and a fix to an existing plugin) into a single Pull Request - create one PR for the theme, and a separate PR for the fix.
* For complex changes, try to _squash_ your changes into a single commit. Don't create a PR consisting of 20 commits that show your work in progress. Before you create the PR, _squash_ your changes into a single commit.

## Code Style

* Try to stick to the existing code style. Please don't reformat or change the syntax of existing code simply because you don't like that style.
* Indentation is using spaces, not tabs. Most of the code is indented with 2 spaces, some with 4 spaces. Please try to stick to 2 spaces. If you're using an editor that supports [EditorConfig](http://EditorConfig.org), the editor should automatically use the settings defined in Bash-it's [.editorconfig file](.editorconfig).
* When creating new functions, please use a dash ("-") to separate the words of the function's name, e.g. `my-new-function`. Don't use underscores, e.g. `my_new_function`.
* Internal functions that aren't to be used by the end user should start with an underscore, e.g. `_my-new-internal-function`.
* Use the provided meta functions to document your code, e.g. `about-plugin`, `about`, `group`, `param`, `example`. This will make it easier for other people to use your new functionality. Take a look at the existing code for an example (e.g. [the base plugin](plugins/available/base.plugin.bash)).
* When adding files, please use the existing file naming conventions, e.g. plugin files need to end in `.plugin.bash`. This is important for the installation functionality.

## Features

* When adding new completions or plugins, please don't simply copy existing tools into the Bash-it codebase, try to load/integrate the tools instead. An example is using `nvm`: Instead of copying the existing `nvm` script into Bash-it, the `nvm.plugin.bash` file tries to load an existing installation of `nvm`. This means an additional step for the user (installing `nvm` from its own repo, or through a package manager), but it will also ensure that `nvm` can be upgraded in an easy way.

## Themes

* When adding a new theme, please include a screenshot and a short description about what makes this theme unique in the Pull Request.
* Ideally, each theme's folder should contain a `README.md` file describing the theme and its configuration options.
