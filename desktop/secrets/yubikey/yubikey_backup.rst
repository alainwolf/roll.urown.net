Backup Yubikey
==============

OpenPGP Keys
------------

Safe working Environment
^^^^^^^^^^^^^^^^^^^^^^^^

To setup a second Yubikey for use with your OpenPGP keys, you need a
:doc:`backup of your private keys </desktop/secrets/gpg/gpg_keys>`, since its
not possible to get anything out of your original Yubikey.

Since we created a backup of our OpenPGP private keys on the
:doc:`/desktop/luks`, residing on your :doc:`/desktop/tails` we boot our
workstation with it. Keep the Network cable unplugged and wireless and
bluetooth disabled.

Mount the safe storage. The following steps assume, your safe storage is
mounted on :file:`/media/${USER}/SafeStorage`.

Kill all running GnuPG agents, directory managers, etc, as they might
interfere::

    $ gpgconf --kill all


Set which key we need to move to our backup Yubikey::

    $ export GPGKEY=0x0123456789ABCDEF


Create a temporary GnuPG home directory::

    $ export GNUPGHOME=$(mktemp -d -t gnupg_$(date +%Y%m%d%H%M)_XXX)


Import from Backup
^^^^^^^^^^^^^^^^^^

Import the backup from the safe storage to the temporary working directory::

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


Prepare the Yubikey
^^^^^^^^^^^^^^^^^^^

$ gpg --card-edit

Set the PIN code, nedded to unlock the private key on the card before use::

    gpg/card> admin
    gpg/card> admin
    Admin commands are allowed

    gpg/card> passwd
    gpg: OpenPGP card no. D2760001240102000000012345670000 detected

    1 - change PIN
    2 - unblock PIN
    3 - change Admin PIN
    4 - set the Reset Code
    Q - quit

    Your selection? 1

On a new Yubikey the default is set to **123456**.

Change the Admin PIN::

    1 - change PIN
    2 - unblock PIN
    3 - change Admin PIN
    4 - set the Reset Code
    Q - quit

    Your selection? 3

On a new Yubikey the default Admin PIN is **12345678**.


Move OpenPGP Key to Yubikey
^^^^^^^^^^^^^^^^^^^^^^^^^^^

    $ gpg --edit-key $GPGKEY

