.. image:: MariaDB-logo.*
    :alt: MariaDB Logo
    :align: right

Database Server
===============

`MariaDB <https://mariadb.org/en/>`_ is a community-developed fork of the `MySQL
<https://en.wikipedia.org/wiki/MySQL>`_ relational database management system
intended to remain free under the GNU GPL. 

Being a fork of a leading open source software system, it is notable for being
led by the original developers of MySQL, who forked it due to concerns over its
acquisition by Oracle.

.. contents:: 
  :local: 


Software Installation
---------------------

To get the `latest stable version <https://downloads.mariadb.org/>`_ directly
from the project, instead of the `older release <http://packages.ubuntu.com
/trusty-updates/mariadb-server>`_ in the Ubuntu software package repository, we
add `their repository 
<https://downloads.mariadb.org/mariadb/repositories/#mirror=digitalocean-ams>`_ to our system::

    $ sudo apt-get install software-properties-common
    $ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0xcbcb082a1bb943db
    $ sudo add-apt-repository \
        "deb http://ams2.mirrors.digitalocean.com/mariadb/repo/10.0/ubuntu `lsb_release -cs` main"
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

MariaDB runs as Upstart service **mysql**::

    $ sudo status mysql 
    mysql start/running, process 5430


To see the currently running server version and status::
    
    $ mysqladmin -p version
    Enter password: 
    mysqladmin  Ver 9.1 Distrib 10.0.19-MariaDB, for debian-linux-gnu on x86_64
    Copyright (c) 2000, 2015, Oracle, MariaDB Corporation Ab and others.

    Server version      10.0.19-MariaDB-1~trusty
    Protocol version    10
    Connection      Localhost via UNIX socket
    UNIX socket     /var/run/mysqld/mysqld.sock
    Uptime:         1 min 34 sec

    Threads: 1  Questions: 721  Slow queries: 0  Opens: 183  Flush tables: 1  Open tables: 38  Queries per second avg: 7.670


Configuration
-------------

The main configuration file is :file:`/etc/mysql/my.cnf` with additional files
loaded from :file:`/etc/mysql/conf.d/`.


Default Character Set
^^^^^^^^^^^^^^^^^^^^^

Use *UTF-8* instead of *Latin1* as default for the server and clients.

Open :file:`/etc/mysql/conf.d/mariadb.cnf` and uncomment the three UTF-8 lines.

.. code-block:: ini

    # MariaDB-specific config file.
    # Read by /etc/mysql/my.cnf

    [client]
    # Default is Latin1, if you need UTF-8 set this (also in server section)
    default-character-set = utf8 

    [mysqld]
    #
    # * Character sets
    # 
    # Default is Latin1, if you need UTF-8 set all this (also in client section)
    #
    #character-set-server  = utf8 
    #collation-server      = utf8_general_ci 
    character_set_server   = utf8 
    collation_server       = utf8_general_ci 


Binary Log
^^^^^^^^^^

The server can be told to record each and every MySQL transaction in a specially
formatted log-file called `the binary log 
<https://mariadb.com/kb/en/mariadb/overview-of-the-binary-log/>`_. The binary 
log is used for `database replication 
<https://mariadb.com/kb/en/mariadb/replication-overview/>`_ between servers but 
it is essentially also a backup tool, as it gives us the possibility to restore 
the exact state of a database table of any given point in the past by reversing 
all transactions found in the binary log.

To activate binary loggging edit the relevant part of the main configuration
file as follows:

.. code-block:: ini

    # The following can be used as easy to replay backup logs or for replication.
    # note: if you are setting up a replication slave, see README.Debian about
    #       other settings you may need to change.
    server-id           = 1
    log_bin             = /var/log/mysql/mysql-bin.log
    expire_logs_days    = 10
    max_binlog_size     = 100M
    #binlog_do_db       = include_database_name
    #binlog_ignore_db   = include_database_name
    binlog-format       = MIXED


Transport Layer Security (TLS)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Make sure the intermediate and root certificates of your CA are installed in
:file:`/etc/ssl/certs/`.

Create a certificate signing request(CSR) as described in :doc:`server-tls` and
sign it with the private :doc:`/ca/ca_cert`.

Create a certificate chain file with the signed server certificate and the
intermediate signing certificate as described in :doc:`server-tls` and install
that in :file:`/etc/ssl/certs/` too.

.. code-block:: ini

    # * Security Features
    #
    # Read the manual, too, if you want chroot!
    # chroot = /var/lib/mysql/
    #
    # For generating SSL certificates I recommend the OpenSSL GUI "tinyca".
    #
    ssl-ca      = /etc/ssl/certs/example.com_CA_root.crt
    ssl-cert    = /etc/ssl/certs/server.eample.com.chained.crt
    ssl-key     = /etc/ssl/private/server.example.com.key
    ssl-cipher  = kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3


.. warning::

    While the above procedure enables a sever to use TLS encrypted connections
    with clients. Be aware that this **DOES NOT ENFORCE** the use of encryption
    in any way!

    To make sure connections with specific clients (users @ hosts) are indeed
    encrypted, the database user profile must be edited with TLS specific
    `GRANT` options.


When done with the configuration changes, restart the MariaDB server::

    $ sudo restart mysql


Adding Users
^^^^^^^^^^^^

To add a local user on the server:

.. code-block:: sql

    CREATE USER 'pma'@'localhost' 
        IDENTIFIED BY PASSWORD '********';

    GRANT USAGE ON *.* TO 'pma'@'localhost' 

    GRANT SELECT, INSERT, UPDATE, DELETE ON `phpmyadmin`.* TO 'pma'@'localhost';

    FLUSH PRIVILEGES;


To add a remote IPv4 user, who can connect to the server from anywhere on our
local network:

.. code-block:: sql

    CREATE USER 'john'@'192.0.2.0/255.255.255.0' 
        IDENTIFIED BY PASSWORD '********';

    GRANT ALL PRIVILEGES ON *.* TO 'john'@'192.0.2.0/255.255.255.0' 
        REQUIRE ISSUER 'O=example.com, 
            OU=Certificate Authority, 
            CN=example.com Root Signing Authority'
        REQUIRE SUBJECT 'CN=John Doe'
        WITH GRANT OPTION;

    FLUSH PRIVILEGES;
    

Remote IPv6 user:

.. note::

    Netmask notation cannot be used for IPv6 addresses in the host part of an
    account name. Use wildcards?


.. code-block:: sql

    CREATE USER 'user'@'2001:db8::%'
        IDENTIFIED BY PASSWORD '********';

    GRANT ALL PRIVILEGES ON *.* TO 'user'@'2001:db8::158'
        REQUIRE ISSUER 'O=example.com, 
            OU=Certificate Authority, 
            CN=example.com Root Signing Authority'
        REQUIRE SUBJECT 'CN=John Doe'
        WITH GRANT OPTION;

    FLUSH PRIVILEGES;


On the client side in the users :file:`~/.my.cnf` configuration file:

.. code-block:: ini

    [client]

    # Default is Latin1, if you need UTF-8 set this (also in server section)
    default-character-set = utf8 

    # Transport Layer Security (TLS)
    ssl-ca      = /etc/ssl/certs/example.com_CA_root.crt
    ssl-cert    = ~/.ssl/certs/john@eample.com.chained.crt
    ssl-key     = ~/.ssl/private/john@example.com.key
    ssl-cipher  = kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3
    ssl-verify-server-cert 

    # Default connection
    host        = server.example.com
    user        = john
    password



Web-based Administration
------------------------

.. image:: phpMyAdmin-logo.*
    :alt: phpMyAdmin Logo
    :align: right

`phpMyAdmin <http://www.phpmyadmin.net/>`_ is a free software tool written in
PHP, intended to handle the administration of MySQL over the Web. phpMyAdmin
supports a wide range of operations on MySQL, MariaDB and Drizzle. Frequently
used operations (managing databases, tables, columns, relations, indexes, users,
permissions, etc) can be performed via the user interface, while you still have
the ability to directly execute any SQL statement.


Download and Install
^^^^^^^^^^^^^^^^^^^^

Due to their frequent updates, its easier to clone their STABLE branch from
GitHub, instead of download, unpacking and installing packages, along with
moving configuration files around.

::

    $ cd /var/www/server/public_html/
    $ sudo -u www-data -s
    $ git clone --branch STABLE --depth=1 git://github.com/phpmyadmin/phpmyadmin.git
    $ cd phpmyadmin

The ``git clone`` command creates a new sub-directory on the local system and
fills it with the contents of a remote repository.

Where:
 * ``--branch STABLE`` refers to the STBALE branch of their GitHub repository;
 * ``--depth=1`` selects only latest changes, without fetching the whole commit history.


Configuration
^^^^^^^^^^^^^

Create a configuration-setup directory with write-access to everybody::

    $ mkdir /var/www/server/public_html/phpmyadmin/config
    $ chmod o+rw /var/www/server/public_html/phpmyadmin/config

Now point your browser to `<https://server.lan/phpmyadmin/setup/>`_. A
configuration file will be created where you make the necessary settings.

When done save the configuration and move the created configuration file to the
phpmyadmin root directory, remove write-access and delete the :file:`config` 
subdirectory::

    $ mv /var/www/server/public_html/phpmyadmin/config/config/config.inc.php \
        /var/www/server/public_html/phpmyadmin/
    $ chmod o-rw /var/www/server/public_html/phpmyadmin/config.inc.php
    $ rm -rf /var/www/server/public_html/phpmyadmin/config
    $ exit


Upgrade
^^^^^^^

Download  and install the new version in its version specific directory::


    $ cd /var/www/server/public_html/phpmyadmin
    $ sudo -u www-data -s
    $ git remote update
    $ git pull
    $ exit

``git remote update`` fetches all updates for the current repository from GitHub.

``git checkout`` Updates files in the working tree to match the version in the index.

Done.
