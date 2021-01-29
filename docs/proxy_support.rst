.. _proxy_support:

Proxy Support
^^^^^^^^^^^^^

If you are working in a corporate environment where you have to go through a proxy server for internet access,
then you know how painful it is to configure the OS proxy variables in the shell,
especially if you are switching between environments, e.g. office (with proxy) and home (without proxy).

The Bash shell (and many shell tools) use the following variables to define the proxy to use:


* ``HTTP_PROXY`` (and ``http_proxy``\ ): Defines the proxy server for HTTP requests
* ``HTTPS_PROXY`` (and ``https_proxy``\ ): Defines the proxy server for HTTPS requests
* ``ALL_PROXY`` (and ``all_proxy``\ ): Used by some tools for the same purpose as above
* ``NO_PROXY`` (and ``no_proxy``\ ): Comma-separated list of hostnames that don't have to go through the proxy

Bash-it's ``proxy`` plugin allows to enable and disable these variables with a simple command.
To start using the ``proxy`` plugin, run the following:

.. code-block:: bash

   bash-it enable plugin proxy

Bash-it also provides support for enabling/disabling proxy settings for various shell tools.
The following backends are currently supported (in addition to the shell's environment variables): Git, SVN, npm, ssh.
The ``proxy`` plugin changes the configuration files of these tools to enable or disable the proxy settings.

Bash-it uses the following variables to set the shell's proxy settings when you call ``enable-proxy``.
These variables are best defined in a custom script in Bash-it's custom script folder (\ ``$BASH_IT/custom``\ ), e.g. ``$BASH_IT/custom/proxy.env.bash``


* ``BASH_IT_HTTP_PROXY`` and `BASH_IT_HTTPS_PROXY`: Define the proxy URL to be used, e.g. 'http://localhost:1234'
* ``BASH_IT_NO_PROXY``\ : A comma-separated list of proxy exclusions, e.g. ``127.0.0.1,localhost``

Once you have defined these variables (and have run ``reload`` to load the changes), you can use the following commands to enable or disable the proxy settings in your current shell:


* ``enable-proxy``\ : This sets the shell's proxy environment variables and configures proxy support in your SVN, npm, and SSH configuration files.
* ``disable-proxy``\ : This unsets the shell's proxy environment variables and disables proxy support in your SVN, npm, and SSH configuration files.

There are many more proxy commands, e.g. for changing the local Git project's proxy settings.
Run ``glossary proxy`` to show the available proxy functions with a short description.
