Borgmatic Setup
===============

Local Backup Configuration
--------------------------

Create directories::

    $ sudo mkdir -p /etc/borgmatic
    $ sudo mkdir -p /etc/borg/{keys,security,ssh} /var/lib//borg /var/cache/borg


Create SSH keys::

    $ sudo ssh-keygen -t ed25519 -f /etc/borg/ssh/id_ed25519 -N ''


Create the repository encryption passphrase::

    $ xkcdpass -n7


Generate borgmatic configuration files for the local backup destination::

    $ sudo generate-borgmatic-config --destination /etc/borgmatic/config.yaml

This generates a sample configuration file
:file:`/etc/borgmatic/config.yaml` which then can be customized.


What to Backup
^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :end-before: # Any paths matching these patterns are excluded


What NOT to Backup
^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # - /etc/borgmatic/patterns
    :end-before: # borgmatic_source_directory: /tmp/borgmatic


Where Backup Data is Stored
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # borgmatic_source_directory
    :end-before: # Repository storage options. See


How to Store the Backups
^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # borgmatic_source_directory: /tmp/borgmatic
    :end-before: # Retention policy for how many backups to keep


For How Long Backups are Stored
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # check: --save-space
    :end-before: # Consistency checks to run after backups


How Backup Data is Verified
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: prefix: '{hostname}-'
    :end-before: # Options for customizing borgmatic's own output and logging


What To Do Before and After
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # color: false
    :end-before: to execute when an exception



What To Do on Errors
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/borgmatic/config.yaml
    :language: yaml
    :start-after: # - echo "Finished checks."
    :end-before: List of one or more PostgreSQL databases



Remote Backup Configuration
---------------------------

Copy the configuration file :file:`config.yaml` to :file:`remonte-nas.yaml`::

    $ sudo cp /etc/borgmatic/config.yaml /etc/borgmatic/remote-nas.yaml

Change the repository to the remote location in the copied file:

.. code-block:: yaml

    # Paths to local or remote repositories (required). Tildes are expanded.
    # Multiple # repositories are backed up to in sequence. See ssh_command for
    # SSH options like # identity file or port.
     repositories:
        - ssh://borg@remote-nas.example.net:6883/volume1/BorgBackup/{hostname}


Repository Setup
----------------

The backup destination stores its data in Borg backup **repositories**.

These Borg backup repositories have to be properly initialized, before data can
be store in them.

Repositories should be encrypted, especially if a remote backup location is not
fully trusted. Encryption has be enabled at repository init time. It cannot be
changed later.

When using one of the `repokey` and `keyfile` encryption modes, the passphrase
AND the keyfile are both required to access the repository.


Local Network Location
^^^^^^^^^^^^^^^^^^^^^^

Initialize the the local network repository::

        $ sudo borgmatic init --config /etc/borgmatic/config.yaml \
            --encryption keyfile-blake2

The keyfile will be created and stored in the directory set by the configuration
setting **borg_keys_directory**. If you didn't change the example provided above,
you should find it in the :file:`/etc/borg/keys/` directory.


Remote Network Location
^^^^^^^^^^^^^^^^^^^^^^^

Initialize the the remote network repository::

        $ sudo borgmatic init --config /etc/borgmatic/remote-nas.yaml \
            --encryption keyfile-blake2


Safeguard Keys and Passwords
----------------------------

.. warning::

    To be able to access the backups you need:

    1. The **private SSH key** to access the storage server holding the repository.
    2. The Borg **keyfile** holding the key, which is used to encrypt the backup data in the repository.
    3. The Borg **repokey** password used to unlock the keyfile.

If one of these things are lost, you will no longer be able to access the backup
for restoration.

Store them in a safe place and make sure you can get to them, in case you have
to restore any data.
