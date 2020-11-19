.. image:: gnupg-logo.*
    :alt: GNU Privacy Guard Logo
    :align: right


OpenPGP
=======

`GnuPG <https://gnupg.org/>`_ allows to encrypt and sign your data and
communication, features a versatile key management system as well as access
modules for all kinds of public key directories.

GnuPG is a complete and free implementation of the OpenPGP standard as defined
by :RFC:`4880` (also known as `PGP or Pretty Good Privacy
<https://en.wikipedia.org/wiki/Pretty_Good_Privacy>`_).


.. contents::
    :depth: 2
    :local:
    :backlinks: top


.. note::

    Throughout this documentation we assume GnuPG version 2.2.x as
    pre-installed in Ubuntu 20.04.


Prerequisites
-------------

Disable the Gnome SSH Agent
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Disable autostart of the Gnome SSH agent::

    $ mkdir -p ~/.config/autostart
    $ cp /etc/xdg/autostart/gnome-keyring-ssh.desktop ~/.config/autostart/
    $ echo 'X-GNOME-Autostart-enabled=false' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop
    $ echo 'Hidden=true' \
        >> ~/.config/autostart/gnome-keyring-ssh.desktop


Restart any Gnome keyring daemon which might already be running::

    $ /usr/bin/gnome-keyring-daemon --replace --components keyring,pkcs11


Systemd User Environment
^^^^^^^^^^^^^^^^^^^^^^^^

In Ubuntu 20.04.1 there is a script which tells SystemD services, how to
communicate with the GnuPG SSH Agent. But it somehow lacks the execution bit.
This
`might be a bug <https://bugs.launchpad.net/ubuntu/+source/gnupg2/+bug/1901724>`_,
but for the time being ...

::

    $ sudo chmod +x /lib/systemd/user-environment-generators/90gpg-agent


Bash User Environment
^^^^^^^^^^^^^^^^^^^^^

The following lines should be added to your local profile settings file
:file:`~/.profile`::

    # Let GnuPG know which key you normally use
    export GPGKEY=0x0123456789ABCDEF

    # Let the SSH Agent know how to communicate with GPG Agent.
    unset SSH_AGENT_PID
    if [ "${gnupg_SSH_AUTH_SOCK_by:-0}" -ne $$ ]; then
        SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
        export SSH_AUTH_SOCK
    fi


Terminal Sessions Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

GnuPG and the GnuPG Agent need the following lines added to your shell
configuration file :file:`~/.bashrc`::

    #
    # GnuPG Agent
    GPG_TTY=$(tty)
    export GPG_TTY


Configuration
-------------


GnuPG
^^^^^

The available configuration options can be found on the `gpg man page
<https://manpages.ubuntu.com/manpages/bionic/man1/gpg.1.html#options>`_.

Open the file :download:`.gnupg/gpg.conf </desktop/config-files/gnupg/gpg.conf>` in you
home directory and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/gpg.conf


GnuPG Agent
^^^^^^^^^^^

The "Gnu Privacy Guard Agent" is a service which safely manages your
private-keys in the background. Any application (e.g. the mail-client signing a
message with your key) don't need direct access to your key or your passphrase.
Instead they go trough the agent, which eventually will ask the user for the key
passphrase in a protected environment.

Additionally GnuPG-Agent also will manage your SSH keys, thus replacing the SSH-
Agent.

The available configuration options can be found on the `gpg-agent man page
<https://manpages.ubuntu.com/manpages/bionic/man1/gpg-agent.1.html#options>`_.

Open the file  :download:`.gnupg/gpg-agent.conf </desktop/config-files/gnupg/gpg-agent.conf>`
and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/gpg-agent.conf


Directory Manager
^^^^^^^^^^^^^^^^^

**dirmngr** takes care of retrieving PGP public keys of from various sources
(i.e. key-servers). It is also used as a server for managing and downloading
certificate revocation lists (CRL) for X.509 certificates, downloading X.509
certificates, and providing access to OCSP providers. :file:`dirmngr` is invoked
internally by :file:`gpg`, :file:`gpgsm`, or via the :file:`gpg-connect-agent`
tool.

The available configuration options can be found on the `dirmngr man page
<https://manpages.ubuntu.com/manpages/bionic/en/man8/dirmngr.8.html#options>`_.

Open the file  :download:`.gnupg/dirmngr.conf </desktop/config-files/gnupg/dirmngr.conf>`
and change, add or uncomment as follows:

.. literalinclude:: /desktop/config-files/gnupg/dirmngr.conf


PIN Entry
^^^^^^^^^

"PIN Entry" is used by "GnuPG Agent" and others to safely ask the user for a
passphrase in a secure manner. It works on various graphical desktop
environments, text-only consoles and terminal sessions.

"GPG Agent" and "PIN Entry" will not only make the handling of your keys more
secure, but also easier to use. You can set a time, during which you keys will
stay unlocked so you are not required to enter your passphrase again every time
they key is needed.


Related Tools and Options
-------------------------


Seahorse Nautilus Extension
^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Seahorse**, sometimes also called "Secretes and Keys" is the name of the Gnome
Desktop application that provides a graphical user interface for the user to
manage his secrets inside the Gnome-Keyring.

The "Nautilus extension for Seahorse integration" allows encryption
and decryption of OpenPGP files using GnuPG.

.. image:: seahorse-nautilus.*
    :alt: The Seahorse Nautilus extensions in action.


.. image:: /scbutton-free-200px.*
    :alt: Install seahorse-nautilus
    :target: apt:seahorse-nautilus
    :align: left

Install **seahorse-nautilus** from the Ubuntu Software Center

or with the command-line::

    $ sudo apt install seahorse-nautilus


Use a Password-Safe
^^^^^^^^^^^^^^^^^^^

Store your GnuPG passphrases in a password-safe, like KeePassXC.

See the section `KeePassXC </desktop/secrets.html#keepassxc>`_ on how to set it
up.


Yubikey Neo
^^^^^^^^^^^

Store your private keys on a secure hardware device, and use it everywhere,
instead of storing the as files on disks.

See :doc:`yubikey/yubikey_gpg`.


Enigmail
^^^^^^^^

Encrypt, decrypt, digitally sign and verify your mail communications.

See :doc:`/desktop/thunderbird`.


Using PGP keys on remote Machines
---------------------------------

If you frequently you work on remote systems, you can use GnuPG on these
systems, without the need to transfer and install any private keys there.

You can use GnuPG as in the same way as on your local machine, while signing or
decrypting, files and mails, perform signed git operations, signing software
packages or use the GnuPG ssh-agent while opening remote sessions to further
systems or transferring files. All the while your private keys never leave your
local machine.

This is even more useful if you keep your private keys ona a hardware token
(like a :doc:`YubiKey <yubikey/index>` or a smartcard), since you can't plug-in
your hardware key in the remote system.

The GnuGP agent can be told to use an additional socket on the local system and
forward it to the remote system trough the secure SSH connection. On the remote
system that socket is then connected to the gpg-agent socket and used by gpg,
as if it where a locally running gpg-agent.


Remote System Setup
^^^^^^^^^^^^^^^^^^^

The **remote SSH server** needs to be told how to manage these remote sockets.

Add the following line to your remote
:doc:`SSH Server</server/ssh-server>` file :file:`/etc/ssh/sshd_config`::

    # Specifies whether to remove an existing Unix-domain socket file for local
    # or remote port forwarding before creating a new one. If the socket file
    # already exists and StreamLocalBindUnlink is not enabled, sshd will be un-
    # able to forward the port to the Unix-domain socket file. This option is
    # only used for port forwarding to a Unix-domain socket file. The argument
    # must be yes or no. The default is no.
    StreamLocalBindUnlink yes


To activate this change, the remote SSH server needs a restart::

    remote$> sudo systemctl restart ssh.service
    remote$> logout
    Connection to remote.example.net closed.


Also on the **remote** system, we need to know, where the gpg-agent socket is
found::

    remote$> gpgconf --list-dir agent-socket
    /run/user/1000/gnupg/S.gpg-agent


Local System Setup
^^^^^^^^^^^^^^^^^^

On the **local system** we need to know the location of the gpg-agent **extra
socket**::

    local$> gpgconf --list-dir agent-extra-socket
    /run/user/1000/gnupg/S.gpg-agent.extra

An additional **extra socket** is needed on the **local system**, so we can
still also use our local gpg-agent as usual.

Since we now know the locations of both the **local extra socket** and the
**remote socket**, we can set up the forward in the **local SSH client**
configuration::

    Host remote.example.net
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra


Personally I use a slightly different configuration, as I connect to multiple
systems with different user-ids, but have this setup only on a subset of them::

    # We have GPG agent sockets setup on some hosts.
    Match Host dolores.*,maeve.*,bernard.*,arnold.* User john
        RemoteForward /run/user/1000/gnupg/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent.extra


Remote GnuPG Setup
^^^^^^^^^^^^^^^^^^

While you now have your private keys available on the remote system, GnuPG is
not yet fully usable remotely without the public keyrings.

This is how we transfer the public keys and trust settings from the local to the
remote system::

    local$> gpg --export-options export-local-sigs --export $GPGKEY | \
                ssh remote.example.net gpg --import
    local$> gpg --export-ownertrust | \
                ssh remote.example.net gpg --import-ownertrust

You also might want to assimilate the GnuPG configuration::

    local$> scp ~/.gnupg/*.conf remote.example.net:/home/user/.gnupg/


Signing GIT Operations
----------------------

In :doc:`/desktop/toolbox/git-scm` you find a description to set up git for
signing and verifying various operations.


Publishing Keys
---------------

As can be seen with the :file:`--auto-key-locate` configuration parameter of
there are various ways to find and import a key.


Key-Servers
^^^^^^^^^^^

Public key servers are still the mostly widely used way to find OpenPGP keys,
but other methods come with significant benefits over the old key servers.

In recent years, various problems with with the key-servers and their federation
model have been discovered. In terms of reliability, abuse-resistance, privacy,
and usability, the use of key servers can no longer be recommended.

Notable keys servers include:

 * keys.openpgp.org <https://keys.openpgp.org>

DNS CERT
^^^^^^^^

Publishing keys using DNS CERT, as specified in RFC-4398.


PKA
^^^

PKA (public key association) puts a pointer where to obtain a key into a DNS TXT
record. At the same time that can be used to verify that a key belongs to a mail
address. The documentation is at the g10code website (only in German so far).

TBD

::

        $ gpg --export-options export-minimal,export-pka \
        --export-filter keep-uid="uid=~@example.net" \
        --export $GPGKEY


DANE
^^^^

The :RFC:`7929` titled "DNS-Based Authentication of Named Entities (DANE)
Bindings for OpenPGP"  describes a mechanism to associate a user's OpenPGP
public key with their email address, using the OPENPGPKEY DNS RRtype.
These records are published in the DNS zone of the user's email
address.  If the user loses their private key, the OPENPGPKEY DNS
record can simply be updated or removed from the zone.

As with other DANE records like TLSA, the OPENPGPKEY data is supposed to be
secured by DNSSEC.

The :file:`gpg` provides a way to output the required DNS records for a key with
the **export-dane** export option.

Since this will be published as DNS record, we want to export the smallest
possible key. We therefore also add the **export-minimal** export-option.

Additionally, most users have multiple user-ids (email addresses) in their key.
Probably not all of those domains provide write-access to their DNS records
(i.e. gmail.com). With the **keep-uid** export-filter, only the records for the
domain we actually are allowed to publish will be shown::

    $ gpg --export-options \
                export-minimal,export-dane \
        --export-filter keep-uid="uid=~@example.net" \
        --export $GPGKEY

This outputs records in generic format as TYPE61.

If you want standard OPENPGPKEY format records::

    $ export MY_USER=john MY_DOMAIN=example.net
    $ echo -e "$( echo -n "$MY_USER" | sha256sum | head --bytes=56 )._openpgpkey.${MY_DOMAIN}. IN OPENPGPKEY (\n $( gpg --export-options export-minimal --export-filter keep-uid="uid=~@${MAIL_DOMAIN}" --export $GPGKEY | hexdump -e '"\t" /1 "%.2x"' -e '/32 "\n"' )\n )"


There is also the online
`DNS OPENPGPKEY Record Generator <https://www.huque.com/bin/openpgpkey>`_ who
generates standard OPENPGPKEY records.


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
drive along with other important and protected files, like your KeepassXC
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
