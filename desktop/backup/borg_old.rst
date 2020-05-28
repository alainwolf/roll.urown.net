:orphan:

Old Configuration
^^^^^^^^^^^^^^^^^

.. note::

    To be replaced!


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

Setup environment variables in :file:`/etc/borg/vars.sh`:

.. literalinclude:: /desktop/config-files/etc/borg/vars.sh


Change permissions (as it contains the repository password)::

    $ sudo chmod 0700 /etc/borg/vars.sh


Create a list of directories to exclude from backups and save them in the file
:file:`/etc/borg/exclude`:

.. literalinclude:: /desktop/config-files/etc/borg/exclude


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

.. literalinclude:: /desktop/config-files/etc/borg/borg-sys-backup


.. note::

    You can remove the ":file:`--verbose`" switch after some time. You then will
    only get a mail message, when something unexpected was happening.


Make it executable for root only::

    $ sudo chmod 0764 /etc/borg/borg-sys-backup


System Backup Schedule
^^^^^^^^^^^^^^^^^^^^^^

Since personal computers, unlike servers, are not running 24 hours a day, daily
system backups are scheduled to run by **anacron** instead of the usual **cron**.

Anacron will run the backup job once a day, whenever the computer is turned on
and not running on battery.

Link this this to :file:`/etc/borg/borg-sys-backup`::

    $ sudo ln -s /etc/borg/borg-sys-backup /etc/cron.daily/borg-sys-backup





Restore
-------

Show available archives in your repository::

    $ source ~/.config/borg/vars.sh
    $ borg info
    $ borg list


Mounting Borg Backup Repositories
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mount one of your available archives in your repository::

    $ source ~/.config/borg/vars.sh
    $ mkdir /tmp/borg-mount/
    $ borg mount \
        ${BORG_REPO}::${USER}-$(hostname)-2019-02-29T00:05:01 \
        /tmp/borg-mount/
    $ ls /tmp/borg-mount/


Reference
---------

 * `Borg Documentation <https://borgbackup.readthedocs.io/en/stable/index.html>`_
