.. _contributing:

Contribution Guidelines
=======================

When contributing a new feature, a bug fix, a new theme, or any other change to Bash-it, please consider the following guidelines.
Most of this is common sense, but please try to stick to the conventions listed here.

Issues
------


* When reporting a bug or requesting a new feature, consider providing a Pull Request that fixes the issue or can be used as a starting point for the new feature.
  Don't be afraid, most things aren't that complex...

Pull Requests
-------------


* Fork the Bash-it repo, create a new feature branch from *master* and apply your changes there.
  Create a *Pull Request* from your feature branch against Bash-it's *master* branch.
* Limit each Pull Request to one feature.
  Don't bundle multiple features/changes (e.g. a new *Theme* and a fix to an existing plugin) into a single Pull Request - create one PR for the theme, and a separate PR for the fix.
* For complex changes, try to *squash* your changes into a single commit before
  pushing code. Once you've pushed your code and opened a PR, please refrain
  from force-pushing changes to the PR branch – remember, Bash-it is a
  distributed project and your branch may be in use already.
* When in doubt, open a PR with too many commits. Bash-it is a learning project
  for everyone involved. Showing your work provides a great history for folks
  to learn what works and what didn't.

Code Style
----------


* When adding new files, be sure to add them into `clean_files.txt`, which is a growing list of linted files in the project.
* When changing existing files, consider also adding them into `clean_files.txt` and fixing the linting errors that arise. See :ref:`linting_your_changes` for more information.
* Indentation is using tabs, not spaces. Most of the code is indented with 2 spaces, some with 4 spaced tabs. Please try to stick to tabs.
  If you're using an editor that supports `EditorConfig <http://EditorConfig.org>`_\ , the editor should automatically use the settings defined in Bash-it's `.editorconfig file <.editorconfig>`_.
* Prefer to invoke commands directly using the ``command`` shell builtin. This way, your code
  will always execute the command you wanted and not an alias/function that overrides the name of the command. (For example, use ``command rm`` instead of ``rm``)
* When creating new functions, please use a dash ("-") to separate the words of the function's name, e.g. ``my-new-function``.
  Don't use underscores, e.g. ``my_new_function``.
* Internal functions that aren't to be used by the end user should start with an underscore, e.g. ``_my-new-internal-function``.
* Use the provided meta functions to document your code, e.g. ``about-plugin``\ , ``about``\ , ``group``\ , ``param``\ , ``example``.
  This will make it easier for other people to use your new functionality.
  Take a look at the existing code for an example (e.g. `the base plugin <plugins/available/base.plugin.bash>`_\ ).
* When adding files, please use the existing file naming conventions, e.g. plugin files need to end in ``.plugin.bash``.
  This is important for the installation functionality.
* When using the ``$BASH_IT`` variable, please always enclose it in double quotes to ensure that the code also works when Bash-it is installed in a directory that contains spaces in its name: ``for f in "${BASH_IT}/plugins/available"/*.bash ; do echo "$f" ; done``
* Bash-it supports Bash 3.2 and higher. Please don't use features only available in Bash 4, such as associative arrays.

Unit Tests
----------

When adding features or making changes/fixes, please run our growing unit test suite to ensure that you did not break existing functionality.
The test suite does not cover all aspects of Bash-it, but please run it anyway to verify that you did not introduce any regression issues.

Any code pushed to GitHub as part of a Pull Request will automatically trigger a continuous integration build on `GitHub Actions <https://github.com/Bash-it/bash-it/actions>`_\ , where the test suite is run on both Linux and macOS.
The Pull Request will then show the result of the CI build, indicating whether all tests ran fine, or whether there were issues.
Please pay attention to this, Pull Requests with build issues will not be merged.

Adding new functionality or changing existing functionality is a good opportunity to increase Bash-it's test coverage.
When you're changing the Bash-it codebase, please consider adding some unit tests that cover the new or changed functionality.
Ideally, when fixing a bug, a matching unit test that verifies that the bug is no longer present, is added at the same time.

To run the test suite, simply execute the following in the directory where you cloned Bash-it:

.. code-block:: bash

   test/run

This command will ensure that the `Bats Test Framework <https://github.com/bats-core/bats-core>`_ is available in the local ``test_lib`` directory (Bats is included as a Git submodule) and then run the test suite found in the `test <test>`_ folder.
The test script will execute each test in turn, and will print a status for each test case.

When adding new test cases, please take a look at the existing test cases for examples.

The following libraries are used to help with the tests:


* Test Framework: https://github.com/bats-core/bats-core
* Support library for Bats-Assert: https://github.com/bats-core/bats-support
* General ``assert`` functions: https://github.com/bats-core/bats-assert
* File ``assert`` functions: https://github.com/bats-core/bats-file

When verifying test results, please try to use the ``assert`` functions found in these libraries.

Features
--------


* When adding new completions or plugins, please don't simply copy existing tools into the Bash-it codebase, try to load/integrate the tools instead.
  An example is using ``nvm``\ : Instead of copying the existing ``nvm`` script into Bash-it, the ``nvm.plugin.bash`` file tries to load an existing installation of ``nvm``.
  This means an additional step for the user (installing ``nvm`` from its own repo, or through a package manager),
  but it will also ensure that ``nvm`` can be upgraded in an easy way.

.. _contributing_theme:

Themes
------


* When adding a new theme, please include a screenshot and a short description about what makes this theme unique in the Pull Request's description field.
  Please do not add theme screenshots to the main PR itself, as they will add unnecessary bloat to the main branch in the repo.
  The project's docs has a `Themes page <https://github.com/Bash-it/bash-it/blob/master/docs/themes-list/index.rst>`_ where you should add a screenshot, see how :ref:`here<add_screenshot>`.
* Ideally, you should add a ``<theme_name>.rst`` file describing the theme and its configuration options to ``docs/themes-list`` folder.

.. _add_screenshot:

Adding a Screenshot
-------------------

In order to add a new screenshot, use the ``gh-pages`` branch.
Add your new screenshot to the ``docs/images`` folder, and open a PR.
In the `Themes page <https://github.com/Bash-it/bash-it/blob/master/docs/themes-list/index.rst>`_, see the other screenshots to know what kind of link you should use.
