System Configuration Backup
===========================

.. contents::
    :depth: 2
    :local:
    :backlinks: top

The system backup contains system-wide configuration files, keys, certificates
(i.e. SSH keys) and the datra about 3rd-party software package repositories and
installed packages. This includes:

 * The :file:`/etc` directory;
 * The :file:`/opt` directory;
 * The :file:`/usr/local` directory;
 * The :file:`/var/lib` directory;
 * A list of currently installed Ubuntu software packages (apt);
 * A list of currently installed Python packages (pip);


Borg Preparation
----------------

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


Mail Notification Script
------------------------

The :file:`/etc/borgmatic/notify.sh` shell script will send us a mail message,
whenever something goes wrong during backups, pruning or a repository check.

.. literalinclude:: /desktop/config-files/etc/borgmatic/notify.sh


Borgmatic Configuration
-----------------------

Generate a new borgmatic configuration file::

    $ sudo generate-borgmatic-config


This generates a sample configuration file :file:`/etc/borgmatic/config.yaml`.


What to Backup and Where
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :end-before: # Repository storage options


How to Store the Backups
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: borgmatic_source_directory:
    :end-before: # Retention policy for how many backups to keep


How Long to Keep Backups
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: archive_name_format:
    :end-before: # Shell commands, scripts, or integrations


What To Do on Errors
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: prefix: '{hostname}-'
    :end-before: # actions (if one of them is "create").


What To Do Before and After
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /desktop/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: - /etc/borgmatic/notify.sh


Secure and Validate Configuration
---------------------------------

To prevent potential shell injection or privilege escalation, do not forget to
set secure permissions on borgmatic configuration files (chmod 0600) and scripts
(chmod 0700) invoked by hooks.

::

    $ sudo chmod 0600 /etc/borgmatic/config.yml
    $ sudo chmod 0700 /etc/borgmatic/notify.sh
    $ sudo validate-borgmatic-config


Initialize Repository
---------------------

::

    $ sudo borgmatic init --encryption repokey



Interactive Backup Test
-----------------------


::

    $ sudo borgmatic --verbosity 1 --files



Systemd Service Files
---------------------

Service
^^^^^^^

Start a system backup once, but only if connected to a network and not running
on battery.

Systemd service file: :file:`/etc/systemd/system/borgmatic.service`:

.. literalinclude:: /desktop/config-files/etc/systemd/system/borgmatic.service
    :language: ini


Schedule
^^^^^^^^

Schedule the system backups once every day at a random time between midnight 
and 6 AM. or if a scheduled backup time was missed, due to the system powered
off or asleep. Don't wake up the system just for doing a backup.

Systemd timer file :file:`/etc/systemd/system/borgmatic.timer`:

.. literalinclude:: /desktop/config-files/etc/systemd/system/borgmatic.timer
    :language: ini



Activate
^^^^^^^^

::

    $ sudo systemctl enable --now borgmatic.timer
