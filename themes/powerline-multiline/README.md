# Powerline Multiline Theme

A colorful multiline theme, where the first line shows information about your shell session (divided into two parts, left and right), and the second one is where the shell commands are introduced.

**IMPORTANT:** This theme requires that [a font with the Powerline symbols](https://github.com/powerline/fonts) needs to be used in your terminal emulator, otherwise the prompt won't be displayed correctly, i.e. some of the additional icons and characters will be missing. Please follow your operating system's instructions to install one of the fonts from the above link and select it in your terminal emulator.

## Provided Information

* Current path
* Current username and hostname
* Current time
* Current shell level
* Current dirstack level (`pushd` / `popd`)
* Current history number
* Current command number
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

By default, the username and hostname are shown on the right hand side, but you can change this behavior by setting the value of the following variable:

```bash
export POWERLINE_PROMPT_USER_INFO_MODE="sudo"
```

For now, the only supported value is `sudo`, which hides the username and hostname, and shows an indicator when `sudo` has the credentials cached. Other values have no effect at this time.

### Clock Format

By default, the current time is shown on the right hand side, you can change the format using the following variable:

```bash
export THEME_CLOCK_FORMAT="%H:%M:%S"
```

The time/date is printed by the `date` command, so refer to its man page to change the format.

### Soft Separators

Adjacent segments having the same background color will use a less-pronouced (i.e. soft) separator between them.

### Segment Order

The contents of both prompt sides can be "reordered", all the "segments" (every piece of information) can take any place. The currently available segments are:

* `aws_profile` - Show the current value of the `AWS_PROFILE` environment variable
* `battery` - Battery information (you'll need to enable the `battery` plugin)
* `clock` - Current time in `HH:MM:SS` format
* `cwd` - Current working directory including full folder hierarchy (c.f. `wd`)
* `hostname` - Host name of machine
* `in_vim` - Show identifier if running in `:terminal` from vim
* `k8s_context` - Show current kubernetes context
* `last_status` - Exit status of last run command
* `python_venv` - Python virtual environment information (`virtualenv`, `venv`
  and `conda` supported)
* `ruby` - Current ruby version if using `rvm`
* `node` - Current node version (only `nvm` is supported)
* `scm` - Version control information, `git` 
* `terraform` - Current terraform workspace
* `user_info` - Current user
* `wd` - Working directory, like `cwd` but doesn't show the full folder
  hierarchy, only the directory you're currently in.
* `shlvl` - Show the current shell level (based on `SHLVL` environment variable), but only if you are not in root shell
* `dirstack` - Show the current dirstack level (based on `DIRSTACK` environment variable), but only if the stack is not empty
* `history_number` - Show current history number
* `command_number` - Show current command number

Two variables can be defined to set the order of the prompt segments:

```bash
export POWERLINE_LEFT_PROMPT="scm python_venv ruby cwd"
export POWERLINE_RIGHT_PROMPT="in_vim clock battery user_info"
```

The example values above are the current default values, but if you want to remove anything from the prompt, simply remove the "string" that represents the segment from the corresponding variable.

### Padding

To get the length of the left and right segments right, a _padding_ value is used.
In most cases, the default value (_2_) works fine, but on some operating systems, this needs to be adjusted.
One example is _macOS High Sierra_, where the default padding causes the right segment to extend to the next line.
On macOS High Sierra, the padding value needs to be changed to _3_ to make the theme look right.
This can be done by setting the `POWERLINE_PADDING` variable before Bash-it is loaded, e.g. in your `~/.bash_profile` or `~/.bashrc` file:

```bash
export POWERLINE_PADDING=3
```

### Compact Settings

You can configure various aspects of the prompt to use less whitespace. Supported variables are:

| Variable                             | Description
|--------------------------------------|------------
|POWERLINE_COMPACT_BEFORE_SEPARATOR    | Removes the leading space before each separator
|POWERLINE_COMPACT_AFTER_SEPARATOR     | Removes the trailing space after each separator
|POWERLINE_COMPACT_BEFOR_FIRST_SEGMENT | Removes the leading space on the first segment
|POWERLINE_COMPACT_AFTER_LAST_SEGMENT  | Removes the trailing space on the last segment
|POWERLINE_COMPACT_PROMPT              | Removes the space after the prompt character
|POWERLINE_COMPACT                     | Enable all Compact settings (you can still override individual settings)

The default value for all settings is `0` (disabled). Use `1` to enable.

**Multiline Mode Right Prompt**

For the purposes of the `Compact` settings, the segments within the **Right Prompt** are considered to run "right-to-left", i.e.:

* The **right-most** segment is considered to be the `"first"` segment, while the **left-most** segment is considered to be the `"last"`
* The space to the **right** of the separator character is considered to be `"before"`, while the space to the **left** is considered to be `"after"`
