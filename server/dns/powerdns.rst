.. image:: PowerDNS-logo.*
    :alt: PowerDNS Logo
    :align: right

PowerDNS
========

.. contents:: \

`PowerDNS <https://www.powerdns.com/>`_ is a versatile nameserver which supports
a large number  of different backends ranging from simple zonefiles to
relational  databases and load balancing/failover algorithms.  PowerDNS tries to
emphasize speed and security.


Prerequisites
-------------


IP Addresses
^^^^^^^^^^^^

The server will need a dedicated private IPv4 address and global IPv6 address.
See :doc:`/server/network`.

Troughout this document we will use following IP Addresses for demonstration.

.. list-table:: IP Addresses
   :header-rows: 1

   * - Type
     - Host
     - IPv4
     - IPv6
   * - Master
     - dns01
     - 192.0.2.41
     - 2001:db8::41
   * - Slave
     - dns02
     - 192.0.2.42
     - 2001:db8::42

In the real world a DNS slave would be on entirely another subnet.

Firewall-Gateway
^^^^^^^^^^^^^^^^

The :doc:`/router/index` needs to forward incoming external IPv4 traffic on TCP
and UDP port  **53** to the private IPv4 address of this DNS server. IPv6
traffic on TCP and UDP port 53 to this servers IP address must be allowed to
pass the firewall.


Database
^^^^^^^^

:doc:`/server/mariadb/index` must be installed and running.


Domain Registration
^^^^^^^^^^^^^^^^^^^

You need to register your domain with one of the official DNS registrars. The
registrar must support **IPv6**, **DNSSEC** and allow you to define your own name servers.


Secondary Domain Name Servers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You will need a 3rd-Party providing you with secondary servers. The provider must
support **IPv6** records, **NOTIFY**, **AXFR** and **DNSSEC** on its servers.

Their DNS servers must be reachable over IPv6 and be able to receive DNS NOTIFY
messages and transfer zones from the master over IPv6.


Software Installation
---------------------

The PowerDNS server software is in the Ubuntu software package repository. But there is not always the latest version available.
If this is the case, you can use the PowerDNS repository, to get the latest version.

We install the authoritative server. (you need sudo/root permissions for these tasks)

Create the file :file:`/etc/apt/sources.list.d/pdns.list` with this content:

ATTENTION: Please visit: https://repo.powerdns.com/ and replace **ubuntu**, **focal** and **-auth-44** to fit your distribution.

::

    deb [arch=amd64] http://repo.powerdns.com/ubuntu focal-auth-44 main

And this to  :file:`/etc/apt/preferences.d/pdns`: Now you use the packages from the powerdns repository.

.. code-block:: shell

    Package: pdns-*
    Pin: origin repo.powerdns.com
    Pin-Priority: 600


and execute the following commands, to install the powerdns-server:

.. code-block:: shell

    curl https://repo.powerdns.com/FD380FBB-pub.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install pdns-server pdns-backend-mysql

for further information see: https://repo.powerdns.com/.

The following happens during installation:

    * The following configuration file are created:

        * :file:`/etc/powerdns/pdns.conf`.
        * :file:`/etc/powerdns/named.conf`.
        * :file:`/etc/powerdns/pdns.d/bind.conf`
        * :file:`/etc/default/pdns`.

    * A user and group *pdns* is created.
    * A Systemd service :file:`/lib/systemd/system/pdns.service` is created
      and started.


Systemd Service Dependencies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since we use MariaDB as database backend for PowerDNS, we want to ensure that
PowerDNS is always able to connect to the database server before running.

The Systemd services file for the PowerDNS server
:file:`/lib/systemd/system/pdns.service` is created as part of the software
package installation. The recommended method is to create a Systemd
override-file and not change anything in the provided service file, as it
would be lost on software package updates.

You can create a override file easily with the help of the
:command:`systemctl` command::

    $ sudo systemctl edit pdns.service

This will start your editor with an empty file, where you can add your own
custom Systemd service configuration options.

.. code-block:: ini

    [Unit]
    BindsTo=mariadb.service


The configuration statement :code:`After=mariadb.service` ensures that
:code:`mariadb.service` is fully started up before the :code:`pdns.service` is
started. It is already included in the service file installed by the software
package.

The line :code:`BindsTo=mariadb.service` ensures that if the Database
service is stopped, the PowerDNS server will be stopped too.

After you save and exit of the editor, the file will be saved as
:file:`/etc/systemd/system/pdns.service.d/override.conf` and Systemd will
reload its configuration::

    systemctl show pdns.service |grep -E "After=|BindsTo="

DNS Server Database
-------------------

All our DNS data will stored in a MariaDB database.


Remove BIND Backend
^^^^^^^^^^^^^^^^^^^

By default PowerDNS uses BIND style zone-files to store DNS data.

We need to remove the default "BIND backend". This is done simply by
deleting its configuration file.

::

    $ sudo rm /etc/powerdns/pdns.d/bind.conf


Database Server
^^^^^^^^^^^^^^^

The following setting needs to changed in
:download:`/etc/powerdns/pdns.d/mariadb.conf <config/mariadb.conf>`:

.. literalinclude:: config/mariadb.conf
    :language: ini


Preparing the database
^^^^^^^^^^^^^^^^^^^^^^

Create a new emtpy database called **pdns** on the MySQL server
::

    $ mysql -u root -p 
    CREATE DATABASE pdns;

Create a database user for PowerDNS-server to access the database:

.. code-block:: mysql

    GRANT ALL ON pdns.* TO 'pdns'@'localhost' IDENTIFIED BY '********';
    FLUSH PRIVILEGES;
    EXIT;


The file :download:`powerdns.sql <config/powerdns.sql>` contains the PowerDNS
database structure as shown in the PoweDNS documentation
`Basic setup: configuring database connectivity
<https://doc.powerdns.com/authoritative/guides/basic-database.html>`_:

.. literalinclude:: config/powerdns.sql
    :language: mysql

To create this table structures in our new PowerDNS database::

    $ mysql -u root -p pdns < powerdns.sql


Master Server
-------------

The following settings need to be changed in
:download:`/etc/powerdns/pdns.conf <config/pdns-master.conf>`:

REST API
^^^^^^^^

This is only requiered, if you want to make changes through the API, or use PowerDNS-Admin.

Create a random string to be used as API key to access the server by
other apps::

    $ pwgen -cns 64 1

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :lines: 42-52

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :lines: 629-664

Don't forget: if you want to use the API from any other host then localhost, add / change `webserver-address` and `webserver-allow-from`.


Allowed Zone Transfers
^^^^^^^^^^^^^^^^^^^^^^

Add here all your slave servers IP.

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # 8bit-dns=no
    :end-before: # allow-dnsupdate-from


Enable Zone Transfers
^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # direct-dnskey=no
    :end-before: # disable-axfr-rectify


Server IP Address (Optional)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Replace this with your IPv4, and (optional) IPv6 address.

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # load-modules=
    :end-before: # local-address-nonexist-fail

Don't use `local-ipv6`, it's deprecated!

Act as Master Server
^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # lua-records-exec-limit=
    :end-before: # max-cache-entries


Source Address
^^^^^^^^^^^^^^

By default PowerDNS will use the last defined IP address as source address to
send out DNS NOTIFY messages to slaves.

The slave servers, will not accept any NOTIFY messages, if they are not coming
from the defined master server of a domain. Here is how we tell PowerDNS to use
its dedicated IPv4 and IPv6 addresses for outgoing connections:

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # query-cache-ttl=20
    :end-before: # query-logging Hint backends that queries should be logged


Server Restart
^^^^^^^^^^^^^^^^^

::

    $ sudo systemctl restart pdns.service


Secondary Server(s)
----------------

To set up a PowerDNS as secondary slave DNS server.

In this guide we use PowerDNS `Supermaster <https://doc.powerdns.com/authoritative/modes-of-operation.html#supermaster-automatic-provisioning-of-slaves>`__ functionality.


Install MariaDB and PowerDNS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

See above, run everything in the `DNS Server Database`_ section

Download the config for the slave :download:`/etc/powerdns/pdns.conf <config/pdns-slave.conf>`, or make the following changes to the default config:

Slave Server IP Addresses
^^^^^^^^^^^^^^^^^^^^^^^^^

.. literalinclude:: config/pdns-slave.conf
    :language: ini
    :start-after: # load-modules=
    :end-before: # local-address-nonexist-fail


Setup PowerDNS as a Slave
^^^^^^^^^^^^^^^^^^^^^^^^^

Enable slave functionality:

.. literalinclude:: config/pdns-slave.conf
    :language: ini
    :start-after: # signing-threads=3
    :end-before: # slave-cycle-interval

.. literalinclude:: config/pdns-slave.conf
    :language: ini
    :start-after: # socket-dir=
    :end-before: # tcp-control-address

Allow notify from master server.

.. literalinclude:: config/pdns-slave.conf
    :language: ini
    :start-after: # allow-dnsupdate-from=
    :end-before: # allow-unsigned-notify

Configure supermaster on slave server (in mysql).

.. code-block:: mysql

    USE pdns;
    INSERT INTO supermasters (ip, nameserver, account) VALUES ("192.0.2.41", "ns01", "");


Restart the slave server::

    $ sudo systemctl restart pdns.service


Add a Domain and Recrods
------------------------

You need to do that only on the Master Server.

Import existing Zone-Files
^^^^^^^^^^^^^^^^^

If you already have zone files, from previous DNS servers or 3rd-party
providers, you can import them as follows::

    $ zone2sql --zone=example.de.zone \
               --zone-name=example.de \
               --gmysql --transactions --verbose \
               > example.de.zone.sql
    1 domains were fully parsed, containing 49 records
    $ mysql -u root -p pdns < example.de.zone.sql
    Enter password:

or

Create a sample Zones
^^^^^^^^^^^^^^^^^^^^^

Make sure, this is the first domain you add, else you need to change the `domain_id` in `INSERT INTO records` statements.

.. code-block:: mysql

    USE pdns;

    INSERT INTO domains (name, type, account) values ('example.de', 'MASTER', 'example');

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'example.de','localhost admin.example.de 1 10380 3600 604800 3600','SOA', 86400, NULL);

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'example.de','dns01','NS',86400, NULL);

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'example.de','dns02','NS',86400, NULL);

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'example.de','192.0.1.10','A',120, NULL);

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'mail.example.de','192.0.1.12','A',120, NULL);

    INSERT INTO records (domain_id, name, content, type,ttl,prio)
    VALUES (1,'example.de','mail.example.de','MX',120,25);


And done. Very easy.


Add Domain Record on Slave Server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This happens automatic, because we use superslave :-)

Notifications are sent default every 60 seconds. You can chagne this in :file:`/etc/powerdns/pdns.conf`

.. literalinclude:: config/pdns-master.conf
    :language: ini
    :start-after: # slave=no
    :end-before: # slave-renotify


Add Slave Record on Master Server
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Open a MySQL database server sesssion::

    master$ mysql -u root -p pdns


Add a NS record and IP addresses of the new slave to the domain:

 .. code-block:: mysql

    USE pdns;

    INSERT INTO `records` (`domain_id`, `name`, `type`, `content`)
        VALUES(
            (SELECT `id` FROM `domains` WHERE `name` = 'example.de'),
            'example.de',
            'NS',
            'ns2.example.de'
    );
    INSERT INTO `records` (`domain_id`, `name`, `type`, `content`)
        VALUES(
            (SELECT `id` FROM `domains` WHERE `name` = 'example.de'),
            'ns2.example.de',
            'A',
            '192.0.2.42'
    );
    INSERT INTO `records` (`domain_id`, `name`, `type`, `content`)
        VALUES(
            (SELECT `id` FROM `domains` WHERE `name` = 'example.de'),
            'ns2.example.de',
            'AAAA',
            '2001:db8::42'
    );


Delete a Domain
---------------

Let's say you want to remove the domain **example.de** completely.

 .. code-block:: mysql

    USE pdns;

    DELETE FROM `domainmetadata` WHERE `domain_id` = (
        SELECT `id` FROM `domains` WHERE `name` = "example.de"
    );
    DELETE FROM `records` WHERE `domain_id` = (
        SELECT `id` FROM `domains` WHERE `name` = "example.de"
    );
    DELETE FROM `comments` WHERE `domain_id` = (
        SELECT `id` FROM `domains` WHERE `name` = "example.de"
    );
    DELETE FROM `cryptokeys` WHERE `domain_id` = (
        SELECT `id` FROM `domains` WHERE `name` = "example.de"
    );
    DELETE FROM `domains` WHERE `name` = "example.de";

This same procedure needs to be done on every master or slave sever.
This happens **not** automatically with supermaster, you really need to do that on every master / slave server.
