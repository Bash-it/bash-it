.. _reload:

Bash-it reload
^^^^^^^^^^^^^^

Bash-it creates a ``reload`` alias that makes it convenient to reload
your Bash profile when you make changes.

Additionally, if you export ``BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE`` as a non-null value,
Bash-it will automatically reload itself after activating or deactivating plugins, aliases, or completions.

.. warning::
  When changing theme, do not use ``bash-it reload``. Instead, use :ref:`restart`.

.. _restart:

Bash-it restart
^^^^^^^^^^^^^^^

Similar to :ref:`reload`, ``bash-it restart`` can be used to restart your shell.
Instead of reloading your Bash profile, this command re-runs Bash (using exec).

This is stronger than simple reload, and is similar to the effect of closing and reopening your terminal.
