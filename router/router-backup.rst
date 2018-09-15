Router Backup
=============

The built in backup procedure is somewhat limited and has to be started 
manually from the webinterface. 
Goto `Sytem - Backup / Flash Firmware
<https://router.lan/cgi-bin/luci/admin/system/flashops/>`_

We d'like to have a daily fully automated backup, once a day. The compressed 
archive should be encrypted with the owners OpenPGP key and stored on a network
attached storage system.


Prerequisites
-------------

A network attached storage (NAS) device or other form of remote storage.

We assume you have already created a user profile called **router** and a
directory :file:`/volume1/backup/router/` with writing permissions for him on
a NAS called **nas.lan**.


Required Software
^^^^^^^^^^^^^^^^^

The backup script uses the following software packages:

 * gnupg - GNU Privacy Guard
 * gnupg-utils - Key management utilities.
 * gzip - compression utility
 * rsync - copy files to and from remote machines.
 * tar - utility to package a set of files in a archive file.


To install these, enter the following commands on your router::

    router$ opkg install gnupg gnupg-utils gzip rsync tar


SSH Keys
^^^^^^^^

To transfer the backups to our network attached storage, we need a user-
profile for the router on that system along with SSH private and public keys.

Enter the following  command on your router::

    router$ cd /root
    router$ mkdir -p .ssh
    router$ dropbearkey -t rsa -f .ssh/id_rsa
    router$ chmod 0700 /root/.ssh
    router$ chmod 0600 /root/.ssh/id_rsa

The command will print out the public key and fingerprint when done.

Unlike OpenSSH, Dropbear will not create public key files along with your 
private keys.

Instead one can display the public key anytime with the following command::

    $ dropbearkey -f .ssh/id_rsa -y

The following command sequence will copy the public key in the :file:`.ssh/` 
directory in the users home folder on the storage system, when used on your desktop::

    desktop$ ssh router.lan 'dropbearkey -f .ssh/id_rsa -y' > /tmp/router-backup.pub
    desktop$ scp /tmp/router-backup.pub router@nas.lan/var/service/home/.ssh/
    desktop$ ssh router@nas.lan 'cat ~/.ssh/router-backup.pub >> ~/.ssh/authorized_keys'


OpenPGP Keys
^^^^^^^^^^^^

The router needs the public PGP key of its owner to encrypt the backup 
archives. The following commands, used on your router will store them in its public 
keyring::

    router$ gpg --keyserver pgpkeys.urown.net --search-keys 0x0123456789ABCDEF
    router$ gpg --edit-key 0x0123456789ABCDEF
    gpg> trust
      1 = I don't know or won't say
      2 = I do NOT trust
      3 = I trust marginally
      4 = I trust fully
      5 = I trust ultimately
      m = back to the main menu

    Your decision? 5
    gpg> quit


What to Back Up
---------------

Gather information on the differences between a freshly installed or factory-reset OpenWRT system and your actual currently running system:

 * List of installed Packages
 * List of changed configuration files
 * Certificates and keys (SSH, TLS, OpenPGP)

By backing up the :file:`/etc/` and :file:`/root/` directories with the up-to-
date list of installed packages we might be on the save side.


Backup Script
-------------

This is our :download:`router-backup<files/bin/router-backup.sh>` script:

.. literalinclude:: files/bin/router-backup.sh
   :linenos:


Cron Job
--------

Setup a cron job on the router to run the backup script every night at 2 AM::

    router$ EDITOR=$(which nano) crontab -e


Insert the line as follows:

.. code-block:: bash
   :linenos:

    # Send any output by mail to `hostmaster@example.net'
    MAILTO=hostmaster@example.net
    #
    #min hour mday month wday cmd
    00   02   *    *     *    /root/openwrt-backup.sh

    # crontab and fstab must end with the last line a space or comment


Use CTRL+X and Y to save and exit.

Restart cron to re-read its configuration::

    router$ /etc/init.d/cron restart
