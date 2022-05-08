Installation
============

Ubuntu Software Packages
------------------------

As of the time of this writing (May 2022), Ubuntu 20.04 LTS has outdated
versions of its software packages:

 * Borgbackup version 1.1.15 (latest is 1.2.0)
 * Borgmatic version 1.5.1 (latest is 1.6.0)

To install using Ubuntu package manager::

    $ sudo apt install borgbackup borgmatic


Python Package Installer (PIP)
------------------------------

Borg Prerequisites
^^^^^^^^^^^^^^^^^^

See the `Borg installation documentation
<https://borgbackup.readthedocs.io/en/1.2-maint/installation.html#dependencies>`_::

    $ sudo apt-get install python3 python3-dev python3-pip python3-virtualenv \
    libacl1-dev libacl1 \
    libssl-dev \
    liblz4-dev libzstd-dev libxxhash-dev \
    build-essential \
    pkg-config python3-pkgconfig


Borg Installation
^^^^^^^^^^^^^^^^^

Install Borg using PIP::

    $ sudo pip install --upgrade pip setuptools wheel
    $ sudo pip install --upgrade pkgconfig
    $ sudo pip install --upgrade borgbackup

This installs as a systemwide usable software in to :file:`/usr/local/bin/`,
usable by the system (root, systemd, cron etc.) and users alike.


Borgmatic Installation
^^^^^^^^^^^^^^^^^^^^^^

Install Borgmatic using PIP::

    $ sudo pip install borgmatic

To install updates just repeat the installation command above.


Installing Updates
------------------

Make sure you read any "Important notes" at the Borgbackup documentation:
`<https://borgbackup.readthedocs.io/en/stable/changes.html>`_:


Upgrade Using PIP
^^^^^^^^^^^^^^^^^

To upgrade Borg and Borgmatic to a new version later, run the following::

    $ sudo pip install --upgrade borgbackup
    $ sudo pip install --upgrade borgmatic


After Updating
^^^^^^^^^^^^^^

After installing software updates, you should verify that your configurations
are still valid::

    $ sudo validate-borgmatic-config -c /etc/borgmatic/local-nas.yaml
    $ sudo validate-borgmatic-config -c /etc/borgmatic/remote-nas.yaml


Also check repositories:

.. note::

    This might take some time.

::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml check
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml check


In case of errors, repair::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml check --repair
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml check --repair


Again the `Borgbackup documentation
<https://borgbackup.readthedocs.io/en/stable/changes.html#change-log>`_
might suggest some things to do, after software upgrades::

    $ sudo borgmatic -c /etc/borgmatic/local-nas.yaml \
        borg compact --cleanup-commits
    $ sudo borgmatic -c /etc/borgmatic/remote-nas.yaml \
        borg compact --cleanup-commits


References
----------

* `<https://borgbackup.readthedocs.io/en/1.2-maint/installation.html>`_
* `<https://torsion.org/borgmatic/docs/how-to/set-up-backups/>`_
