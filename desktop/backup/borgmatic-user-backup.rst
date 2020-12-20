User Data Backup
================

.. contents::
    :depth: 2
    :local:
    :backlinks: top

The user data backup basically consists of the users home directory, with some
exeptions.


Borg Preparation
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


Mail Notification Script
------------------------

The :file:`/.config/borgmatic/notify.sh` shell script will send us a mail message,
whenever something goes wrong during backups, pruning or a repository check.

.. literalinclude:: /desktop/config-files/etc/borgmatic/notify.sh


Borgmatic Configuration
-----------------------

Generate a new borgmatic configuration file::

    $ generate-borgmatic-config -d ~/.config/borgmatic/config.yaml

This generates a sample configuration file
:file:`/home/user/.config/borgmatic/config.yaml`.


What to Backup and Where
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/borgmatic/config.yaml
    :language: yaml
    :end-before: # Repository storage options


How to Store the Backups
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/borgmatic/config.yaml
    :language: yaml
    :start-after: - .nobackup
    :end-before: # Retention policy for how many backups to keep


How Long to Keep Backups
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/borgmatic/config.yaml
    :language: yaml
    :start-after: archive_name_format:
    :end-before: # Shell commands, scripts, or integrations


What To Do on Errors
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/borgmatic/config.yaml
    :language: yaml
    :start-after: prefix: '{user}-{hostname}-'
    :end-before: # List of one or more shell commands or scripts to execute before running all


What To Do Before and After
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/borgmatic/config.yaml
    :language: yaml
    :start-after: - ~/.config/borgmatic/notify.sh


Secure and Validate Configuration
---------------------------------

To prevent potential shell injection or privilege escalation, do not forget to
set secure permissions on borgmatic configuration files (chmod 0600) and scripts
(chmod 0700) invoked by hooks.

::

    $ chmod 0600 ~/.config/borgmatic/config.yml
    $ chmod 0700 ~/.config/borgmatic/notify.sh
    $ validate-borgmatic-config


Initialize Repository
---------------------

::

    $ borgmatic init --encryption keyfile-blake2


Key Files and Passwords
^^^^^^^^^^^^^^^^^^^^^^^

After the initialization a key file is found at
:file:`~/.config/borg/keys/${USER}.key`.

.. warning::

    Without the repository key-file, the repository password and the SSH private
    keys, your backup data will not be accessible any more.

    Store these files and passwords in a save place!


Interactive Backup Test
-----------------------


::

    $ borgmatic --verbosity 1 --files



Systemd Service Files
---------------------

Service
^^^^^^^

Start a system backup once, but only if connected to a network and not running
on battery.

Systemd service file: :file:`~/.config/systemd/user/borgmatic.service`:

.. literalinclude:: /desktop/config-files/systemd/user/borgmatic.service
    :language: ini


Schedule
^^^^^^^^

Schedule the system backups once every day at a random time between midnight
and 6 AM. or if a scheduled backup time was missed, due to the system powered
off or asleep. Don't wake up the system just for doing a backup.

Systemd timer file :file:`~/.config/systemd/user/borgmatic.timer`:

.. literalinclude:: /desktop/config-files/systemd/user/borgmatic.timer
    :language: ini


Activate
^^^^^^^^

::

    $ systemctl --user enable --now borgmatic.timer


Checking Backups
----------------

Checking Logs
^^^^^^^^^^^^^

Borgmatic logs to systemd journal::

    $ journalctrl --user -t borgmatic


Listing Archives
^^^^^^^^^^^^^^^^

::

    $ borgmatic list


Archive Information
^^^^^^^^^^^^^^^^^^^

::

    $ borgmatic info --archive latest


Testing
^^^^^^^

TBD.


Restoring Files
---------------


Mounting Backup Archives
^^^^^^^^^^^^^^^^^^^^^^^^

The easiest way to access the backed-up files in the archive, is by mounting it
as a file-system::

    $ sudo mkdir -p /media/${USER}/Borg-Backup
    $ sudo chown ${USER} /media/${USER}/Borg-Backup
    $ borgmatic mount --mount-point /media/${USER}/Borg-Backup


The files in the backup archives should now be accessible in the Nautilus file
manager, as "Borg-Backup" like an external drive.

To mount a specific archive::

    $ borgmatic mount --archive ${USER}-${HOSTNAME}-2020-12-07T08:06:20 \
        --mount-point /media/${USER}/Borg-Backup


After your are done inspecting or restoring::

    $ borgmatic umount --mount-point /media/${USER}/Borg-Backup
    $ rmdir /media/${USER}/Borg-Backup

