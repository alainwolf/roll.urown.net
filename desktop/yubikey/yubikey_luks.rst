Yubikey and Full Disk Encryption
================================

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right

Yubikey's HMAC-SHA1 challenge-response mode can be used to unlock your encrypted
hard disk at boot time.


Required Software
-----------------

`Yubikey for LUKS <https://github.com/cornelinux/yubikey-luks>`_ is available
from package manager::

    $ sudo apt install yubikey-luks


Setup and Configuration
-----------------------

We assume you already have full disk encryption enabled on your desktop system
and you unlock the disk with a password at boot time.


Important Information
^^^^^^^^^^^^^^^^^^^^^

#. The disk device and partition number where your encrypted file system resides.

#. The LUKS key-slot to use. By default slot 7 (the last one) will be used.

On my personal computer the physical device holding the encrypted file-system is
on the **third partition** of a a NVMe M.2 SSD known as :file:`/dev/nvme0n1`.

Thus my device to un-encrypt is :file:`/dev/nvme0n1p3`.

LUKS partitions have eight rewritable key-slots, each one can hold a password to
un-encrypt the partition.

Display the already used slots in the LUKS header information::

    $ sudo cryptsetup luksDump /dev/nvme0n1p3


If you only used one password to decrypt your disk, it is usually stored in slot
0 and slot 1 to 7 are still unused. 

.. warning::

    Beware! if a previously used slot is overwritten, that password can no longer be
    used to decrypt your disk!


Backup you LUKS header
^^^^^^^^^^^^^^^^^^^^^^

Anything goes wrong, you might not be able to access the encrypted data again.
Backup your LUKS header in any case before modifying it::

    $ sudo cryptsetup luksHeaderBackup /dev/nvme0n1p3 \
        --header-backup-file /media/user/safe-storage/${HOSTNAME}-LUKS-header.backup-$(date -u +%Y-%m-%d_%H-%M-%S)

The backup is stored on :file:`/media/user/safe-storage/` a 
:doc:`../luks`.


Initialize your Yubikey
^^^^^^^^^^^^^^^^^^^^^^^

Initialize the Yubikey for HMAC-SHA1 challenge/response mode in slot 2::

    $ ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible



Enroll your Yubikey to a LUKS slot
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo yubikey-luks-enroll -d /dev/nvme0n1p3
    setting disk to /dev/nvme0n1p3.
    setting slot to 7.
    This script will utilize slot 7 on drive /dev/nvme0n1p3.  If this is not 
    what you intended, exit now!
    Adding yubikey to initrd
    Please enter the yubikey challenge password. This is the password that will 
    only work while your yubikey is installed in your computer: 
    ********
    Please enter the yubikey challenge password again: 
    ********
    Please provide an existing passphrase. This is NOT the passphrase you just 
    entered, this is the passphrase that you currently use to unlock your LUKS 
    encrypted drive: 
    ********


Enable at System Boot
^^^^^^^^^^^^^^^^^^^^^

Open the file :file:`/etc/crypttab` and change the line::

    nvme0n1p3_crypt UUID=baa9d1c2-3b57-440a-9148-52570dba9814 none luks,discard


as follows::

    nvme0n1p3_crypt UUID=baa9d1c2-3b57-440a-9148-52570dba9814 none luks,keyscript=/usr/share/yubikey-luks/ykluks-keyscript,discard


This will tell the boot process, that the script 
:file:`/usr/share/yubikey-luks/ykluks-keyscript` needs to be called, which in 
turn will send the password typed by the user as challenge to the Yubikey and 
send the response from the Yubikey to LUKS to decrypt the disk.

Save and close the file, then update the initial RAM disk::

    $  sudo update-initramfs -u


Enable at Suspend/Resume
^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ systemctl enable yubikey-luks-suspend.service


References
----------

 * `yubikey-luks README <https://github.com/cornelinux/yubikey-luks/blob/master/README.md>`_
 * `Two factor authentication with Yubikey for harddisk encryption with LUKS <https://www.howtoforge.com/ubuntu-two-factor-authentication-with-yubikey-for-harddisk-encryption-with-luks>`_
