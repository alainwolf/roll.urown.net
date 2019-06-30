.. image:: gnupg-logo.*
    :alt: GNU Privacy Guard Logo
    :align: right


GNU Privacy Guard
=================

`GnuPG <https://gnupg.org/>`_ allows to encrypt and sign your data and
communication, features a versatile key management system as well as access
modules for all kinds of public key directories.

GnuPG is a complete and free implementation of the OpenPGP standard as defined
by :RFC:`4880` (also known as
`PGP or Pretty Good Privacy <https://en.wikipedia.org/wiki/Pretty_Good_Privacy>`_).


.. contents::
    :depth: 2
    :local:
    :backlinks: top


Software Installation
---------------------

Current Ubuntu versions install `GnuPG <https://gnupg.org/>`_ version 2.x,
while versions before Ubuntu 18.04 LTS (bionic) had version 1.4.x pre-installed, 
but allowed to install newer version 2.x.

.. warning::

    Throughout this documentation we assume GnuPG version 2.4 or newer is
    installed.


On Ubuntu 18.04 LTS (bionic) and newer
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $> sudo apt install xloadimage


On Ubuntu 16.04 LTS (bionic) and older
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

On older Ubunutu versions before 18.04 LTS (bionic) "GNU Privacy Guard Version
2.x", "GnuPG Agent" and "PIN Entry" needs to be installed manually::

    $> sudo apt install gnupg2 gnupg-agent pinentry-gtk2 pinentry-curses xloadimage


Both versions are now available as :file:`/usr/bin/gpg` and :file:`/usr/bin/gpg2`.
To use version 2.x by default, define a command alias::

    $> echo "alias gpg='/usr/bin/gpg2'" >> ~/.bash_aliases
    $> source ~/.bash_aliases



Configuration
-------------


GnuPG
^^^^^

The available configuration options can be found on the `gpg man page
<https://manpages.ubuntu.com/manpages/bionic/man1/gpg.1.html#options>`_.

Open the file  :download:`.gnupg/gpg.conf <config-files/gnupg/gpg.conf>` in you home
directory and change, add or uncomment as follows:

.. literalinclude:: config-files/gnupg/gpg.conf


GnuPG Agent
^^^^^^^^^^^

The "Gnu Privacy Guard Agent" is a service which safely manages your private-keys
in the background. Any application (e.g. the mail-client singning a message with
your key) don't need direct access to your keyfile or your passphrase. Instead
they go trough the agent, which eventually will ask the user for the key
passphrase in a protected environment.

Additionally GnuPG-Agent also will manage your SSH keys, thus replacing the SSH-
Agent.

The available configuration options can be found on the `gpg-agent man page
<https://manpages.ubuntu.com/manpages/bionic/man1/gpg-agent.1.html#options>`_.

Open the file  :download:`.gnupg/gpg-agent.conf <config-files/gnupg/gpg-agent.conf>`
and change, add or uncomment as follows:

.. literalinclude:: config-files/gnupg/gpg-agent.conf


Directory Manager
^^^^^^^^^^^^^^^^^

Since version 2.1 of GnuPG, dirmngr takes care of accessing the OpenPGP
keyservers. As with previous versions it is also used as a server for managing
and downloading certificate revocation lists (CRLs) for X.509 certificates,
downloading X.509 certificates, and providing access to OCSP providers. Dirmngr
is invoked internally by gpg, gpgsm, or via the gpg-connect-agent tool.

The available configuration options can be found on the `dirmngr man page
<https://manpages.ubuntu.com/manpages/bionic/en/man8/dirmngr.8.html#options>`_.

Open the file  :download:`.gnupg/dirmngr.conf <config-files/gnupg/dirmngr.conf>`
and change, add or uncomment as follows:

.. literalinclude:: config-files/gnupg/dirmngr.conf


PIN Entry
^^^^^^^^^

"PIN Entry" is used by "GnuPG Agent" and others to safely ask the user for a
passphrase in a secure manner. It works on various graphical desktop
environments, text-only consoles and terminal sessions.

"GPG Agent" and "PIN Entry" will not only make the handling of your keys more
secure, but also easier to use. You can set a time, during which you keys will
stay unlocked so you are not required to enter your passphrase again every time
they key is needed.


Login Shell Options
^^^^^^^^^^^^^^^^^^^

GnuPG and the GnuPG Agent need the following lines added to your shell
configuration file :file:`~/.bashrc`::

    # Let GnuPG know which key you normally use
    export GPGKEY=0x0123456789ABCDEF

    #
    # GnuPG Agent
    GPG_TTY=$(tty)
    export GPG_TTY


Related Tools and Options
-------------------------


Disable Seahorse GnuPG-agent
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Seahorse is a GNOME application for managing encryption keys and passwords in
the GNOME Keyring. 

By default your GnuPG keys are managed by Seahorse. This can result in problems
when using GnuPG 2.0 or newer versions.

See the section `Disabling the Seahorse GnuPG-Agent
</desktop/secrets.html#disabling-the-seahorse-gnupg-agent>`_ on how to do this.


Use KeePassXC
^^^^^^^^^^^^^

Store your GnuPG passphrases in KeePassXC.

See the section `KeePassXC </desktop/secrets.html#keepassxc>`_ on how to set it
up.


Yubikey Neo
^^^^^^^^^^^

See :doc:`yubikey/yubikey_gpg`.


Enigmail
^^^^^^^^

See :doc:`thunderbird`.


Use local keys on remote systems over SSH
-----------------------------------------

GnuPG enables you to forward the GnuPG-Agent to a remote system. That means that
you can keep your secret keys on a local machine (or even a hardware token like
a :doc:`YubiKey <yubikey/index>` or smartcard), but use them for signing or
decryption on a remote machine.

This is done by forwarding a special gpg-agent socket to the remote system by
the local SSH client.

Set up the forwards in the *local* SSH-client configuration. We also need
to know the location of the socket on the remote system to connect to.

Show the GnuPG-Agent socket location on the remote server::

    remote$> gpgconf --list-dir agent-socket
    /run/user/1000/gnupg/S.gpg-agent


Show the GnuPG-Agent *extra* socket location on the local client::
    
    local$> gpgconf --list-dir agent-extra-socket
    /run/user/1000/gnupg/S.gpg-agent.extra


No add these both to the SSH client configuration :file:`~/.ssh/config` in the
appropriate server section as **RemoteForward** :file:`RemoteSocket`
:file:`LocalExtraSocket`

**RemoteForward** specifies that a socket from the *remote machine* be forwarded
over the secure channel to a *local* socket

::

    Host remote.example.net
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra


Also add the following line to your remote :doc:`SSH Server
</server/ssh-server>` file :file:`/etc/ssh/sshd_config`::

    # Specifies whether to remove an existing Unix-domain socket file for local
    # or remote port forwarding before creating a new one. If the socket file
    # already exists and StreamLocalBindUnlink is not enabled, sshd will be un-
    # able to forward the port to the Unix-domain socket file. This option is
    # only used for port forwarding to a Unix-domain socket file. The argument
    # must be yes or no. The default is no.
    StreamLocalBindUnlink yes


Then restart the remote SSH server for the configuration change to be applied::

    remote$> sudo systemctl restart ssh.service
    remote$> logout
    Connection to remote.example.net closed.

After re-connecting your local keyring should be available on the remote system,
but not yet usable without their corresponding public keys and trust settings.

This is how we transfer your public key and trust settings from the local to the
remote system::

    local$> gpg --export-options export-local-sigs --export $GPGKEY | \
                ssh remote.example.net gpg --import
    local$> gpg --export-ownertrust | \
                ssh remote.example.net gpg --import-ownertrust


You also might want to assimilate the GnuPG configuration::

    local$> cd ~/.gnupg/
    local$> scp gpg.conf dirmngr.conf gpg-agent.conf \
                remote.example.net:/home/user/.gnupg/


Publishing Keys
---------------

As can be seen with the :file:`--auto-key-locate` configuration parameter of
there are various ways to find and import a key.


Keyservers
^^^^^^^^^^

Public Keyservers are still the mostly widely used way to find OpenPGP keys, but
other methods come with significant benefits over the old keyserver.


LDAP
^^^^


DNS CERT
^^^^^^^^

Publishing keys using DNS CERT, as specified in RFC-4398.


PKA
^^^


DANE
^^^^


Web Key Directory
^^^^^^^^^^^^^^^^^

TBD.


Keybase.io
^^^^^^^^^^

TBD.


Backup Your Keys!
-----------------

Backup is very important. If you lose your private key or the passphrase for
it, everything encrypted will not be recoverable.

Backups of your private keys and key-rings should be stored on a encrypted USB
drive along with other important and protected files, like your KeepassX
password database, your personal TLS certificates and private keys and the ones
of your servers.

::

    # Export all public keys from your keyring
    $ gpg2 --output /media/user/SafeStorage/pubring.asc \
        --export-options=export-local-sigs,export-sensitive-revkeys \
        --armor --export
    # Export your private keys from your keyring
    $ gpg2 --output /media/user/SafeStorage/secring.asc \
        --armor --export-secret-key
    # Export your personal trust settings, towards other peoples keys
    $ gpg2 --export-ownertrust > /media/user/SafeStorage/gpg-ownertrust-db.txt



References
----------

 * `riseup.net OpenPGP Best Practices
   <https://help.riseup.net/en/security/message-security/openpgp/best-practices>`_

 * `Ubuntu GNU Privacy Guard How To
   <https://help.ubuntu.com/community/GnuPrivacyGuardHowto>`_

 * `Gnu Privacy Guard 2.2.4 manpage
   <https://manpages.ubuntu.com/manpages/bionic/en/man1/gpg.1.html>`_

 * `GnuPG Agent manpage
   <http://manpages.ubuntu.com/manpages/bionic/man1/gpg-agent.1.html>`_

 * `How to use local secrets on a remote machine 
   <https://wiki.gnupg.org/AgentForwarding>`_
