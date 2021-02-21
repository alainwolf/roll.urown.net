Backup
======

This is how to setup a backup **client** on a server. For a how-to to
backup your personal desktop computer or notebook see
:doc:`desktop backup </desktop/backup/index>`.

.. contents::
    :depth: 1
    :local:
    :backlinks: top


Borg
----

.. image:: borg_insignia.*
    :alt: The Borg insignia, by Rick Sternbach from Star Trek: The Next Generation.
    :align: right


`BorgBackup <https://www.borgbackup.org/>`_ (short: Borg) is a deduplicating
backup program. Optionally, it supports compression and authenticated
encryption.

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
directory, as described in :doc:`mariadb/backup`.

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


Prerequisites
-------------

 * Its assumed a working :doc:`/NAS/borg-backup-server` has been prepared to
   receive the backup data.
 * Your personal computer is setup to
   :doc:`send out mails on its own </desktop/send-mail>`.


Installation
------------


Ubuntu 20.04 (focal) or later
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As of the time of this writing (May 2020), Ubuntu 20.04 LTS has both packages in
fairly up-to-date versions:

 * Borgbackup version 1.1.11 (latest)
 * Borgmatic version 1.5.1 (latest is 1.5.4)

To install using Ubuntu package manager::

    $ sudo apt install borgbackup borgmatic



Ubuntu 19.10 (eoan) or earlier
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Older versions of Ubuntu either don't have these packages in their repository,
or they are hopelessly outdated.

 * Borgbackup (xenial 1.0.2, 1.0.12), (bionic 1.1.5), (eoan 1.1.10)
 * Borgmatic (since Ubuntu 19.10, version 1.2.11)

You can use this also on newer systems if you want to make sure to have the
latest and greatest version. But remember that with this method, updates will
not be installed automatically.

Use Python PIP::

    $ sudo pip3 install --upgrade borgbackup borgmatic


This installs as a systemwide usable software in to :file:`/usr/local/bin/`,
usable by the system (root, systemd, cron etc.) and users alike.

To install updates just repeat the installation command above.


Backup
------



Restore
-------
