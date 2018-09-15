Managing Users
==============

.. warning::

	By default MariaDB clients and servers don't use encryption while
	communicating. Make sure you either create local users or remote users who
	connect trough a :doc:`/server/wireguard`.


.. contents::
  :local:


Adding Users
------------

Local Users
^^^^^^^^^^^

Local users can connect by using the UNIX socket :file:`/run/mysqld.sock` or by
connecting to the localhost IP address 127.0.0.1.

This is how a local user "john" is created:

.. code-block:: sql

    CREATE USER 'john'@'localhost'
        IDENTIFIED BY '********';


Remote Users
^^^^^^^^^^^^

.. warning::

	Note that, except for connections from encrypted tunnels and
	:doc:`/server/wireguard`, a TLS encrypted connections as well as valid and
	verified client certificates are mandatory here.


.. note::

	Since we set :code:`skip-name-resolve` to :code:`ON` in our server
	:doc:`config` we can not use host names here. Only IP addresses in numbers.


To add a remote IPv4 user, who can connect to the server from our local network:

.. code-block:: sql

    CREATE USER 'john'@'192.0.2.0/255.255.255.0'
        IDENTIFIED BY '********'
        REQUIRE X509;


To add a remote IPv6 user, who can connect to the server from our local network:

.. note::

    Netmask notation cannot be used for IPv6 addresses in the host part of an
    account name. Use wildcards instead.


.. code-block:: sql

    CREATE USER 'john'@'2001:db8:%'
        IDENTIFIED BY '********'
        REQUIRE X509;


VPN User
^^^^^^^^

Since we have setup a :doc:`/server/wireguard` we know that connections to
server coming from the :code:`10.195.171.0/24` network are safely encrypted.

.. code-block:: sql

    CREATE USER 'john'@'10.195.171.0/255.255.255.0'
        IDENTIFIED BY '********';

    CREATE USER 'john'@'fdc1:d89e:b128:6a04:%'
        IDENTIFIED BY '********';


List Users
^^^^^^^^^^

There is no specific command to work with already created user profiles. But
since the user profiles are stored in the :file:`mysql` database, we just send a
query that way:

.. code-block:: sql

	SELECT User, Host FROM mysql.user;
	+------------------+-----------+
	| User             | Host      |
	+------------------+-----------+
	| root             | 127.0.0.1 |
	| root             | ::1       |
	| debian-sys-maint | localhost |
	| root             | localhost |
	+------------------+-----------+
	4 rows in set (0.00 sec)


Creating Similar Profiles
^^^^^^^^^^^^^^^^^^^^^^^^^

Often we need create user-profiles which very similar attributes. Like same
login credentials, but allow access from a different location. That is where the
:code:`SHOW CREATE USER` command comes in handy:

.. code-block:: sql

    SHOW CREATE USER john@locahost;
	+---------------------------------------------------------------------------------------------------+
	| CREATE USER for john@localhost                                                                    |
	+---------------------------------------------------------------------------------------------------+
	| CREATE USER 'john'@'localhost' IDENTIFIED BY PASSWORD 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX' |
	+---------------------------------------------------------------------------------------------------+


Access Privileges
-----------------

No we have some user profiles who can connect to our server. But without
privileges can't see or do anything on the server.


Read-Only Access
^^^^^^^^^^^^^^^^

.. code-block:: sql

    -- Allow read-only access
    GRANT SELECT ON `johns_database`.* TO 'john'@'localhost';


Read and Write Access
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sql

    -- Allow read and write access
    GRANT SELECT, INSERT, UPDATE, DELETE ON `johns_database`.* TO 'john'@'localhost';


Management Access
^^^^^^^^^^^^^^^^^

.. code-block:: sql

    -- Allow administrative access
    -- Can create and delete tables, change structure of tables or delete the
    -- whole database.
    GRANT ALL PRIVILEGES ON *.* TO 'john'@'192.0.2.0/255.255.255.0'
        REQUIRE ISSUER 'O=example.net,
            OU=Certificate Authority,
            CN=example.net Root Signing Authority'
        REQUIRE SUBJECT 'CN=John Doe'


Administrative Access
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sql

    -- Allow full administrative access
    -- Can manage access right to the database, so can allow other users to access the database.
    GRANT ALL PRIVILEGES ON johns_database.* TO 'john'@'2001:db8::158'
        REQUIRE ISSUER 'O=example.net,
            OU=Certificate Authority,
            CN=example.net Root Signing Authority'
        REQUIRE SUBJECT 'CN=John Doe'
        WITH GRANT OPTION;


Displaying Access Rights
^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sql

	SHOW GRANTS FOR 'john'@'2001:db8::158';




Activating Changes
------------------

All changes made to the user database or access rights will not be active on the
server before explicitly activated.

.. code-block:: sql

    FLUSH PRIVILEGES;


Client Configuration
--------------------

On the client side in the users :file:`~/.my.cnf` configuration file:

.. code-block:: ini

    [client]

    # Default is Latin1, if you need UTF-8 set this (also in server section)
    default-character-set = utf8mb4

    # Transport Layer Security (TLS)
    ssl-ca      = /etc/ssl/certs/example.net_CA_root.crt
    ssl-cert    = ~/.ssl/certs/john@example.net.chained.crt
    ssl-key     = ~/.ssl/private/john@example.net.key
    ssl-cipher  = kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3
    ssl-verify-server-cert

    # Default connection
    host        = server.example.net
    user        = john
    password

References
----------

 * `MariaDB Account Management <https://mariadb.com/kb/en/library/account-management-sql-commands/>`_
