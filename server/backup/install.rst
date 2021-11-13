Installation
------------

Ubuntu 20.04 (focal) or later
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As of the time of this writing (May 2020), Ubuntu 20.04 LTS has both packages in
fairly up-to-date versions:

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

