.. _test:

Testing Bash-it
===============

Overview
--------

The Bash-it unit tests leverage the `Bats unit test framework for Bash <https://github.com/bats-core/bats-core>`_.
There is no need to install Bats explicitly, the test run script will automatically download and install Bats and its dependencies.

When making changes to Bash-it, the tests are automatically executed in a test build environment on `Travis CI <https://travis-ci.com>`_.

Test Execution
--------------

To execute the unit tests, please run the ``run`` script:

.. code-block:: bash

   # If you are in the `test` directory:
   ./run

   # If you are in the root `.bash_it` directory:
   test/run

The ``run`` script will automatically install if it is not already present, and will then run all tests found under the ``test`` directory, including subdirectories.

To run only a subset of the tests, you can provide the name of the test subdirectory that you want to run, e.g. like this for the tests in the ``test/themes`` directory:

.. code-block:: bash

   # If you are in the root `.bash_it` directory:
   test/run test/themes

By default, the tests run in single-threaded mode.
If you want to speed up the test execution, you can install the `GNU ``parallel`` tool <https://www.gnu.org/software/parallel/>`_\ , which is supported by Bats.
When using ``parallel``\ , the ``test/run`` script will use a number of threads in parallel, depending on the available CPU cores of your system.
This can speed up test execution significantly.

Writing Tests
-------------

When adding or modifying tests, please stick to the format and conventions of the existing test cases.
The ``test_helper.bash`` script provides a couple of reusable helper functions that you should use when writing a test case,
for example for setting up an isolated test environment.
