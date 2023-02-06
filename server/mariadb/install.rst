Software Installation
=====================

Get the `latest stable version <https://downloads.mariadb.org/>`_ directly
from the project, instead of the
`older release <https://packages.ubuntu.com/search?suite=default&section=all&arch=any&keywords=mariadb-server&searchon=names>`_
in the Ubuntu software package repository, we add
`their own repository <https://mariadb.org/download/>`_ to your system.

Get the release key::

    $ curl --silent https://mariadb.org/mariadb_release_signing_key.asc | gpg --dearmor | \
        sudo tee /etc/apt/keyrings/mariadb.gpg > /dev/null

Add the software package source::

    $ DIST=$( lsb_release -sc )

::

    # /etc/apt/sources.list.d/mariadb.sources
    Types: deb deb-src
    URIs: https://mirror.mva-n.net/mariadb/repo/10.10/ubuntu
    Suites: jammy
    Components: main
    Arch: amd64
    Signed-By: /etc/apt/keyrings/mariadb.gpg


Update the software repository cache::

    $ sudo apt update


Once key and repository have been added and the package database updated, it can
be installed as follows::

    $ sudo apt install mariadb-server


.. note::

    If Oracle MySQL server is already installed, it will be removed, but not
    without confirmation. MySQL configuration files will be preserved and used
    by MariaDB.

MariaDB runs as Systemd service **mariadb.service**. It's not started after
Installation::

    $ systemctl status mariadb.service
    ○ mariadb.service - MariaDB 10.10.2 database server
        Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
        Drop-In: /etc/systemd/system/mariadb.service.d
                └─migrated-from-my.cnf-settings.conf
        Active: inactive (dead)
        Docs: man:mariadbd(8)
                https://mariadb.com/kb/en/library/systemd/

We therefore can begin with its :doc:`extensive configuration task <config>`::
