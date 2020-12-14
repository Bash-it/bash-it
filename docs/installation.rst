.. _installation:

Installation
------------


#. Check out a clone of this repo to a location of your choice, such as
   ``git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it``
#. Run ``~/.bash_it/install.sh`` (it automatically backs up your ``~/.bash_profile`` or ``~/.bashrc``\ , depending on your OS)
#. Edit your modified config (\ ``~/.bash_profile`` or ``~/.bashrc``\ ) file in order to customize Bash-it.
#. Check out available aliases, completions, and plugins and enable the ones you want to use (see the next section for more details).

Install Options
^^^^^^^^^^^^^^^

The install script can take the following options:


* ``--interactive``\ : Asks the user which aliases, completions and plugins to enable.
* ``--silent``\ : Ask nothing and install using default settings.
* ``--no-modify-config``\ : Do not modify the existing config file (\ ``~/.bash_profile`` or ``~/.bashrc``\ ).
* ``--append-to-config``\ : Back up existing config file and append bash-it templates at the end.

When run without the ``--interactive`` switch, Bash-it only enables a sane default set of functionality to keep your shell clean and to avoid issues with missing dependencies.
Feel free to enable the tools you want to use after the installation.

When you run without the ``--no-modify-config`` switch, the Bash-it installer automatically modifies/replaces your existing config file.
Use the ``--no-modify-config`` switch to avoid unwanted modifications, e.g. if your Bash config file already contains the code that loads Bash-it.

**NOTE**\ : Keep in mind how Bash loads its configuration files,
``.bash_profile`` for login shells (and in macOS in terminal emulators like `Terminal.app <http://www.apple.com/osx/apps/>`_ or
`iTerm2 <https://www.iterm2.com/>`_\ ) and ``.bashrc`` for interactive shells (default mode in most of the GNU/Linux terminal emulators),
to ensure that Bash-it is loaded correctly.
A good "practice" is sourcing ``.bashrc`` into ``.bash_profile`` to keep things working in all the scenarios.
To achieve this, you can add this snippet in your ``.bash_profile``\ :

.. code-block::

   if [ -f ~/.bashrc ]; then
     . ~/.bashrc
   fi

Refer to the official `Bash documentation <https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files>`_ to get more info.

Install using Docker
^^^^^^^^^^^^^^^^^^^^

You can try Bash-it in an isolated environment without changing any local files via a `Docker <https://www.docker.com/>`_ Container.
(Bash Shell v4.4 with Bash-it, `bats <https://github.com/sstephenson/bats>`_\ ,and bash-completion based on `Alpine Linux <https://alpinelinux.org/>`_\ ).

``docker pull ellerbrock/bash-it``

Have a look at our `bash-it-docker repository <https://github.com/Bash-it/bash-it-docker>`_ for further information.

Updating
^^^^^^^^

See :ref:`update command <update>`.
