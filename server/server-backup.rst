Backup
======

.. image:: Backupninja-logo.*
    :alt: backupninja Logo
    :align: right

Backups are done using 
`backupninja <https://labs.riseup.net/code/projects/backupninja>`_.

Backupninja is wrapper for numerous different backup solutions of which we use
`duplicity <http://duplicity.nongnu.org/>`_.

Duplicity is a enhanced combination of usual backup tools and tasks:

* Creates compressed archives of files like :command:`tar`
* Differential transfers to remote storage locations like :command:`rsync`
* File encryption with :command:`gpg`

Installation
------------

Backupninja is in the repository, additionally we install duplicity and a Python library for making SSH connections to the storage host::

    $ sudo apt-get install backupninja duplicity python-paramiko python-pip
    $ sudo pip install paramiko --upgrade


Configuration
--------------

The main configuration is stored in :download:`/etc/backupninja.conf 
<config/backupninja/backupninja.conf>`, while the different backup tasks are 
found in the directory :file:`/etc/backup.d`.

There is a helper application to aid in the configuratoion of all this::

    $ ninjahelper


hwinfo Issue
^^^^^^^^^^^^
There is currently an `issue <https://labs.riseup.net/code/issues/6388>`_ with the system-task of backupnja. The task is using the `hwinfo <http://www.linuxintro.org/wiki/Hwinfo>`_ program to collect information on hardware and disk partitions before backup. 

The hwinfo package is no longer available in Ubuntu. It has been removed due to incompatibilities with Ubuntu's current hardware management.

Disable the tasks **partitions** and **hardware** in 
:download:`/etc/backup.d/10.sys <config/backupninja/10.sys>`:

..  code-block:: ini
    :emphasize-lines: 2,4

    packages = yes
    partitions = no
    dosfdisk = yes
    hardware = no
    luksheaders = no
    lvm = yes


What how and where to backup
----------------------------

The file :download:`/etc/backup.d/90.dup <config/backupninja/90.dup>` has all 
the meat. 

Duplicity encrypts all backup-files before transferring to the remote storage:

..  code-block:: ini

    sign = no 
    password = ********

.. warning::
    Safe the password in a secure location! Without it you can't restore 
    anything!

Add more directories here when needed (e.g. after new software has been installed):

..  code-block:: ini

    [source]
    # files to include in the backup
    include = /var/spool/cron/crontabs
    include = /var/backups
    include = /etc
    include = /root
    include = /home
    include = /usr/local/*bin
    include = /var/lib/dpkg/status*
    include = /var/www


Leave the "files to exclude from the backup" as they are.

The backup destination needs a userprofile, which is able to login with its SSH
key automatically. The directory system must be existing and the userprofile
must have read/write access to it.

..  code-block:: ini

    [dest]
    incremental = yes
    increments = 30
    keep = 60
    keepincroffulls = 6

    destdir = /backup/Server/BackupNinja
    desthost = nas.lan
    destuser = server


Prepare the Backup Location
---------------------------

Since the backups will be carried out by the root user, the storage target needs
his public keys for password-less authentication::

    $ sudo -s -H
    $ for type in rsa ecdsa ed25519; do ssh-keygen -t $type; done
    $ ssh-copy-id server@nas.lan

Make sure you can login without password and that the target directory for the
backups exists and is writeable.

While still working as root::

    $ touch /tmp/testfile
    $ scp /tmp/testfile server@nas.lan:/backup/BackupNinja/
    $ ssh server@nas.lan rm /backup/BackupNinja/
    $ rm /tmp/testfile

Working with Backups
--------------------

Since backups are done by BackupNinja with Duplicity, we have to use the
duplicity commandline interface to access them. backupninja only helps with
the backup itself, not with anything else. Reference is the `duplicity man page 
<http://duplicity.nongnu.org/duplicity.1.html>`_.

Since all commands need the backup storage location in duplicity URL format, we
save that in an reusable environment variable::

    $ sudo -s -H
    $ export BACKUP_URL=sftp://server@nas.lan/backup/Server/BackupNinja
    $ export ARCHIVE_DIR=/var/cache/backupninja/duplicity


Backup Status
^^^^^^^^^^^^^

To check the overall status of our backups::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        collection-status ${BACKUP_URL}


Backup Catalog
^^^^^^^^^^^^^^

List the latest available versions of all backed up file.
We save the output in a text file :file:`backup-catalog.txt` for later search.

::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        list-current-files ${BACKUP_URL} \
        > ${HOME}/backup-catalog.txt

Search the created catalaog for a specific file::

    $ grep "owncloud/cron.php" backup-catalog.txt


Search for a version of a file backed up 30 days ago::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        list-current-files --time 30D  ${BACKUP_URL} \
            | grep "owncloud/cron.php"


Backup Verification
^^^^^^^^^^^^^^^^^^^

To compare single files or directory with what we have on backup::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        verify \
        --file-to-restore var/www/owncloud \
        ${BACKUP_URL} \
        var/www/owncloud


Restoring Files
^^^^^^^^^^^^^^^

To restore a single file (i.e. :file:`/var/www/owncloud/cron.php`)::

    $ cd /
    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        --file-to-restore var/www/owncloud/cron.php 
        ${BACKUP_URL} \
        var/www/owncloud/cron.php


Restore Databases
^^^^^^^^^^^^^^^^^

Backupninja exports the server MariaDB databases to a SQL file per database  in 
the directory :file:`/var/backups/mysql`. Thats where they are picked up by 
duplicity and backed up along with other files.

To restore a database to a given point in the past we nedd to use a combination 
of the commands introduced earlier to fetch the SQL dump file.

In the following example scencario, the upgrade of a Wordpress-Plugin reduced 
all our carefully carafted wordpress articles to gibberish. The upgrade happened 
on the 20th of February, but was only discovered a few days later.
The Wordpress database is called **wp_urown_net**.

1. Create a backup catalog of a point in time when the database content was 
still readable::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        list-current-files ${BACKUP_URL} \
        --time 02-19-2015  > ${HOME}/backup-catalog-2015-02-19.txt

2. Search the created backup catalog :file:`backup-catalog-2015-02-19.txt` for 
the database dump file :file:`wp_urown_net.sql` ::

    $ grep "wp_urown_net.sql" ${HOME}/backup-catalog-2015-02-19.txt
    Sat Feb 19 01:00:07 2015 var/backups/mysql/sqldump/wp_urown_net.sql

3. Restore the dump-file :file:`wp_urown_net.sql` to our home directory, but 
save it under the new name :file:`wp_urown_net-2015-02-19.sql`::

    $ duplicity --archive-dir ${ARCHIVE_DIR} \
        --file-to-restore var/backups/mysql/sqldump/wp_urown_net.sql \
        --time 02-19-2015 \
        ${BACKUP_URL} \
        ${HOME}/wp_urown_net-2015-02-19.sql

4. Take a look a the dump-file, to make sure it has the expected content::

    $ less ${HOME}/wp_urown_net-2015-02-19.sql

5. Restore the database from the dump-file. All tables in the database will be 
deleted and recreated with the content of the dump-file::

    $ mysql -u root -p wp_urown_net < ${HOME}/wp_urown_net-2015-02-19.sql
