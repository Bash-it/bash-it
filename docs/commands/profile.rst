.. _profile:

Bash-it Profile
---------------

Have you ever wanted to port your *Bash-it* configuration into another machine?

If you did, then ``bash-it profile`` is for you!

This command can save and load custom *"profile"* files, that can be later
used to load and recreate your configuration, in any machine you would like |:smile:|

When porting your configuration into a new machine, you just need to save your current profile, copy the resulting *"profile"* file, and load it in the other machine.

Example
^^^^^^^

.. code-block:: bash

     # Saves your current profile
     bash-it profile save my_profile
     # Load the default profile, which is the one used in the default installation.
     bash-it profile load default

     # Do whatever you want:
     # Disable stuff
     bash-it disable ...
     # Enable stuff
     bash-it enable ...
     # If you want to get back into your original configuration, you can do it easily
     bash-it profile load my_profile
