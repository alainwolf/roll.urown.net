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


