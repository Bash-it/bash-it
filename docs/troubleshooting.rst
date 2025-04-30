.. _troubleshooting:

Troubleshooting Guide
=====================

Table of Contents
-----------------

* `I'm stuck in the LightDM login screen after setting up bash-it. <im-stuck-in-the-lightdm-login-screen-after-setting-up-bash-it>`_

* `I'm getting strange line break and wrapping behaviour on macOS. <im-getting-strange-line-break-and-wrapping-behaviour-on-macos>`_

I'm stuck in the LightDM login screen after setting up bash-it
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Possible issue**\ : `#672 <https://github.com/Bash-it/bash-it/issues/672>`_

**Solution**\ : Check `this comment <https://github.com/Bash-it/bash-it/issues/672#issuecomment-257870653>`_ for detailed information about the cause and solution for this issue.

I'm getting strange line break and wrapping behaviour on macOS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Possible issue**\ : `#1614 <https://github.com/Bash-it/bash-it/issues/1614>`_

**Solution**\ : Bash-it requires Bash 4.?? or later to run correctly. Any reasonably current Linux distribution should have shipped with a compatible version of Bash. However, macOS users must upgrade from the included, obsolete Bash version 3. While some functionality might work with Bash 3, there is no guarantee that everything will work perfectly. Thus, we recommend using `Homebrew <https://brew.sh/>`_ to ensure Bash is up to date:

x86 Mac
^^^^^^^

  .. code-block:: bash

     brew install bash
     sudo sh -c 'echo /usr/local/bin/bash >> /etc/shells'
     chsh -s /usr/local/bin/bash

M1 Mac
^^^^^^

Homebrew's default installation location on M1 is ``/opt/homebrew/bin/``:

  .. code-block:: bash

     brew install bash
     sudo sh -c 'echo /opt/homebrew/bin/bash >> /etc/shells'
     chsh -s /opt/homebrew/bin/bash
