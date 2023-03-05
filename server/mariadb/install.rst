Software Installation
=====================

Get the `latest stable version <https://downloads.mariadb.org/>`_ directly
from the project, instead of the
`older release <https://packages.ubuntu.com/search?suite=default&section=all&arch=any&keywords=mariadb-server&searchon=names>`_
in the Ubuntu software package repository, we add
`their own repository <https://mariadb.org/download/>`_ to your system.

Get the release signing keys::

    $ curl --silent https://supplychain.mariadb.com/MariaDB-Server-GPG-KEY \
        | gpg --dearmor | \
        sudo tee /etc/apt/keyrings/MariaDB-Server.gpg > /dev/null

    $ curl --silent https://supplychain.mariadb.com/MariaDB-MaxScale-GPG-KEY \
        | gpg --dearmor | \
        sudo tee /etc/apt/keyrings/MariaDB-MaxScale.gpg > /dev/null

    $ curl --silent https://supplychain.mariadb.com/MariaDB-Enterprise-GPG-KEY \
        | gpg --dearmor | \
        sudo tee /etc/apt/keyrings/MariaDB-Enterprise.gpg > /dev/null


Create a source file:

 .. code-block:: bash
    :caption: /etc/apt/sources.list.d/mariadb.sources
    :name: mariadb.sources
    :linenos:

    # MariaDB Server
    # To use a different major version of the server, or to pin to a specific minor
    # version, change URI below.
    Types: deb
    URIs: https://dlm.mariadb.com/repo/mariadb-server/10.11/repo/ubuntu
    Suites: jammy
    Components: main
    Architectures: amd64 arm64
    Signed-By: /etc/apt/keyrings/MariaDB-Server.gpg

    # MariaDB MaxScale
    # To use the latest stable release of MaxScale, use "latest" as the version
    # To use the latest beta (or stable if no current beta) release of MaxScale, use
    # "beta" as the version
    Types: deb
    URIs: https://dlm.mariadb.com/repo/maxscale/latest/apt
    Suites: jammy
    Components: main
    Architectures: amd64 arm64
    Signed-By: /etc/apt/keyrings/MariaDB-MaxScale.gpg

    # MariaDB Tools
    # MariaDB Tools are a collection of advanced command-line tools.
    Types: deb
    URIs: http://downloads.mariadb.com/Tools/ubuntu
    Suites: jammy
    Components: main
    Architectures: amd64
    Signed-By: /etc/apt/keyrings/MariaDB-Enterprise.gpg

    # -*- mode: debsources; indent-tabs-mode: nil; tab-width: 4; -*-


Create a preferences file to give the packages from the MariaDB repositories
the highest priority, in order to avoid conflicts with packages from OS and
other repositories:

 .. code-block:: text
    :caption: /etc/apt/preferences.d/mariadb.pref
    :name: mariadb.pref
    :linenos:

    Package: *
    Pin: origin dlm.mariadb.com
    Pin-Priority: 1000


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

We therefore can begin with its :doc:`extensive configuration task <config>`.
