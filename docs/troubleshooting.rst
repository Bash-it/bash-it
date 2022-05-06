.. _troubleshooting:

Troubleshooting Guide
=====================

Table of Contents
-----------------

* `I'm stuck in the LightDM login screen after setting up bash-it. <#id1>`_
* `Pre-commit installation is failed with "unrecognized option --gdwarf-5" error. <#id3>`_ 

I'm stuck in the LightDM login screen after setting up bash-it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Possible issue**\ : `#672 <https://github.com/Bash-it/bash-it/issues/672>`_

**Solution**\ : Check `this comment <https://github.com/Bash-it/bash-it/issues/672#issuecomment-257870653>`_ for detailed information about the cause and solution for this issue.

Pre-commit installation is failed with "unrecognized option --gdwarf-5" error
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Possible issue**\ : You might have an incompatible version of GCC is installed. Supported versions are below ``gcc-10``

**Solution** Export the different gcc version using ``export CC=gcc-8``. For more information, check `this comment <https://github.com/Bash-it/bash-it/issues/1696#issuecomment-1035968473>`__.
