.. _test:

Testing Bash-it
===============

Overview
--------

The Bash-it unit tests leverage the `Bats unit test framework for Bash <https://github.com/bats-core/bats-core>`_.
There is no need to install Bats explicitly, the test run script will automatically download and install Bats and its dependencies.

When making changes to Bash-it, the tests are automatically executed in a test build environment on `GitHub Actions <https://github.com/Bash-it/bash-it/actions>`_. See the :ref:`Continuous Integration <ci>` section for more details.

Test Execution
--------------

To execute the unit tests, please run the ``run`` script:

.. code-block:: bash

   # If you are in the `test` directory:
   ./run

   # If you are in the root `.bash_it` directory:
   test/run

The ``run`` script will automatically install if it is not already present, and will then run all tests found under the ``test`` directory, including subdirectories.

To run only a subset of the tests, you can provide a directory or a specific test file:

.. code-block:: bash

   # Run all tests in a directory:
   test/run test/themes

   # Run a single test file:
   test/run test/completion/op.completion.bats

   # Run multiple specific files:
   test/run test/completion/op.completion.bats test/completion/herdr.completion.bats

The tests always run in single-threaded mode (``TEST_JOBS=1``). Parallel execution
via GNU ``parallel`` was previously supported but caused TAP plan count mismatches
when combined with the ``--tap`` flag, producing false failures. Single-threaded
mode is reliable and is what CI enforces.

Local Runs and Isolation
~~~~~~~~~~~~~~~~~~~~~~~~

Running ``test/run`` directly on your machine works, but it inherits your shell's
``PATH``. Any tool installed locally (e.g. ``op``, ``herdr``, ``docker``) will be
visible to the tests, which can cause tests to behave differently than they do on CI,
where the runner is a clean environment with only a known set of packages installed.

To reproduce CI conditions exactly, use ``test/run-local``, which builds a minimal
Docker image and runs the tests inside it:

.. code-block:: bash

   # Run all tests in a clean container:
   test/run-local

   # Run a subset:
   test/run-local test/completion/op.completion.bats

The image is built on the first run and cached afterwards, so subsequent runs are
fast. The trade-off compared to running ``test/run`` directly is that the first run
takes longer and Docker must be installed.

Writing Tests
-------------

When adding or modifying tests, please stick to the format and conventions of the existing test cases.
The ``test_helper.bash`` script provides a couple of reusable helper functions that you should use when writing a test case,
for example for setting up an isolated test environment.
