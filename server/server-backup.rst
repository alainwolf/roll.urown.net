Backup
======

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

	$ sudo apt-get install backupninja duplicity python-paramiko

Configuration
--------------

There is a helper application to aid in the configuratoion of all this::

	$ ninjahelper

The main configuration is stored in :file:`/etc/backupninja.conf`, while the different backup tasks are found in the directory :file:`/etc/backup.d`.

hwinfo Issue
^^^^^^^^^^^^
There is currently an `issue <https://labs.riseup.net/code/issues/6388>`_ with the system-task of backupnja. The task is using the `hwinfo <http://www.linuxintro.org/wiki/Hwinfo>`_ program to collect information on hardware and disk partitions before backup. 

The hwinfo package is no longer available in Ubuntu. It has been removed due to incompatibilities with Ubuntu's current hardware management.

Disable the tasks **partitions** and **hardware** in 
:file:`/etc/backup.d/10.sys`::

	packages = yes
	partitions = no
	dosfdisk = yes
	hardware = no
	luksheaders = no
	lvm = yes

What how and where to backup
----------------------------

The file :file:`/etc/backup/d.90.dup` has all the meat. 

Duplicity encrypts all backup-files before transferring to the remote storage::

	sign = no 
	password = ********

.. warning::
	Safe the password in a secure location! Without it you can't restore anything!

Add more directories here when needed (e.g. after new software has been installed)::

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

The backup destination needs a userprofile, which is able to login with its SSH key automatically. The directory system must be existing and the userprofile must have read/write access to it.

::

	[dest]
	incremental = yes
	increments = 30
	keep = 60
	keepincroffulls = 6

	destdir = /backup/Cortez/BackupNinja2
	desthost = nas.lan
	destuser = cortez

