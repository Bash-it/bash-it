# Powerline Multiline Theme

Colorfull multiline theme, the first line shows information about your shell session (divided into two parts, left and right), the second one is where the shell commands are introduced.

## Information provided

* Current path
* Current username and hostname
* An indicator when connected by SSH
* An indicator when sudo has the credentials cached (see the sudo manpage for more info about this)
* An indicator when the current shell is inside the Vim editor
* Battery charging status (depends on the battery plugin)
* Repository status
* The current Python enviroment (Virtualenv, venv, and Conda are supported) in use
* The current Ruby enviroment (RVM) in use
* Last command exit code (only shown when the exit code is greater than 0)

## Configuration

This theme is pretty configurable, all the configuration is done by setting environment variables.

### User information

By default, the username and hostname are shown at the right side, but you can change this behavior setting the value of the following variable:

    THEME_PROMPT_USER_INFO_MODE

for now, the only supported value is `sudo`, that hides the username and hostname, and shows an indicator when the sudo has the credentials cached. Any other value has no effect.

### Clock format

By default, the current time is shown at the right side, you can change the format with the variable:

    THEME_PROMPT_CLOCK_FORMAT="%H:%M:%S"

the date is printed by the `date` command, so refer to its man page to change the format.

### Segment order

Both prompt sides can be "reordered", all the "segments" (every piece of information) can take any place, the only restriction (for now), is that some segments only can be placed at left, and others only at right.

Current available left "segments":

* scm
* virtualenv
* rvm
* cwd

Current available right "segments":

* in_vim
* clock
* battery
* user_info

Two variables can be defined to set the order of the prompt segments:

    THEME_LEFT_SEGMENTS="scm virtualenv rvm cwd"
    THEME_RIGHT_SEGMENTS="in_vim clock battery user_info"

if you want to remove something else from the prompt, simply remove the "string" that represents the segment from the corresponding variable.


