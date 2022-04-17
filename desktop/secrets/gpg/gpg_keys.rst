Managing OpenPGP Keys
=====================


Use a Password-Safe
-------------------

Store your GnuPG passphrases in a password-safe, like KeePassXC.

See the section `KeePassXC </desktop/secrets.html#keepassxc>`_ on how to set it
up.


Gnu Privacy Guard Configuration
-------------------------------

Let GnuPG know which key you normally use:

.. literalinclude:: /desktop/config-files/gnupg/gpg.conf
    :lines: 1-27
    :linenos:
    :lineno-start: 1


Bash User Environment
---------------------

The following lines should be added to your local profile settings file
:file:`~/.profile`::

    # Let GnuPG know which key you normally use
    export GPGKEY=0x0123456789ABCDEF

This comes in handy for you to, you can use the :command:`$GPGKEY` environment
variable on the command-line and in scripts. In fact most of the PGP-related
commands in this guide assume, that this variable is correctly set.


Backup Your Keys!
-----------------

Backup is very important. If you lose your private key or the passphrase for
it, everything encrypted will not be recoverable.

Backups of your private keys and key-rings should be stored on a
:doc:`encrypted USB drive </desktop/luks>` along with other important and
protected files, like your KeepassXC password database, your personal TLS
certificates and SSH private keys.

The following steps assume, your safe storage is mounted on
:file:`/media/${USER}/SafeStorage`::

    # Create a backup directory on the safe storage::
    $ mkdir /media/${USER}/SafeStorage/OpenPGP

    # Which key you wnat to backup
    export GPGKEY=0x0123456789ABCDEF

    # Export your Private Key
    $ gpg --verbose --export-options backup --armor \
        --output /media/${USER}/SafeStorage/OpenPGP/${$GPGKEY}.private.asc \
        --export-secret-keys $GPGKEY

    # Export your public key
    gpg --verbose --export-options backup --armor \
        --output /media/${USER}/SafeStorage/OpenPGP/${$GPGKEY}.asc \
         --export $GPGKEY

    # Export your personal trust settings, towards other peoples keys
    $ gpg --verbose --export-ownertrust \
        > /media/${USER}/SafeStorage/OpenPGP/OwnerTrust.db

    # Backup your revocation certificates
    $ cp --archive --verbose --interactive \
         ~/.gnupg/openpgp-revocs.d /media/${USER}/SafeStorage/OpenPGP/


Restoring Private and Public Keys
---------------------------------

The following steps assume, your safe storage is mounted on
:file:`/media/${USER}/SafeStorage`::

    # Which key you wnat to restore
    export GPGKEY=0x0123456789ABCDEF

    # Import your public key
    gpg --verbose --import-options restore --armor \
        --import /media/${USER}/SafeStorage/OpenPGP/${$GPGKEY}.asc \

    # Import your private key
    $ gpg --verbose --import-options restore --armor \
        --import /media/${USER}/SafeStorage/OpenPGP/${$GPGKEY}.private.asc \

    # Import your personal trust settings
    $ gpg --verbose --import-ownertrust \
        < /media/${USER}/SafeStorage/OpenPGP/OwnerTrust.db
    $ gpg --verbose --check-trustdb

    # Set your own key as ulimatetly trusted
    $ gpg --edit-key $GPGKEY
