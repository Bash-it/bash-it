.. _barbuk:

BarbUk theme
============

A minimal theme with a clean git prompt

Provided Information
--------------------

* Current git remote tool logo (support: github, gitlab, bitbucket)
* Current path (red when user is root)
* Current git info
* Last command exit code (only shown when the exit code is greater than 0)
* user@hostname for ssh connection

Default configuration
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   BARBUK_PROMPT="git-uptream-remote-logo ssh path scm python_venv ruby node terraform cloud duration exit"

You can override BARBUK_PROMPT to display only the desired information.

available block:

* git-uptream-remote-logo
* ssh
* path
* scm
* python_venv
* ruby
* node
* terraform
* cloud
* duration
* exit

Fonts and glyphs
----------------

A font with SCM glyphs is required to display the default tool/host logos.
You can use a font from https://www.nerdfonts.com/ or patch your own font with the tool
provided by https://github.com/ryanoasis/nerd-fonts.

You can also override the default variables if you want to use different glyphs or standard ASCII characters.

Default theme glyphs
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   BARBUK_GITLAB_CHAR='  '
   BARBUK_BITBUCKET_CHAR='  '
   BARBUK_GITHUB_CHAR='  '
   BARBUK_GIT_DEFAULT_CHAR='  '
   BARBUK_GIT_BRANCH_ICON=''
   BARBUK_CURRENT_USER_PREFFIX='  '
   BARBUK_HG_CHAR='☿ '
   BARBUK_SVN_CHAR='⑆ '
   BARBUK_EXIT_CODE_ICON=' '
   BARBUK_PYTHON_VENV_CHAR=' '
   BARBUK_COMMAND_DURATION_ICON='  '
   BARBUK_RUBY_CHAR=' '
   BARBUK_NODE_CHAR=' '
   BARBUK_TERRAFORM_CHAR="❲t❳ "
   BARBUK_AWS_PROFILE_CHAR=" aws "
   BARBUK_SCALEWAY_PROFILE_CHAR=" scw "
   BARBUK_GCLOUD_CHAR=" gcp "

Customize glyphs
^^^^^^^^^^^^^^^^

Define your custom glyphs before sourcing bash-it:

.. code-block:: bash

   export BARBUK_GITHUB_CHAR='•'
   source "$BASH_IT"/bash_it.sh

SSH prompt
----------

Usage
^^^^^

When using a ssh session, the theme will display ``user@hostname``.
You can disable this information with ``BARBUK_SSH_INFO``.

The hostname is displayed in the FQDN format by default. You
can use the short hostname format with ``BARBUK_HOST_INFO``.

.. code-block:: bash

   # short or long
   export BARBUK_HOST_INFO=short
   # true or false
   export BARBUK_SSH_INFO=false
   source "$BASH_IT"/bash_it.sh

Keep theme with sudoer
^^^^^^^^^^^^^^^^^^^^^^

If you want the theme to persist using ``sudo -s`` in a ssh session, you need to configure sudo to keep the ``HOME`` and ``SSH_CONNECTION`` environment variables.

``HOME`` contains the path to the home directory of the current user. Keeping it will allow to use your user dotfiles when elevating privileges.

Keeping ``SSH_CONNECTION`` env is necessary for ssh detection in the theme.

Please refer to the following documentation for more information:


* `sudo manual <https://www.sudo.ws/man/1.8.13/sudoers.man.html>`_ for ``env_keep`` configuration
* `openssh manual <https://linux.die.net/man/1/ssh>`_ for information about ``SSH_CONNECTION`` environment

.. code-block:: bash

   cat << EOF > /etc/sudoers.d/keepenv
   Defaults env_keep += HOME
   Defaults env_keep += SSH_CONNECTION
   EOF
   chmod 400 /etc/sudoers.d/keepenv

Command duration
----------------

See :ref:`Command duration <command_duration>`.

Examples
--------

Clean
^^^^^

.. code-block:: bash

    ~ ❯

Git
^^^

.. code-block:: bash

      ~/.dotfiles on  master ⤏  origin ↑2 •7 ✗ ❯

Ssh
^^^

.. code-block:: bash

   user@hostname in  ~/bash-it on  master ✓ ❯

Python venv
^^^^^^^^^^^

.. code-block:: bash

     flask ~/test on  master ✓ ❯

Command duration
^^^^^^^^^^^^^^^^

.. code-block:: bash

   # sleep 3s
   user@hostname in  ~/bash-it on  master ✓  3.2s ❯
