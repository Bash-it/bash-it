.. _powerline_multiline:

Powerline Multiline Theme
=========================

A colorful multiline theme, where the first line shows information about your shell session (divided into two parts, left and right), and the second one is where the shell commands are introduced.

See :ref:`powerline_base` for general information about the powerline theme.

Soft Separators
^^^^^^^^^^^^^^^

Adjacent segments having the same background color will use a less-pronouced (i.e. soft) separator between them.

Padding
^^^^^^^

To get the length of the left and right segments right, a *padding* value is used.
In most cases, the default value (\ *2*\ ) works fine, but on some operating systems, this needs to be adjusted.
One example is *macOS High Sierra*\ , where the default padding causes the right segment to extend to the next line.
On macOS High Sierra, the padding value needs to be changed to *3* to make the theme look right.
This can be done by setting the ``POWERLINE_PADDING`` variable before Bash-it is loaded, e.g. in your ``~/.bash_profile`` or ``~/.bashrc`` file:

.. code-block:: bash

   export POWERLINE_PADDING=3


Multiline Mode Right Prompt
^^^^^^^^^^^^^^^^^^^^^^^^^^^

For the purposes of the :ref:`Compact <powerline_compact_settings>` settings, the segments within the **Right Prompt** are considered to run "right-to-left", i.e.:


* The **right-most** segment is considered to be the ``"first"`` segment, while the **left-most** segment is considered to be the ``"last"``
* The space to the **right** of the separator character is considered to be ``"before"``\ , while the space to the **left** is considered to be ``"after"``
