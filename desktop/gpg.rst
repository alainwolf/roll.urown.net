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
    :depth: 1
    :local:
    :backlinks: top


Version 1.4 vs. 2.0
-------------------

Current Ubuntu versions install `GnuPG <https://gnupg.org/>`_ version 1.4.x,
while the newer version 2.0.x is recommended for desktop systems.

Amongst others you get the following notable features not available on the
classic version.

 * GnuPG Agent
 * PIN-entry
 * Store keys on a :term:`SmartCard`
 * Support for X.509 certificates and keys, besides OpenPGP keys
 * Support for signed and encrypted mails using S/Mime besides OpenPGP mails
 * Directory Manager

The versions co-exist nicely, if installed on the same system.

Enigmail requires GnuPG 2.0.


GnuPG Agent
-----------

The "Gnu Privacy Guard Agent" is a service which safely manages your private-keys
in the background. Any application (e.g. the mail-client singning a message with
your key) don't need direct access to your keyfile or your passphrase. Instead
they go trough the agent, which eventually will ask the user for the key
passphrase in a protected environment.

Additionally GnuPG-Agent also will manage your SSH keys, thus replacing the SSH-
Agent.


PIN Entry
---------

"PIN Entry" is used by "GnuPG Agent" and others to safely ask the user for a
passphrase in a secure manner. It works on various graphical desktop
environments, text- only consoles and terminal sessions.

.. note::

    PIN Entry version 0.8.3 currently installed from the Ubuntu Software-Center
    disables access to the clipboard for security reasons. Copy or paste of the
    passhrase is not possible. Later versions allow clipboard access to be
    enabled as option, although it is disabled by default.


"GPG Agent" and "PIN Entry" will not only make the handling of your keys more
secure, but also easier to use. You can set a time, during which you keys will
stay unlocked so you are not required to enter your passphrease again every time
they key is needed.


Software Installation
---------------------

"GNU Privacy Guard Version 2", "GnuPG Agent" and "PIN Entry" can be installed from the Ubuntu
Software-Center:

.. raw:: html

        <p>
            <a class="reference external"
            href="apt:gnupg2,gnupg-agent,pinentry-gtk2,pinentry-curses">
            <img alt="software-center" src="../_images/scbutton-free-200px.png" />
            </a>
        </p>


Or by using apt::

    > sudo apt install gnupg2 gnupg-agent pinentry-gtk2 pinentry-curses


Configuration
-------------


Default Key for Command-Line
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To let GnuPG know which key you normally use, set the following environment
variable in the file :file:`${HOME}/.bashrc`:

::

    export GPGKEY=0x0123456789ABCDEF


Key Server Certificate
^^^^^^^^^^^^^^^^^^^^^^

Whenever GnuPG needs a key to check a signature or to encrypt a message and the
public key is not already in our public key ring, that key is retrieved
automatically from the key servers. Also keys already in the key-ring must be
refreshed from the key-servers periodically to see if they have been revoked or
if there have been new signatures added..

This makes it very easy for 3rd-parties to watch with whom we communicate and
gives anyone watching our network automatic periodic updates of all the
contacts in our address-book.

Therefore all communication with the key servers should be encrypted. For this
we download the CA certificate of the SKS key server pool::

    $ wget -O ~/.gnupg/sks-keyservers.netCA.pem \
        https://sks-keyservers.net/sks-keyservers.netCA.pem



GnuPG Options
^^^^^^^^^^^^^

Open the file  :download:`.gnupg/gpg.conf <config-files/gnupg/gpg.conf>` in you home
directory and change, add or uncomment as follows:

.. literalinclude:: config-files/gnupg/gpg.conf


Available configuration options can be found on the `gpg2 man page
<http://manpages.ubuntu.com/manpages/trusty/en/man1/gpg2.1.html#contenttoc7>`_.


GnuPG Agent Options
^^^^^^^^^^^^^^^^^^^

Open the file  :download:`.gnupg/gpg-agent.conf <config-files/gnupg/gpg-agent.conf>`
and change, add or uncomment as follows:

.. literalinclude:: config-files/gnupg/gpg-agent.conf


Available configuration options can be found on the `gpg-agent man page
<http://manpages.ubuntu.com/manpages/trusty/man1/gpg-agent.1.html#contenttoc4>`_.


Shell Login Options
^^^^^^^^^^^^^^^^^^^

GPG Agent needs the following lines added to your shell configuration file
:file:`~/.bashrc`::

    #
    # GPG Agent
    export GPG_TTY=$(tty)

    # Tell ssh about our GPG Agent
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        export SSH_AUTH_SOCK="${HOME}/.gnupg/S.gpg-agent.ssh"
    fi



Related Tools and Options
-------------------------


Disable Seahorse GnuPG-agent
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

By default your GnuPG keys are managed by Seahorse. This can result in problems
when using GnuPG 2.0 or newer versions.

See the section `Disabling the Seahorse GnuPG-Agent
</desktop/secrets.html#disabling-the-seahorse-gnupg-agent>`_ on how to do this.


Use KeePassX
^^^^^^^^^^^^

Store your GNU GPG passphrases in KeePassX.

See the section `KeePassX </desktop/secrets.html#keepassx>`_ on how to set it up.


Use Keychains
^^^^^^^^^^^^^

Keychain helps with managing different passphrase agents, keys and such, without
that they get in the way of each other.

See the section `Keychain </desktop/secrets.html#keychain>`_ on how to set it up.


parcimonie
^^^^^^^^^^

`parcimonie <http://gaffer.ptitcanardnoir.org/intrigeri/code/parcimonie/>`_
incrementally refreshes a GnuPG keyring in a way that:

 * makes it hard to correlate her keyring content to an individual;
 * makes it hard to locate an individual based on an identifying subset of her
   keyring content.

.. raw:: html

        <p>
            <a class="reference external"
            href="apt:parcimonie">
            <img alt="software-center" src="../_images/scbutton-free-200px.png" />
            </a>
        </p>

Once installed the program will automatically start after login of your desktop
session.

But there is a problem. parcimonie uses Tor to connect to to key-servers and
HKPS does not work well over Tor. We therefore have to tell it to use another
server. Preferably a
`Tor Hidden Service <https://sks-keyservers.net/overview-of-pools.php>`_.

In your startup programs change the parcimonie command-line to the following:

    ``parcimonie --gnupg-extra-arg "--keyserver=hkp://jirk5u4osbsr34t5.onion"``

One can also change the :file:`~/.config/autostart/parcimonie.desktop` file
instead.

And while you are there, disable the "parcimnonie applet" as it doesn't work in
Ubuntu Desktop.

The `parcimonie man page
<http://manpages.ubuntu.com/manpages/trusty/en/man1/parcimonie.1p.html>`_ has
additional information.


Yubikey Neo
^^^^^^^^^^^

See :doc:`secrets/yubikey_gpg`.


GnuPG Key Manager
^^^^^^^^^^^^^^^^^

Over time the keyring will grow, especially if used with the ``auto-key-
retrieve`` option we have set earlier. A large keyring my slow down operations
and lead to sluggish response of other applications like Thunderbird with
Enigmail.

How many keys are there? To find out::

    $ gpg --list-keys | grep 'pub ' | wc -l


`gpgkeymgr <https://nudin.github.io/GnuPGP-Tools/>`_ can help doing a spring
cleaning.

Download and install::

    $ cd ~/Downloads
    $ wget https://nudin.github.io/GnuPGP-Tools/gpgkeymgr/gpgkeymgr-0.4.tar.gz
    $ tar -xzf gpgkeymgr-0.4.tar.gz
    $ cd gpgkeymgr-0.4
    $ sudo apt-get install libgpgme11-dev
    $ sudo make install

Usage manual::

    $ man gpgkeymgr


Backup Your Keys!
-----------------

Backup is very important. If you lose your private key or the passhprase for
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

 * `Gnu Privacy Guard 2.0.x manpage
   <http://manpages.ubuntu.com/manpages/trusty/man1/gpg2.1.html>`_

 * `GnuPG Agent manpage
   <http://manpages.ubuntu.com/manpages/trusty/man1/gpg-agent.1.html>`_
