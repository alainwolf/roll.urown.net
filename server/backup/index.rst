Backup
======

This is how to setup a backup **client** on a server. For a how-to to
backup your personal desktop computer or notebook see
:doc:`desktop backup </desktop/backup/index>`.

.. contents::
    :depth: 2
    :local:
    :backlinks: top


Borg
----

.. image:: borg_insignia.*
    :alt: The Borg insignia, by Rick Sternbach from Star Trek: The Next Generation.
    :align: right


`BorgBackup <https://www.borgbackup.org/>`_ (short: Borg) is a
:term:`deduplicating <Data deduplication>` backup program. Optionally, it
supports compression and authenticated encryption.

The main goal of Borg is to provide an efficient and secure way to backup data.
The data deduplication technique used makes Borg suitable for daily backups
since only changes are stored. The authenticated encryption technique makes it
suitable for backups to not fully trusted targets.


Borgmatic
---------

.. image:: borgmatic-logo.*
    :alt: borgmatic logo
    :align: right


`borgmatic <https://torsion.org/borgmatic/>`_ is a simple, configuration-driven
frontend to automate borg backup on servers and workstations. Protect your
files with client-side encryption. Backup your databases too. Monitor it all
with integrated third-party services.


Considerations
--------------

Backup Storage Destinations
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Backup data is stored on two different storage servers. One is on the local
network and another one on at a remote location.

The local backup can be used to restore data that has been lost on the server
(e.g. user error, server storage issues). The remote location backup is kept in
case the local backup storage is unavailable to, in case of fire or theft.

The Borg developers recommend to use distinct backup tasks for each destination,
as opposed to just copy the backed up data from one destination to the other.

In this document the storage servers will be called as `local-nas.example.net`
and `remote-nas.example.net`.


Files and Directories
^^^^^^^^^^^^^^^^^^^^^

The following :

 * :file:`/etc`       - System configuration
 * :file:`/home`      - Users home directories
 * :file:`/root`      - Systemd administrators home directory
 * :file:`/usr/local` - Locally installed software and scripts
 * :file:`/var`       - Data

* All MariaDB (MySQL) Databases.
* A list of installed packages and software.


Excluded Files and Directories
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following files and directories are excluded from backups:

 * :file:`**/.aMule`
 * :file:`**/.beagle`
 * :file:`**/.cache`
 * :file:`**/Trash`
 * :file:`**/.thumbnails`
 * :file:`**/.Trash`
 * :file:`**/downloads`
 * :file:`**/Downloads`
 * :file:`**/gtk-gnutella-downloads`
 * :file:`**/cache`
 * :file:`/var/lib/bitcoind`
 * :file:`/var/lib/deluge/downloads`
 * :file:`/var/lib/lxcfs`
 * :file:`/var/lib/mysql`
 * :file:`/var/lib/sks`
 * :file:`/var/lib/sks*`
 * :file:`/var/lib/transmission-daemon`
 * :file:`/var/www/mirrors`
 * :file:`/var/lib/clamav`


MariaDB Database Backups
^^^^^^^^^^^^^^^^^^^^^^^^

For database servers like MariaDB, its not possible to just copy the files out
of the data directory of the database sever.

MariaDB physical backups are created in the :file:`/var/backups/mariadb/`
directory, as described in :doc:`/server/mariadb/backup`.

So here we make sure that the :file:`/var/backups/mariadb/` directory is
**included** and the :file:`/var/lib/mysql/` directory is **excluded** in our
Borgmatic configuration.

We then let :command:`borgmatic` run a :command:`mariabackup` full backup as
pre-backup task, and let it empty the directory afterwards.


Installed Packages
^^^^^^^^^^^^^^^^^^

 * :file:`apt` software package sources.
 * List of installed packages.
 * List of :file:`pip` installed Python packages.



Scheduling
^^^^^^^^^^

Backups are made every six hours (four times a day).

Scheduling is done by systemd-timers, which has more flexiblity then classic
cron-jobs.


Retention
^^^^^^^^^

For how long is are backup archives stored?

 * All backups of the last 24 hours
 * Last backup of the day for 7 days
 * Last backup of the week for 4 weeks
 * Last backup of the month for 6 months
 * Last backup of the year for 2 years


Encryption
^^^^^^^^^^

Backup data is client-side encrypted and uses two-factor authentication.

This ensures that ...

 * Backup data can be moved and stored anywhere (i.e on untrusted cloud storage);
 * In order to access the backup data, a user must know the password AND needs
   to have the key-file in his possession;

On modern 64-bit CPUs :term:`BLAKE2b-256` is recommended over :term:`SHA-256`.

To create a safe password for the encryption key::

    $ xkcdpass -n7
    rasping voucher murkiness cosigner tricking armful suitor


Prerequisites
-------------

 * Its assumed a working :doc:`/NAS/borg-backup-server` has been prepared to
   receive the backup data.
 * Your personal computer is setup to
   :doc:`send out mails on its own </desktop/send-mail>`.


.. toctree::
  :maxdepth: 1

  install
  borgmatic-setup
  borgmatic-backup
  borgmatic-restore
