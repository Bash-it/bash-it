.. _custom:

Custom Content
--------------

For custom scripts, and aliases, just create the following files (they'll be ignored by the git repo):


* ``aliases/custom.aliases.bash``
* ``completion/custom.completion.bash``
* ``lib/custom.bash``
* ``plugins/custom.plugins.bash``
* ``custom/themes/<custom theme name>/<custom theme name>.theme.bash``

Anything in the custom directory will be ignored, with the exception of ``custom/example.bash``.

Alternately, if you would like to keep your custom scripts under version control, you can set ``BASH_IT_CUSTOM`` in your ``~/.bashrc`` to another location outside of the ``$BASH_IT`` folder.
In this case, any ``*.bash`` file under every directory below ``BASH_IT_CUSTOM`` folder will be used.
