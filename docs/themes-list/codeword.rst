.. _codeword:

Codeword Theme
==============

Single line PS1 theme w/realtime history among windows.
Minimal theme overrides from bash_it base theming

``user@host:path[virt-env][scm] $``
---------------------------------------

Breakdown of the segments:


* **user@host:path** - *convienient for LAN based ``ssh`` and ``scp`` tasks*
* [\ **virtualenv**\ ] - *only appears when activated*
* [\ **scm**\ ] - *only appears when activated*
* **marker** - *$ or # depending on current user*

Examples
^^^^^^^^

.. code-block:: bash

   user@example.lan:~ $ cd /tmp/foo/bar/baz
   user@example.lan:/tmp/foo/bar/baz $ cd $HOME/workspace
   user@example.lan:~/workspace $ cd sampleRepo/
   user@example.lan:~/workspace/sampleRepo [± |master ↑1 ↓3 {1} S:2 ?:1 ✗|] $
