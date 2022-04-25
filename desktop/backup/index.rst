Backup
======

This is how to setup a backup **client** on a personal computer. For a how-to
to backup a server see :doc:`server backup </server/backup/index>`.

.. contents::
    :depth: 1
    :local:
    :backlinks: top

.. toctree::
   :maxdepth: 1

   borgmatic-system-backup
   borgmatic-user-backup

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

User and System Data
^^^^^^^^^^^^^^^^^^^^

Separate independent backups for user data and system configuration are made.

This ensures that ...

 * System configuration data backups are made anytime the system is powered on.
 * System administrators don't have access to user data backups.
 * User data backups are only made when a user is actively working on the
   system.
 * Encrypted home directories are only backed up when its user is logged in.
 * Users don't have access to system configuration backups.
 * Multiple users on a system can't access each others backup data.


Scheduling
^^^^^^^^^^

Backups can be made several times a day.

By using systemd-timers instead of cron-jobs, the Ubuntu Desktop system does
not need to be running at a specific time.

If the system is running on AC power and connected to a network either by
Ethernet cable or Wi-Fi a fresh backup is made a few minutes after startup and
at any desired interval after that. In the case of user data backups, whenever
the user has logged in.

In any other case the backup will made the next time all these conditions are
met.

If the system was running on battery or not connected trough a unmetered
network, it will try again the next time.


Retention
^^^^^^^^^

For how long is are backup archives stored:

 * All backups of the last 24 hours
 * Last backup of the day for 7 days
 * Last backup of the week for 4 weeks
 * Last backup of the month for 6 months
 * Last backup of the year for 2 years


Encryption
^^^^^^^^^^

Backup data is client-side encrypted and uses two-factor authentication.
This ensures that ...

 * Backup data can be moved and stored anywhere (i.e on untrusted cloud
   storage);
 * In order to access the backup data, a user must know the password AND needs
   to have the key-file in his possession;

On modern Intel/AMD 64-bit CPUs **BLAKE2b-256** is recommended over
**SHA-256**.


Prerequisites
-------------

 * Its assumed a working :doc:`/NAS/borg-backup-server` has been prepared to
   receive the backup data.
 * Your personal computer is setup to
   :doc:`send out mails on its own </desktop/postfix-null>`.


Installation
------------


Ubuntu 20.04 (focal) or later
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As of the time of this writing (May 2020), Ubuntu 20.04 LTS has both packages
in fairly up-to-date versions:

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
