.. _vcs_user:

Prompt Version Control Information
==================================

Bash-it provides prompt :ref:`themes` with the ability to check and display version control information for the current directory.
The information is retrieved for each directory and can slow down the navigation of projects with a large number of files and folders.
Turn version control checking off to prevent slow directory navigation within large projects.

Controlling Flags
^^^^^^^^^^^^^^^^^

Bash-it provides a flag (\ ``SCM_CHECK``\ ) within the ``~/.bash_profile`` file that turns off/on version control information checking and display within all themes.
Version control checking is on by default unless explicitly turned off.

Set ``SCM_CHECK`` to 'false' to **turn off** version control checks for all themes:


* ``export SCM_CHECK=false``

Set ``SCM_CHECK`` to 'true' (the default value) to **turn on** version control checks for all themes:


* ``export SCM_CHECK=true``

**NOTE:**
It is possible for themes to ignore the ``SCM_CHECK`` flag and query specific version control information directly.
For example, themes that use functions like ``git_prompt_vars`` skip the ``SCM_CHECK`` flag to retrieve and display git prompt information.
If you turned version control checking off and you still see version control information within your prompt, then functions like ``git_prompt_vars`` are most likely the reason why.

.. _git_prompt:

Git prompt
^^^^^^^^^^

Bash-it has some nice features related to Git, continue reading to know more about these features.

Repository info in the prompt
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bash-it can show some information about Git repositories in the shell prompt: the current branch, tag or commit you are at, how many commits the local branch is ahead or behind from the remote branch, and if you have changes stashed.

Additionally, you can view the status of your working copy and get the count of *staged*\ , *unstaged* and *untracked* files.
This feature is controlled through the flag ``SCM_GIT_SHOW_DETAILS`` as follows:

Set ``SCM_GIT_SHOW_DETAILS`` to 'true' (the default value) to **show** the working copy details in your prompt:


* ``export SCM_GIT_SHOW_DETAILS=true``

Set ``SCM_GIT_SHOW_DETAILS`` to 'false' to **don't show** it:


* ``export SCM_GIT_SHOW_DETAILS=false``

**NOTE:** If using ``SCM_GIT_SHOW_MINIMAL_INFO=true``\ , then the value of ``SCM_GIT_SHOW_DETAILS`` is ignored.

Remotes and remote branches
^^^^^^^^^^^^^^^^^^^^^^^^^^^

In some git workflows, you must work with various remotes, for this reason, Bash-it can provide some useful information about your remotes and your remote branches, for example, the remote on you are working, or if your local branch is tracking a remote branch.

You can control this feature with the flag ``SCM_GIT_SHOW_REMOTE_INFO`` as follows:

Set ``SCM_GIT_SHOW_REMOTE_INFO`` to 'auto' (the default value) to activate it only when more than one remote is configured in the current repo:


* ``export SCM_GIT_SHOW_REMOTE_INFO=auto``

Set ``SCM_GIT_SHOW_REMOTE_INFO`` to 'true' to always activate the feature:


* ``export SCM_GIT_SHOW_REMOTE_INFO=true``

Set ``SCM_GIT_SHOW_REMOTE_INFO`` to 'false' to **disable the feature**\ :


* ``export SCM_GIT_SHOW_REMOTE_INFO=false``

**NOTE:** If using ``SCM_GIT_SHOW_MINIMAL_INFO=true``\ , then the value of ``SCM_GIT_SHOW_REMOTE_INFO`` is ignored.

Untracked files
^^^^^^^^^^^^^^^

By default, the ``git status`` command shows information about *untracked* files.
This behavior can be controlled through command-line flags or git configuration files.
For big repositories, ignoring *untracked* files can make git faster.
Bash-it uses ``git status`` to gather the repo information it shows in the prompt, so in some circumstances, it can be useful to instruct Bash-it to ignore these files.
You can control this behavior with the flag ``SCM_GIT_IGNORE_UNTRACKED``\ :

Set ``SCM_GIT_IGNORE_UNTRACKED`` to 'false' (the default value) to get information about *untracked* files:


* ``export SCM_GIT_IGNORE_UNTRACKED=false``

Set ``SCM_GIT_IGNORE_UNTRACKED`` to 'true' to **ignore** *untracked* files:


* ``export SCM_GIT_IGNORE_UNTRACKED=true``

Also, with this flag to false, Bash-it will not show the repository as dirty when the repo has *untracked* files, and will not display the count of *untracked* files.

**NOTE:** If you set in git configuration file the option to ignore *untracked* files, this flag has no effect, and Bash-it will ignore *untracked* files always.

Stash item count
^^^^^^^^^^^^^^^^

When ``SCM_GIT_SHOW_DETAILS`` is enabled, you can get the count of *stashed* items. This feature can be useful when a user has a lot of stash items.
This feature is controlled through the flag ``SCM_GIT_SHOW_STASH_INFO`` as follows:

Set ``SCM_GIT_SHOW_STASH_INFO`` to 'true' (the default value) to **show** the count of stashed items:


* ``export SCM_GIT_SHOW_STASH_INFO=true``

Set ``SCM_GIT_SHOW_STASH_INFO`` to 'false' to **don't show** it:


* ``export SCM_GIT_SHOW_STASH_INFO=false``

Ahead/Behind Count
^^^^^^^^^^^^^^^^^^

When displaying information regarding whether or not the local branch is ahead or behind its remote counterpart, you can opt to display the number of commits ahead/behind.
This is useful if you only care whether or not you are ahead or behind and do not care how far ahead/behind you are.

Set ``SCM_GIT_SHOW_COMMIT_COUNT`` to 'true' (the default value) to **show** the count of commits ahead/behind:


* ``export SCM_GIT_SHOW_COMMIT_COUNT=true``

Set ``SCM_GIT_SHOW_COMMIT_COUNT`` to 'false' to **don't show** it:


* ``export SCM_GIT_SHOW_COMMIT_COUNT=false``

Git user
^^^^^^^^

In some environments, it is useful to know the value of the current git user, which is used to mark all new commits.
For example, any organization that uses the practice of pair programming will typically author each commit with `combined names of the two authors <https://github.com/pivotal/git_scripts>`_.
When another pair uses the same pairing station, the authors are changed at the beginning of the session.

To get up and running with this technique, run ``gem install pivotal_git_scripts``\ , and then edit your ``~/.pairs`` file, according to the specification on the `gem's homepage <https://github.com/pivotal/git_scripts>`_.
After that, you should be able to run ``git pair kg as`` to set the author to, eg. "Konstantin Gredeskoul and Alex Saxby", assuming they've been added to the ``~/.pairs`` file.
Please see gem's documentation for more information.

To enable the display of the current pair in the prompt, you must set ``SCM_GIT_SHOW_CURRENT_USER`` to ``true``.
Once set, the ``SCM_CURRENT_USER`` variable will be automatically populated with the initials of the git author(s).
It will also be included in the default git prompt.
Even if you do not have ``git pair`` installed, as long as your ``user.name`` is set, your initials will be computed from your name and shown in the prompt.

You can control the prefix and the suffix of this component using the two variables:


* ``export SCM_THEME_CURRENT_USER_PREFFIX=' ☺︎ '``

And


* ``export SCM_THEME_CURRENT_USER_SUFFIX=' ☺︎ '``

**NOTE:** If using ``SCM_GIT_SHOW_MINIMAL_INFO=true``\ , then the value of ``SCM_GIT_SHOW_CURRENT_USER`` is ignored.

Git show minimal status info
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To speed up the prompt while still getting minimal git status information displayed such as the value of ``HEAD`` and whether there are any dirty objects, you can set:

.. code-block::

   export SCM_GIT_SHOW_MINIMAL_INFO=true

Ignore repo status
^^^^^^^^^^^^^^^^^^

When working in repos with a large codebase, Bash-it can slow down your prompt when checking the repo status.
To avoid it, there is an option you can set via Git config to disable checking repo status in Bash-it.

To disable checking the status in the current repo:

.. code-block::

   $ git config --add bash-it.hide-status 1

But if you would like to disable it globally, and stop checking the status for all of your repos:

.. code-block::

   $ git config --global --add bash-it.hide-status 1

Setting this flag globally has the same effect as ``SCM_CHECK=true``\ , but only for Git repos.

Speed up git status calculations
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As an alternative to ignoring repo status entirely, you can try out the ``gitstatus`` plugin.
This plugin speeds up all ``git status`` calculations by up to 10x times!

**NOTE**\ : You will need to clone ``gitstatus`` repo from `here <https://github.com/romkatv/gitstatus>`_.
