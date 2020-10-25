.. _update:

Bash-it update
^^^^^^^^^^^^^^

To update Bash-it to the latest stable version, simply run:

.. code-block:: bash

   bash-it update stable

If you want to update to the latest dev version (directly from master), run:

.. code-block:: bash

   bash-it update dev

If you want to update automatically and unattended, you can add the optional
``-s/--silent`` flag, for example:

.. code-block:: bash

   bash-it update dev --silent

.. _migrate:

Bash-it migrate
^^^^^^^^^^^^^^^

If you are using an older version of Bash-it, it's possible that some functionality has changed, or that the internal structure of how Bash-it organizes its functionality has been updated.
For these cases, we provide a ``migrate`` command:

.. code-block:: bash

   bash-it migrate

This command will automatically migrate the Bash-it structure to the latest version.
The ``migrate`` command is run automatically if you run the ``update``\ , ``enable`` or ``disable`` commands.
