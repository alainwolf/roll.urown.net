Software Installation
=====================

To get the `latest stable version <https://downloads.mariadb.org/>`_ directly
from the project, instead of the `older release <http://packages.ubuntu.com
/trusty-updates/mariadb-server>`_ in the Ubuntu software package repository, we
add `their repository
<https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-ams>`_
to our system::

    $ sudo apt-get install software-properties-common
    $ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0xcbcb082a1bb943db
    $ sudo add-apt-repository \
        "deb [arch=amd64] http://ams2.mirrors.digitalocean.com/mariadb/repo/10.2/ubuntu `lsb_release -cs` main"
    $ sudo apt-get update


Once key and repository have been added and the package database updated, it can
be installed as follows::

    $ sudo apt-get install mariadb-server


.. note::

    If Oracle MySQL server is already installed, it will be removed, but not
    without confirmation. MySQL configuration files will be preserved and used
    by MariaDB.


During the installation, you will be asked to set a password for the MySQL root
user. Create a password with Diceware and store it in KeePassX.

MariaDB runs as Systemd service **mariadb.service**::

    $ sudo systemctl status mariadb.service
    ● mariadb.service - MariaDB database server
       Loaded: loaded (/lib/systemd/system/mariadb.service; enabled; vendor preset: enabled)
      Drop-In: /etc/systemd/system/mariadb.service.d
               └─migrated-from-my.cnf-settings.conf
       Active: active (running) since Sat 2017-12-23 09:20:58 CET; 9min ago
     Main PID: 8212 (mysqld)
       Status: "Taking your SQL requests now..."
       CGroup: /system.slice/mariadb.service
               └─8212 /usr/sbin/mysqld


To see the currently running server version and status::

    $ mysqladmin -u root -p version
    Enter password:

    mysqladmin  Ver 9.1 Distrib 10.2.11-MariaDB, for debian-linux-gnu on x86_64
    Copyright (c) 2000, 2017, Oracle, MariaDB Corporation Ab and others.

    Server version      10.2.11-MariaDB-10.2.11+maria~xenial-log
    Protocol version    10
    Connection      Localhost via UNIX socket
    UNIX socket     /var/run/mysqld/mysqld.sock
    Uptime:         12 min 8 sec

    Threads: 8  Questions: 1  Slow queries: 0  Opens: 17  Flush tables: 1  Open tables: 11  Queries per second avg: 0.001

We stop the server for now before starting its :doc:`extensive configuration task <config>`::

  $ sudo systemctl stop mariadb.service

