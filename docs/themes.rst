.. _themes:

Themes
------

There are over 50+ Bash-it themes to pick from in ``$BASH_IT/themes``.
The default theme is ``bobby``.
Set ``BASH_IT_THEME`` to the theme name you want, or if you've developed your own custom theme outside of ``$BASH_IT/themes``\ ,
point the ``BASH_IT_THEME`` variable directly to the theme file.
To disable theming completely, leave the variable empty.

Examples:

.. code-block:: bash

   # Use the "powerline-multiline" theme
   export BASH_IT_THEME="powerline-multiline"

   # Use a theme outside of the Bash-it folder
   export BASH_IT_THEME="/home/foo/my_theme/my_theme.theme.bash"

   # Disable theming
   export BASH_IT_THEME=""

You can easily preview the themes in your own shell using ``bash-it preview``.

If you've created your own custom prompts, we'd love it if you shared them with everyone else! Just submit a Pull Request.
You can see theme screenshots on `wiki/Themes <https://github.com/Bash-it/bash-it/wiki/Themes>`_.

**NOTE**\ : Bash-it and some themes use UTF-8 characters, so to avoid strange behavior in your terminal, set your locale to ``LC_ALL=en_US.UTF-8`` or the equivalent to your language if it isn't American English.

List of Themes
^^^^^^^^^^^^^^

See :ref:`here <list_of_themes>`.

Theme Switches & Variables
^^^^^^^^^^^^^^^^^^^^^^^^^^

.. _command_duration:

Command duration
================

Prints last command duration

Usage
#####

Command duration can be enabled by exporting ``BASH_IT_COMMAND_DURATION``:

.. code-block:: bash

   export BASH_IT_COMMAND_DURATION=true

The default configuration display last command duration for command lasting one second or more.
You can customize the minimum time in seconds before command duration is displayed in your ``.bashrc``:

.. code-block:: bash

   export COMMAND_DURATION_MIN_SECONDS=5

Clock Related
=============

function: ``clock_char``
########################

Prints a character indicating clock.


* ``THEME_SHOW_CLOCK_CHAR`` : **true**\ /false

* ``THEME_CLOCK_CHAR`` : "\ **⌚**\ "

* ``THEME_CLOCK_CHAR_COLOR`` : "\ **$normal**\ "

function: ``clock_prompt``
##########################

Prints the clock prompt (date, time).


* ``THEME_SHOW_CLOCK`` : **true**\ /false

* ``THEME_CLOCK_COLOR`` :  "\ **$normal**\ "

* ``THEME_CLOCK_FORMAT`` : "\ **%H:%M:%S**\ "

Contributing a new theme
^^^^^^^^^^^^^^^^^^^^^^^^

See the :ref:`instructions <contributing_theme>`.
