Borg Backup Server
==================

`BorgBackup <https://www.borgbackup.org/>`_ (short: Borg) is a deduplicating
backup program. Optionally, it supports compression and authenticated
encryption.

The main goal of Borg is to provide an efficient and secure way to backup data.
The data deduplication technique used makes Borg suitable for daily backups
since only changes are stored. The authenticated encryption technique makes it
suitable for backups to not fully trusted targets.

This is how to setup a Borg Backup **Server** on a Synology DiskStation, so it
can be used by :doc:`Borg Backup clients</desktop/borg-backup>` as backup
storage location.


Prerequisites
-------------

A Synology Software Package for `BorgBackup <https://www.borgbackup.org/>`_ is
available from the third-party source
`SynoCommunity <https://synocommunity.com/>`_

#. Login to DSM as administrator with your web browser.
#. Open the **Package Center** app.
#. Click on the **Settings** button.
#. In the **General** tab, set the **Trust Level** to **Any publisher**.
#. Click on the **Package Sources** tab.
#. Click the **Add** button.
#. Add a Name like **SynoCommunity** and the Location
   :code:`https://packages.synocommunity.com/`
#. Click the **OK** button.

After successful validation, a new section **Community** is available on the
available packages list.


Installation
------------

#. Login to DSM as administrator with your web browser.
#. Open the **Package Center** app.
#. Find the **Borg** package in the **Community** section.
#. Click the **Install** button.



Configuration
-------------

Login into DSM with your administration user and open the "control panel" app.

Create a group called *borg-backup*

Create a user called *borg-backup*

Create a shared folder *BorgBackup*

Allow "full control" for *borg-backup* user and group to the shared folder.

Open a SSH terminal session with the root user::

	$ ssh root@nas.lan


Create the directory for SSH public keys in the "borg-backup" home folder and
adjust permissions to allow password-less logins::

	$ mkdir -p /var/services/homes/borg-backup/.ssh
	$ touch /var/services/homes/borg-backup/.ssh/authorized_keys
	$ chown -R borg-backup:borg-backup /var/services/homes/borg-backup
	$ chmod 0700 /var/services/homes/borg-backup
	$ chmod 0700 /var/services/homes/borg-backup/.ssh
	$ chmod 0600 /var/services/homes/borg-backup/.ssh/*


Client Setup
------------

After SSH public keys are obtained from BorgBackup clients, they need to be
setup using ssh forced commands to point to this clients repository as follows::

	command="/usr/local/bin/borg serve --restrict-to-path /volume1/BorgBackup/client.example.net" ssh-ed25519 AAAAC3...

This way any client-connection authenticated with this SSH key is only allowed
to issue the borg server command.
:code:`/usr/local/bin/borg serve --restrict-to-path /volume1/BorgBackup/client.example.net`
and nothing else.


Reference
---------

 * `BorgBackup Documentation <https://borgbackup.readthedocs.io/en/stable/index.html>`_

