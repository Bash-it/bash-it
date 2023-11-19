.. _powerline_base:

Base Powerline Theme Information
================================

This page explains base powerline theme information, shared between
all powerline themes.

**IMPORTANT:** This theme requires that `a font with the Powerline symbols <https://github.com/powerline/fonts>`_ needs to be used in your terminal emulator, otherwise the prompt won't be displayed correctly, i.e. some of the additional icons and characters will be missing. Please follow your operating system's instructions to install one of the fonts from the above link and select it in your terminal emulator.

**NOTICE:** The default behavior of this theme assumes that you have sudo privileges on your workstation. If that is not the case (e.g. if you are running on a corporate network where ``sudo`` usage is tracked), you can set the flag 'export THEME_CHECK_SUDO=false' in your ``~/.bashrc`` or ``~/.bash_profile`` to disable the Powerline theme's ``sudo`` check. This will apply to all ``powerline*`` themes.

Provided Information
--------------------


* Current path
* Current username and hostname
* Current time
* Current shell level
* Current dirstack level (\ ``pushd`` / ``popd``\ )
* Current history number
* Current command number
* An indicator when connected by SSH
* An indicator when ``sudo`` has the credentials cached (see the ``sudo`` manpage for more info about this)
* An indicator when the current shell is inside the Vim editor
* Battery charging status (depends on the battery plugin)
* SCM Repository status (e.g. Git, SVN)
* The current Kubernetes environment
* The current Python environment (Virtualenv, venv, and Conda are supported) in use
* The current Ruby environment (rvm and rbenv are supported) in use
* Last command exit code (only shown when the exit code is greater than 0)

Configuration
-------------

This theme is pretty configurable, all the configuration is done by setting environment variables.

User Information
^^^^^^^^^^^^^^^^

By default, the username and hostname are shown, but you can change this behavior by setting the value of the following variable:

.. code-block:: bash

   export POWERLINE_PROMPT_USER_INFO_MODE="sudo"


For now, the only supported value is ``sudo``\ , which hides the username and hostname, and shows an indicator when ``sudo`` has the credentials cached. Other values have no effect at this time.

Clock Format
^^^^^^^^^^^^

You can change the format using the following variable:

.. code-block:: bash

   export THEME_CLOCK_FORMAT="%H:%M:%S"


The time/date is printed by the ``date`` command, so refer to its man page to change the format.

Segment Order
^^^^^^^^^^^^^

The contents of the prompt can be "reordered", all the "segments" (every piece of information) can take any place. The currently available segments are:


* ``aws_profile`` - Show the current value of the ``AWS_PROFILE`` environment variable
* ``battery`` - Battery information (you'll need to enable the ``battery`` plugin)
* ``clock`` - Current time in ``HH:MM:SS`` format
* ``cwd`` - Current working directory including full folder hierarchy (c.f. ``wd``\ )
* ``duration`` - Duration of the last command. See :ref:`Command duration <command_duration>` for details.
* ``gcloud`` - Current gcloud active account
* ``hostname`` - Host name of machine
* ``in_toolbox`` - Show identifier if running inside a `toolbox <https://github.com/containers/toolbox>`_
* ``in_vim`` - Show identifier if running in ``:terminal`` from vim
* ``k8s_context`` - Show current kubernetes context
* ``k8s_namespace`` - Show current kubernetes namespace
* ``last_status`` - Exit status of last run command
* ``python_venv`` - Python virtual environment information (\ ``virtualenv``\ , ``venv``
  and ``conda`` supported)
* ``ruby`` - Current ruby version if using ``rvm``
* ``node`` - Current node version (``nvm`` is the default strategy; set ``NODE_VERSION_STRATEGY`` to ``node`` to use ``node --version``)
* ``scm`` - Version control information, ``git``
* ``terraform`` - Current terraform workspace
* ``user_info`` - Current user
* ``wd`` - Working directory, like ``cwd`` but doesn't show the full folder
  hierarchy, only the directory you're currently in.
* ``shlvl`` - Show the current shell level (based on ``SHLVL`` environment variable), but only if you are not in root shell
* ``dirstack`` - Show the current dirstack level (based on ``DIRSTACK`` environment variable), but only if the stack is not empty
* ``history_number`` - Show current history number
* ``command_number`` - Show current command number

A variable can be defined to set the order of the prompt segments:

.. code-block::

   POWERLINE_PROMPT="user_info scm python_venv ruby cwd"


The example values above are the current default values, but if you want to remove anything from the prompt, simply remove the "string" that represents the segment from the variable.

.. _powerline_compact_settings:

Compact Settings
^^^^^^^^^^^^^^^^

You can configure various aspects of the prompt to use less whitespace. Supported variables are:

.. list-table::
   :header-rows: 1

   * - Variable
     - Description
   * - POWERLINE_COMPACT_BEFORE_SEPARATOR
     - Removes the leading space before each separator
   * - POWERLINE_COMPACT_AFTER_SEPARATOR
     - Removes the trailing space after each separator
   * - POWERLINE_COMPACT_BEFOR_FIRST_SEGMENT
     - Removes the leading space on the first segment
   * - POWERLINE_COMPACT_AFTER_LAST_SEGMENT
     - Removes the trailing space on the last segment
   * - POWERLINE_COMPACT_PROMPT
     - Removes the space after the prompt character
   * - POWERLINE_COMPACT
     - Enable all Compact settings (you can still override individual settings)


The default value for all settings is ``0`` (disabled). Use ``1`` to enable.
