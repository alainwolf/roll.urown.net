Installation
============

Python Package Installer (PIP)
------------------------------

Borg Prerequisites
^^^^^^^^^^^^^^^^^^

See the `Borg installation documentation
<https://borgbackup.readthedocs.io/en/stable/installation.html#dependencies>`_::

    $ sudo apt install build-essential python3-dev python3-pip \
        libacl1 libacl1-dev libssl-dev liblz4-dev libzstd-dev libxxhash-dev


Borg Installation
^^^^^^^^^^^^^^^^^

Install Borg using PIP::

    $ sudo pip install --upgrade pip
    $ sudo pip setuptools wheel pkgconfig
    $ sudo pip install borgbackup

This installs as a system-wide usable software in to :file:`/usr/local/bin/`,
usable by the system (root, systemd, cron etc.) and users alike.


Borgmatic Installation
^^^^^^^^^^^^^^^^^^^^^^

Install Borgmatic using PIPx::

    $ sudo apt install pipx
    $ sudo pipx ensurepath
    $ sudo pipx install borgmatic

To install updates just repeat the installation command above.


Installing Updates
------------------

Make sure you read any "Important notes" in the BorgBackup documentation:
`<https://borgbackup.readthedocs.io/en/stable/changes.html>`_:


Upgrade Using PIP
^^^^^^^^^^^^^^^^^

To upgrade Borg and Borgmatic to a new version later, run the following::

    $ sudo pip install --upgrade pip setuptools wheel pkgconfig
    $ sudo pip install --upgrade borgbackup borgmatic


After Updating
^^^^^^^^^^^^^^

After installing software updates, you should verify that your configurations
are still valid::

    $ sudo borgmatic config validate -c /etc/borgmatic/local-nas.yaml
    $ sudo borgmatic config validate -c /etc/borgmatic/remote-nas.yaml


Also check repositories:

.. note::

    This might take some time.

::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml check
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml check


In case of errors, repair::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml check --repair
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml check --repair


Again the `BorgBackup documentation
<https://borgbackup.readthedocs.io/en/stable/changes.html#change-log>`_
might suggest some things to do, after software upgrades::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml \
        borg compact --cleanup-commits
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml \
        borg compact --cleanup-commits


Ubuntu Software Packages
------------------------

As of the time of this writing (August 2023), Ubuntu 22.04.2 LTS has outdated
versions of its software packages:

 * Borgbackup version 1.2.0 (latest is 1.2.4)
 * Borgmatic version 1.5.20 (latest is 1.8.1)

To install using the Ubuntu package manager::

    $ sudo apt install borgbackup borgmatic

References
----------

* `<https://borgbackup.readthedocs.io/en/stable/installation.html>`_
* `<https://torsion.org/borgmatic/docs/how-to/set-up-backups/>`_
