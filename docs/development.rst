.. _development:

Bash-it Development
===================

This page summarizes a couple of rules to keep in mind when developing features or making changes in Bash-it.

Testing
-------

Make sure to read the :ref:`testing docs<test>`.

Debugging and Logging
---------------------

General Logging
^^^^^^^^^^^^^^^

While developing feature or making changes in general, you can log error/warning/debug
using ``_log_error`` ``_log_warning`` and ``_log_debug``. This will help you solve problems quicker
and also propagate important notes to other users of Bash-it.
You can see the logs by using ``bash-it doctor`` command to reload and see the logs.
Alternatively, you can set ``BASH_IT_LOG_LEVEL`` to ``BASH_IT_LOG_LEVEL_ERROR``\ , ``BASH_IT_LOG_LEVEL_WARNING`` or ``BASH_IT_LOG_LEVEL_ALL``.

Log Prefix/Context
^^^^^^^^^^^^^^^^^^

You can define ``BASH_IT_LOG_PREFIX`` in your files in order to a have a constant prefix before your logs.
Note that we prefer to uses "tags" based logging, i.e ``plugins: git: DEBUG: Loading git plugin``.

Load Order
----------

General Load Order
^^^^^^^^^^^^^^^^^^

The main ``bash_it.sh`` script loads the frameworks individual components in the following order:




* ``vendor/github.com/erichs/composure/composure.sh``
* ``lib/log.bash``
* ``vendor/init.d/*.bash``
* Files in ``lib`` with the exception of ``appearance.bash`` - this means that ``log.bash`` is loaded again here (possible improvement?)
* Enabled ``aliases``
* Enabled ``plugins``
* Enabled ``completions``
* ``themes/colors.theme.bash``
* ``themes/base.theme.bash``
* ``lib/appearance.bash``\ , which loads the selected theme
* Custom ``aliases``
* Custom ``plugins``
* Custom ``completions``
* Additional custom files from either ``$BASH_IT/custom`` or ``$BASH_IT_CUSTOM``

This order is subject to change.

Individual Component Load Order
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For ``aliases``\ , ``plugins`` and ``completions``\ , the following rules are applied that influence the load order:


* There is a global ``enabled`` directory, which the enabled components are linked into. Enabled plugins are symlinked from ``$BASH_IT/plugins/available`` to ``$BASH_IT/enabled`` for example. All component types are linked into the same common ``$BASH_IT/enabled`` directory.
* Within the common ``enabled`` directories, the files are loaded in alphabetical order, which is based on the item's load priority (see next item).
* When enabling a component, a *load priority* is assigned to the file. The following default priorities are used:

  * Aliases: 150
  * Plugins: 250
  * Completions: 350

* When symlinking a component into the ``enabled`` directory, the load priority is used as a prefix for the linked name, separated with three dashes from the name of the component. The ``node.plugin.bash`` would be symlinked to ``250---node.plugin.bash`` for example.
*
  Each file can override the default load priority by specifying a new value. To do this, the file needs to include a comment in the following form. This example would cause the ``node.plugin.bash`` (if included in that file) to be linked to ``225---node.plugin.bash``\ :

  .. code-block:: bash

     # BASH_IT_LOAD_PRIORITY: 225

Having the order based on a numeric priority in a common directory allows for more flexibility. While in general, aliases are loaded first (since their default priority is 150), it's possible to load some aliases after the plugins, or some plugins after completions by setting the items' load priority. This is more flexible than a fixed type-based order or a strict alphabetical order based on name.

These items are subject to change. When making changes to the internal functionality, this page needs to be updated as well.

Working with vendored libs
--------------------------

Vendored libs are external libraries, meaning source code not maintained by Bash-it
developers.
They are ``git subtrees`` curated in the ``vendor/`` folder. To ease the work with git
vendored libs as subtrees we use the `git-vendor <https://github.com/Tyrben/git-vendor>`_ tool.
The `original repo <https://github.com/brettlangdon/git-vendor>`_ for git vendor is
unmaintained so for now we are recommending Tyrben's fork.

For more information on ``git vendor`` there are a short `usage description <https://github.com/Tyrben/git-vendor#usage>`_ 
in the repositories ``README`` file and a website for the original repository has a `manual page <https://brettlangdon.github.io/git-vendor/>`_ which is also included in both
repositories.

To support a flexible loading of external libraries, a file unique to the vendored
library must be placed in ``vendor/init.d/`` with the ``.bash`` extension.

Rebasing a feature branch with an added/updated vendored library
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If your feature branch with a newly added/updated vendored lib has fallen behind master
you might need to rebase it before creating a PR. However rebasing with dangling
subtree commits can cause problems.
The following rebase strategy will pause the rebase at the point where you added a 
subtree and let you add it again before continuing the rebasing.

::

    [feature/branch] $ git rebase --rebase-merges --strategy subtree master
    fatal: refusing to merge unrelated histories
    Could not apply 0d6a56b... Add-preexec-from-https-github-com-rcaloras-bash-preexec-0-4-1- # Add "preexec" from "https://github.com/rcaloras/bash-preexec@0.4.1"
    [feature/branch] $ git vendor add preexec https://github.com/rcaloras/bash-preexec 0.4.1
    ...
    [feature/branch] $ git rebase --continue

If rebasing makes you a little uneasy (as it probably should). You can always test in
another branch.

::

    [feater/branch] $ git checkout -b feature/branch-test-rebase
    [feater/branch-test-rebase] $ git rebase --rebase-merges --strategy subtree master
    ...

Afterwards you can make sure the rebase was successful by running ``git vendor list``
to see if your library is still recognized as a vendored lib

::

    [feature/branch] $ git vendor list
    preexec@0.4.1:
        name:   preexec
        dir:    vendor/github.com/rcaloras/bash-preexec
        repo:   https://github.com/rcaloras/bash-preexec
        ref:    0.4.1
        commit: 8fe585c5cf377a3830b895fe26e694b020d8db1a
    [feature/branch] $


Plugin Disable Callbacks
------------------------

Plugins can define a function that will be called when the plugin is being disabled.
The callback name should be ``{PLUGIN_NAME}_on_disable``\ , you can see ``gitstatus`` for usage example.

Library Finalization Callback
-----------------------------

Specifically for Bash-it library code, e.g. in the `lib` subdirectory, a hook is available to run some code at the very end of the main loader script after all other code has been loaded. For example, `lib/theme` uses `_bash_it_library_finalize_hook+=('_bash_it_appearance_scm_init')` to add a function to be called after all plugins have been loaded.

Using the pre-commit hook
-------------------------

Note the file .pre-commit-config.yaml at the top of the repo.
This file configures the behavior of the a pre-commit hook based on `the Pre-Commit framework <https://pre-commit.com/>`_. Please see the site about
installing it (with pip, brew or other tools) then run ``pre-commit install`` in the repo's root to activate the hook.
For the full use of the tool, you may need to install also other third-party tools, such as
`shellcheck <https://github.com/koalaman/shellcheck/>`_ and `shfmt <https://github.com/mvdan/sh>`_.


.. _linting_your_changes:

Linting Your Changes
--------------------

In order to properly lint your changes, you should use our linting script,
by simply running ``./lint_clean_files.sh``. This script iterates over all marked-as-clean
files, and runs the pre-commit hook on them.

Please note that most of the files in the project are currently not linted,
as we want to make the linting process easier.
In order to add your changed/added files to the linting process,
please add your files to ``clean_files.txt``. This way ``lint_clean_files.sh``
will know to pick them up and lint them.

Thank you for helping clean up Bash-it, and making it a nicer and better project |:heart:|
