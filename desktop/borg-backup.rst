Borg Backup
===========

.. contents::
    :depth: 2
    :local:
    :backlinks: top

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

This is how to setup a Borg **client** on a personal computer.


Considerations
--------------

User and System Data
^^^^^^^^^^^^^^^^^^^^

Separate independent backups for user data and system configuration are made.

This ensures that ...

 * System configuration data backups are made anytime the system is powered on.
 * System administrators don't have access to user data backups.
 * User data backups are only made when a user is actively working on the system.
 * Encrypted home directories are only backed up when its user is logged in.
 * Users don't have access to system configuration backups.
 * Multiple users on a system can't access each others backup data.


Scheduling
^^^^^^^^^^

Backups are made once a day.

By using anacron instead of cron, the Ubuntu Desktop system does not need to be
running at a specific time.

If the system is running on AC power and connected to a network either by
Ethernet cable or Wi-Fi a fresh backup is made a few minutes after midnight
every night.

In any other case the backup is made the next time these conditions are met. 

If the system was not powered on at midnight, the backup will run shortly after
the system has been started, or in case of user data backups, when the user has
logged in.

If the system was running on battery or not connected trough a unmetered
network, it will try again every hour.


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

 * Backup data can be moved and stored anywhere (i.e on untrusted cloud storage);
 * In order to access the backup data, a user must know the password AND needs
   to have the key-file in his possession;

On modern Intel/AMD 64-bit CPUs **BLAKE2b-256** is recommended over **SHA-256**.


Prerequisites
-------------

 * Its assumed a working :doc:`/NAS/borg-backup-server` has been prepared to
   receive the backup data.
 * Your personal computer is setup to :doc:`send out mails on its own<send-mail>`.
 * Your personal computer is setup to :doc:`run jobs periodically<anacron>`.


Installation
------------

Add the PPA, update and install::

	$ sudo add-apt-repository ppa:costamagnagianfranco/borgbackup
	$ sudo apt update
	$ sudo apt install borgbackup


System Configuration Backup
---------------------------

The system backup contains system-wide configuration files, keys, certificates
(i.e. SSH keys) and the datra about 3rd-party software package repositories and
installed packages. This includes:

 * The :file:`/etc` directory;
 * The :file:`/opt` directory;
 * The :file:`/usr/local` directory;
 * The :file:`/var/lib` directory;
 * A list of currently installed Ubuntu software packages (apt);
 * A list of currently installed Python packages (pip);


Configuration
^^^^^^^^^^^^^

Add configuration and keys directory::

	$ sudo mkdir -p /etc/borg/{keys,ssh}


Add cache and security directories::

	$ sudo mkdir -p /var/lib/borg/{cache,security}


Create SSH private and public key::

	$ sudo ssh-keygen -t ed25519 -C "BorgBackup@$(hostname)" -f /etc/borg/ssh/id_ed25519
	$ sudo chmod 0600 /etc/borg/ssh/id_ed25519
	$ sudo cat /etc/borg/ssh/id_ed25519.pub


Install the public key on the backup server::

	$ sudo ssh-copy-id -i /etc/borg/ssh/id_ed25519.pub borg-backup@nas.example.net


The backup server needs then to
`setup that public key <../NAS/borg-backup-server.html#client-setup>`_ for use
with this specific Borg client by defining a ssh forced command, that
points Borg to this clients repository.

Setup environment variables in :file:`/etc/borg/vars.sh`::

	#!/bin/bash
	export BORG_REPO='ssh://borg-backup@nas.example.net/volume1/BorgBackup/client.example.net'
	export BORG_PASSPHRASE='********'
	export BORG_RSH='ssh -i /etc/borg/ssh/id_ed25519 -o BatchMode=yes -o VerifyHostKeyDNS=yes'
	export BORG_BASE_DIR="/var/lib/borg"
	export BORG_CONFIG_DIR="/etc/borg"
	export BORG_CACHE_DIR="/var/lib/borg/cache"
	export BORG_SECURITY_DIR="/var/lib/borg/security"
	export BORG_KEYS_DIR="/etc/borg/keys"
	export BORG_KEY_FILE="/etc/borg/keys/client.example.net.key"


Change permissions (as it contains the repository password)::

	$ sudo chmod 0700 /etc/borg/vars.sh


Initialization
^^^^^^^^^^^^^^

Before a backup can be made a repository has to be initialized::

	$ sudo -i
	$ source /etc/borg/vars.sh
	$ borg init --encryption=keyfile-blake2


After the initialization a key file is found at
:file:`/etc/borg/keys/client.example.net.key`. Store this key-file in a safe
place. Without it the backup data will not be accessible.


The System Backup Script
^^^^^^^^^^^^^^^^^^^^^^^^

Let's create a script to be run every day:

.. literalinclude:: config-files/etc/cron.daily/borg-sys-backup


System Backup Schedule
^^^^^^^^^^^^^^^^^^^^^^

Since personal computers, unlike servers, are not running 24 hours a day, daily
system backups are scheduled to run by **anacron** instead of the usual **cron**.

Anacron will run the backup job once a day, whenever the computer is turned on
and not running on battery.

Save this in :file:`/etc/cron.daily/borg-sys-backup` and make it executable::

	$ chmod 0700 /etc/cron.daily/borg-sys-backup


User Data Backup
----------------

Add configuration and keys directory::

	$ mkdir -p ~/.config/borg/{keys,ssh,security}
	$ chmod -R 0700 ~/.config/borg


Add cache directory::

	$ mkdir -p ~/.cache/borg

Create SSH private and public keys for use with Borg::

	$ ssh-keygen -t ed25519 -f ~/.config/borg/ssh/id_ed25519
	$ chmod 0600 ~/.config/borg/ssh/id_ed25519
	$ cat ~/.config/borg/ssh/id_ed25519.pub


Install the public key on the backup server::

	$ ssh-copy-id -i ~/.config/borg/ssh/id_ed25519.pub borg-backup@nas.example.net


The backup server needs then to
`setup that public key <../NAS/borg-backup-server.html#client-setup>`_ for use
with this specific Borg client by defining a ssh forced command, that points
Borg to this clients repository.

Setup environment variables in :file:`~/.config/borg/vars.sh`::

	#!/bin/bash
	export BORG_REPO='ssh://borg-backup@nas.example.net/volume1/BorgBackup/${USER}'
	export BORG_PASSPHRASE='********'
	export BORG_RSH='ssh -i ~/.config/borg/ssh/id_ed25519'
	#export BORG_BASE_DIR="${HOME}"
	#export BORG_CONFIG_DIR="${HOME}/.config/borg"
	#export BORG_CACHE_DIR="${HOME}/.cache/borg"
	#export BORG_SECURITY_DIR="${HOME}/.config/borg/security"
	#export BORG_KEYS_DIR="${HOME}/.config/borg/keys"
	export BORG_KEY_FILE="${HOME}/.config/borg/keys/${USER}.key"


Change permissions (as it contains the repository password)::

	$ sudo chmod 0700 ~/.config/borg/vars.sh


Initialization
^^^^^^^^^^^^^^

Before a backup can be made a repository has to be initialized::

	$ source ~/.config/borg/vars.sh
	$ borg init --encryption=keyfile-blake2


After the initialization a key file is found at
:file:`~/.config/borg/keys/${USER}.key`.
Store this key-file in a save place.
Without it the backup data will not be accessible.


The User Data Backup Script
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Let's create a script to be run every day:

.. literalinclude:: config-files/borg/borg-backup


Save this in :file:`~/.config/borg/borg-backup` and make it executable::

	$ chmod 0700 ~/.config/borg/borg-backup


User Backup Schedule
^^^^^^^^^^^^^^^^^^^^

Place a symbolic link to the daily user backup script in to the daily directory
:file:`~/.anacron/cron.daily`::

	$ ln -s ~/.config/borg/borg-backup ~/.anacron/cron.daily/


Reference
---------

 * `Borg Documentation <https://borgbackup.readthedocs.io/en/stable/index.html>`_
