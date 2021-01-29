.. _searching:

Bash-it search
--------------

If you need to quickly find out which of the plugins, aliases or completions are available for a specific framework, programming language, or an environment, you can *search* for multiple terms related to the commands you use frequently.
Search will find and print out modules with the name or description matching the terms provided.

Syntax
^^^^^^

.. code-block:: bash

     bash-it search term1 [[-]term2] [[-]term3]....

As an example, a ruby developer might want to enable everything related to the commands such as ``ruby``\ , ``rake``\ , ``gem``\ , ``bundler``\ , and ``rails``.
Search command helps you find related modules so that you can decide which of them you'd like to use:

.. code-block:: bash

   ❯ bash-it search ruby rake gem bundle irb rails
         aliases:  bundler rails
         plugins:  chruby chruby-auto ruby
     completions:  bundler gem rake

Currently enabled modules will be shown in green.

Searching with Negations
^^^^^^^^^^^^^^^^^^^^^^^^

You can prefix a search term with a "-" to exclude it from the results.
In the above example, if we wanted to hide ``chruby`` and ``chruby-auto``\ ,
we could change the command as follows:

.. code-block:: bash

   ❯ bash-it search ruby rake gem bundle irb rails -chruby
         aliases:  bundler rails
         plugins:  ruby
     completions:  bundler gem rake

Using Search to Enable or Disable Components
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By adding a ``--enable`` or ``--disable`` to the search command, you can automatically enable all modules that come up as a result of a search query.
This could be quite handy if you like to enable a bunch of components related to the same topic.

Disabling ASCII Color
^^^^^^^^^^^^^^^^^^^^^

To remove non-printing non-ASCII characters responsible for the coloring of the search output, you can set environment variable ``NO_COLOR``.
Enabled components will then be shown with a checkmark:

.. code-block:: bash

   ❯ NO_COLOR=1 bash-it search ruby rake gem bundle irb rails -chruby
         aliases  =>   ✓bundler ✓rails
         plugins  =>   ✓ruby
     completions  =>   bundler gem rake
