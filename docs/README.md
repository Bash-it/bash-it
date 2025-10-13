![logo](https://github.com/Bash-it/media/raw/master/media/Bash-it.png)

![Build Status](../../../workflows/CI/badge.svg?event=push)
![Docs Status](https://readthedocs.org/projects/bash-it/badge/)
![License](https://img.shields.io/github/license/Bash-it/bash-it)
![shell](https://img.shields.io/badge/Shell-Bash-blue)

**Bash-it** is a collection of community Bash commands and scripts for Bash.
(And a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) :smiley:)
97% of the code is compatible with bash 3.2+ but we are geared also toward power users,
and one or two of the more complex plugins may need bash 5 features to run. If you
happen to be "stuck" on an older version of bash, we have code in place to prevent you
from running those modules and getting errors. It's a short list though, and none of the core code.

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

Bash-it provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work.
If you're using the _Bourne Again Shell_ (Bash) regularly and have been looking for an easy way on how to keep all of these nice little scripts and aliases under control, then Bash-it is for you!
Stop polluting your `~/bin` directory and your `.bashrc` file, fork/clone Bash-it and start hacking away.

- [Main Page](https://bash-it.readthedocs.io/en/latest)
- [Contributing](#contributing)
- [Installation](#installation)
  - [Install Options](https://bash-it.readthedocs.io/en/latest/installation/#install-options)
  - [via Docker](https://bash-it.readthedocs.io/en/latest/installation/#install-using-docker)
  - [Updating](https://bash-it.readthedocs.io/en/latest/installation/#updating)
- [Help](https://bash-it.readthedocs.io/en/latest/misc/#help-screens)
- [Diagnostics](#diagnostics)
- [Search](https://bash-it.readthedocs.io/en/latest/commands/search)
  - [Syntax](https://bash-it.readthedocs.io/en/latest/commands/search/#syntax)
  - [Searching with Negations](
  https://bash-it.readthedocs.io/en/latest/commands/search/#searching-with-negations)
  - [Using Search to Enable or Disable Components](https://bash-it.readthedocs.io/en/latest/commands/search/#using-search-to-enable-or-disable-components)
  - [Disabling ASCII Color](https://bash-it.readthedocs.io/en/latest/commands/search/#disabling-ascii-color)
- [Custom scripts, aliases, themes, and functions](
  https://bash-it.readthedocs.io/en/latest/custom)
- [Themes](https://bash-it.readthedocs.io/en/latest/themes)
- [Uninstalling](https://bash-it.readthedocs.io/en/latest/uninstalling)
- [Misc](https://bash-it.readthedocs.io/en/latest/misc)
- [Help Out](https://bash-it.readthedocs.io/en/latest/#help-out)
- [Contributors](#contributors)

## Installation

1) Check out a clone of this repo to a location of your choice, such as
   ``git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it``
2) Run ``~/.bash_it/install.sh``

That's it! :smiley:

You can check out more components of Bash-it, and customize it to your desire.
For more information, see detailed instructions [here](https://bash-it.readthedocs.io/en/latest/installation/).

### custom configuration file location

By default the instller modifies/creates the actual ``~/.bashrc`` is updated.
If this is undesirable, you can create another file, by run the installer:
```bash
BASH_IT_CONFIG_FILE=path/to/my/custom/location.bash ~/.bash_it/install.sh
```

## Diagnostics

If you're experiencing issues with Bash-it or need to report a bug, use the built-in diagnostics tool:

```bash
bash-it doctor
```

This command provides a comprehensive summary including:
- Environment information (OS, Bash version)
- Bash-it version and update status
- Configuration file locations and how Bash-it is loaded
- List of enabled components (aliases, plugins, completions)

**When reporting bugs**, please include the full output of `bash-it doctor` in your issue report.

The doctor command can also help you update Bash-it - if you're behind the latest version and it's safe to update, you'll be prompted to merge the latest changes.

## Contributing

Please take a look at the [Contribution Guidelines](https://bash-it.readthedocs.io/en/latest/contributing) before reporting a bug or providing a new feature.

**When reporting bugs**, always run `bash-it doctor` and include its output in your issue report to help maintainers diagnose the problem quickly.

The [Development Guidelines](https://bash-it.readthedocs.io/en/latest/development) have more information on some of the internal workings of Bash-it,
please feel free to read through this page if you're interested in how Bash-it loads its components.

## Contributors

[List of contributors](https://github.com/Bash-it/bash-it/contributors)

## License

Bash-it is licensed under the [MIT License](https://github.com/Bash-it/bash-it/blob/master/LICENSE).
