# Powerline Theme

A colorful theme, where shows a lot information about your shell session.

## Provided Information

* Current path
* Current username and hostname
* Current time
* An indicator when connected by SSH
* An indicator when `sudo` has the credentials cached (see the `sudo` manpage for more info about this)
* An indicator when the current shell is inside the Vim editor
* Battery charging status (depends on the [../../plugins/available/battery.plugin.bash](battery plugin))
* SCM Repository status (e.g. Git, SVN)
* The current Python environment (Virtualenv, venv, and Conda are supported) in use
* The current Ruby environment (rvm and rbenv are supported) in use
* Last command exit code (only shown when the exit code is greater than 0)

## Configuration

This theme is pretty configurable, all the configuration is done by setting environment variables.

### User Information

By default, the username and hostname are shown, but you can change this behavior by setting the value of the following variable:

    POWERLINE_PROMPT_USER_INFO_MODE="sudo"

For now, the only supported value is `sudo`, which hides the username and hostname, and shows an indicator when `sudo` has the credentials cached. Other values have no effect at this time.

### Clock Format

You can change the format using the following variable:

    THEME_CLOCK_FORMAT="%H:%M:%S"

The time/date is printed by the `date` command, so refer to its man page to change the format.

### Segment Order

The contents of the prompt can be "reordered", all the "segments" (every piece of information) can take any place. The currently available segments are:

* `battery` - Battery information (you'll need to enable the `battery` plugin)
* `clock` - Current time in `HH:MM:SS` format
* `cwd` - Current working directory including full folder hierarchy (c.f. `wd`)
* `hostname` - Host name of machine
* `in_vim` - Show identifier if running in `:terminal` from vim
* `last_status` - Exit status of last run command
* `python_venv` - Python virtual environment information (`virtualenv`, `venv`
  and `conda` supported)
* `ruby` - Current ruby version if using `rvm`
* `scm` - Version control information, `git` 
* `user_info` - Current user
* `wd` - Working directory, like `cwd` but doesn't show the full folder
  hierarchy, only the directory you're currently in.

A variable can be defined to set the order of the prompt segments:

    POWERLINE_PROMPT="user_info scm python_venv ruby cwd"

The example values above are the current default values, but if you want to remove anything from the prompt, simply remove the "string" that represents the segment from the variable.
