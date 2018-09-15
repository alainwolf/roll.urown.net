General Configuration
=====================

.. contents::
  :local:

The configuration presented here differs considerably from what software
packages normally install as default. This is in preparation for the task the
server has to fulfill.


Systemd Service
---------------

On Ubuntu systems MariaDB is started and controlled by systemd as service
:file:`mariadb.service` unit.

To start, stop or restart the server you can use the :file:`systemctl` command::

    $ systemctl start mariadb.service
    $ systemctl restart mariadb.service
    $ systemctl stop mariadb.service


The "reload" command is not supported on MariaDB services.

Status and error messages are written to systemd journal. To monitor the server
you can use the :file:`journalctl` command::

    $ journalctl -u mariadb.service
    $ journalctl -f -u mariadb.service


Service Customization
^^^^^^^^^^^^^^^^^^^^^

The service unit file is installed in :file:`/lib/systemd/system/mariab.service`.
Custom options should be applied by copying the original unit file to
:file:`/etc/systemd/system/`::

    $ sudo cp /lib/systemd/system/mariab.service /etc/systemd/system/
    $ sudo nano /etc/systemd/system/mariab.service
    $ systemctl dameon-reload
    $ systemctl restart mariadb.service


mysqld_safe
^^^^^^^^^^^

Before MariaDB version 10.1.8 the server was started by init-scripts or as
upstart service on most UNIX systems. These scripts also applied options found
in MySQL configuration files in the :file:`[mysqld_safe]` or :file:`[safe_mysqld]`
sections. These sections are no longer relevant.

See https://mariadb.com/kb/en/library/systemd/


Main Configuration
------------------

.. note::

    The convention used is that variable names are listed with '_' and options
    with '-'.

    Always use a '⁻' (dash) when setting options in configuration files or
    command-line options. Like :file:`key-buffer-size = 64K`

    Always use '_' (underscore) in SQL queries on the server.
    Like :code:`SHOW VARIABLES LIKE 'key_buffer_size';`


The main configuration file is
:download:`/etc/mysql/my.cnf</server/config-files/etc/mysql/my.cnf>`:


.. literalinclude:: /server/config-files/etc/mysql/my.cnf
    :language: ini


Notable settings
^^^^^^^^^^^^^^^^

 * **skip-name-resolve** is set to **ON**, as our DNS server will get its data
   form its database, and we don't want to to create a chicken and egg problem
   here.

 * **bind-address** is set to listening on all interfaces. As we need network
   access for the replication with other servers. Unfortunately you can set only
   one interface (usually localhost) or all of them. Since we need localhost AND
   external access, as not all our clients can use UNIX sockets, we need to open
   up all of them. This means we will have to manage the access rights of our
   database server users extra carefully and we need our firewall to block
   unwanted remote access. More on this later.

We don't change the :file:`debian.cnf` and :file:`debian-start` files.

Additional files are then loaded from :file:`/etc/mysql/conf.d/` and
:file:`/etc/mysql/mariadb.conf.d/`.

The idea here is to remain compatible with Oracle MySQL server.

Configuration settings compatible with both products should be stored in
:file:`/etc/mysql/conf.d/`, while settings which only work on MariaDB should be
saved in :file:`/etc/mysql/mariadb.conf.d/`. The file
:file:`/etc/mysql/conf.d/mariadb.cnf` will load these, but only for MariaDB
products compatible.


Character Sets
^^^^^^^^^^^^^^

Use *UTF-8* instead of *Latin1* as default for the server and clients.

Open :file:`/etc/mysql/conf.d/mariadb.cnf` and uncomment the three UTF-8 lines.

.. literalinclude:: /server/config-files/etc/mysql//my.cnf
    :language: ini
    :lines: 10-15,22,43-48




When done with the configuration changes, restart the MariaDB server::

    $ sudo systemctl restart mariadb.service

