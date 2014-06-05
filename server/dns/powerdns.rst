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

The server will need a dedicated private IPv4 address and a IPv6 address.
See :doc:`/server/network`.

Troughout this document we will use **192.0.2.41** as IPv4 address and 
**2001:db8::41** as IPv6 address.

Also you need to know your public IPv4 address on your gateway. In this document 
we will use **198.51.100.240** as an example address.


Firewall-Gateway
^^^^^^^^^^^^^^^^

The :doc:`/router/index` needs to forward incoming external IPv4 traffic on TCP
and UDP port  **53** to the private IPv4 address of this DNS server. IPv6
traffic on TCP and UDP port 53 to this servers IP address must be allowed to
pass the firewall.


Database
^^^^^^^^

:doc:`/server/mariadb` must be installed and running.


Domain Registration
^^^^^^^^^^^^^^^^^^^

You need to register your domain with one of the official DNS registrars. The
registrar must support **DNSSEC** and allow you to define your own name servers.


Secondary Domain Name Servers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You will need a 3rd-Party providing you with secondary servers. The provider must
support **IPv6**, **NOTIFY**, **AXFR** and **DNSSEC** on its servers.


Software Installation
---------------------

The PowerDNS server software is in the Ubuntu software package repository. We 
install the server and the MySQL database backend.

::

    $ sudo apt-get install pdns-server pdns-backend-mysql

You will be asked for the password of the MySQL root user, so the database can 
be created.

The following happens during installation:

    * The following configuration file are created:

        * :file:`/etc/powerdns/pdns.conf`.
        * :file:`/etc/default/pdns`.
        * :file:`/etc/powerdns/pdns.d/pdns.local.conf`
        * :file:`/etc/powerdns/pdns.d/pdns.simplebind.conf`
        * :file:`/etc/powerdns/pdns.d/pdns.local.gmysql.conf`

    * A user and group *pdns* is created.
    * A system service :file:`/etc/init.d/pdns` is created and started.


Configuration
-------------

Only one backend can be active. As we installed the MySQL backend we need to 
remove the default bind-backend, by deleteing its configuration file.

::
    
    $ sudo rm /etc/powerdns/pdns.d/pdns.simplebind.conf


The following settings need to be changed in :file:`/etc/powerdns/pdns.conf`:

.. code-block:: ini

    #################################
    # local-address Local IP address to which we bind
    #
    local-address=192.0.2.41

    #################################
    # local-ipv6    Local IP address to which we bind
    #
    local-ipv6=2001:db8::41


The following setting needs to changed in 
:file:`/etc/powerdns/pdns.d/pdns.local.gmysql.conf`:

.. code-block:: ini

    gmysql-socket=/var/run/mysqld/mysqld.sock


Import Zone-Files
^^^^^^^^^^^^^^^^^

If you already have zone files, from previous DNS servers or 3rd-party
providers, you can import them as follows::

    $ zone2sql --zone=example.com.zone \
               --zone-name=example.com \
               --gmysql --transactions --verbose \
               > alainwolf.net.zone.sql
    1 domains were fully parsed, containing 49 records
    $ mysql -u root -p pdns < example.com.zone.sql
    Enter password: 

And done. Very easy.