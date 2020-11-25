GPG Setup and Configuration
===========================

.. note::

    Throughout this documentation we assume GnuPG version 2.2.x as
    pre-installed in Ubuntu 20.04.


GnuPG Configuration
-------------------

The available configuration options can be found on the `gpg man page
<https://manpages.ubuntu.com/manpages/bionic/man1/gpg.1.html#options>`_.

Open the file :download:`.gnupg/gpg.conf </desktop/config-files/gnupg/gpg.conf>` in you
home directory and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/gpg.conf


GnuPG Agent Configuration
-------------------------

The "Gnu Privacy Guard Agent" is a service which safely manages your
private-keys in the background. Any application (e.g. the mail-client signing a
message with your key) don't need direct access to your key or your passphrase.
Instead they go trough the agent, which eventually will ask the user for the key
passphrase in a protected environment.

Additionally GnuPG-Agent also will manage your SSH keys, thus replacing the SSH-
Agent.

The available configuration options can be found on the `gpg-agent man page
<https://manpages.ubuntu.com/manpages/focal/en/man1/gpg-agent.1.html#options>`_.

Open the file  :download:`.gnupg/gpg-agent.conf </desktop/config-files/gnupg/gpg-agent.conf>`
and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/gpg-agent.conf


Terminal Session Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since the GnuPG agent is a long-running background process (daemon), it is not
attached to a particular terminal session or display.

In order to answer requests, the agent needs to know from which terminal or
display that request came from. We can tell him that, trough the environment
variable :file:`GPG_TTY`.

Add the following lines added to your shell configuration file
:file:`~/.bashrc`::

    #
    # Let gpg-agent know from which terminal its has been called.
    GPG_TTY=$(tty)
    export GPG_TTY


Directory Manager Configuration
-------------------------------

**dirmngr** takes care of retrieving PGP public keys of from various sources
(i.e. key-servers). It is also used as a server for managing and downloading
certificate revocation lists (CRL) for X.509 certificates, downloading X.509
certificates, and providing access to OCSP providers. :file:`dirmngr` is invoked
internally by :file:`gpg`, :file:`gpgsm`, or via the :file:`gpg-connect-agent`
tool.

The available configuration options can be found on the `dirmngr man page
<https://manpages.ubuntu.com/manpages/focal/en/man8/dirmngr.8.html#options>`_.

Open the file  :download:`.gnupg/dirmngr.conf </desktop/config-files/gnupg/dirmngr.conf>`
and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/dirmngr.conf


PIN Entry
---------

"PIN Entry" is used by "GnuPG Agent" and others to safely ask the user for a
passphrase in a secure manner. It works on various graphical desktop
environments, text-only consoles and terminal sessions.

"GPG Agent" and "PIN Entry" will not only make the handling of your keys more
secure, but also easier to use. You can set a time, during which you keys will
stay unlocked so you are not required to enter your passphrase again every time
they key is needed.
