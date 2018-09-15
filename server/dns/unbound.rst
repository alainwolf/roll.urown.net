.. image:: unbound-logo.*
    :alt: unbound Logo
    :align: right

DNS Resolver
============

`Unbound <https://unbound.net/>`_ is a validating, recursive, and caching DNS
server software product from NLnet Labs, VeriSign Inc., Nominet, and Kirei. It
is distributed free of charge in open source form under the BSD license.

Unbound is designed as a set of modular components that incorporate modern
features, such as enhanced security (DNSSEC) validation, Internet Protocol
Version 6 (IPv6), and a client resolver application programming interface
library as an integral part of the architecture. Originally written for POSIX-
compatible Unix-like operating system, it runs on FreeBSD, OpenBSD, NetBSD, OS
X, and Linux, as well as Microsoft Windows.


Software Installation
---------------------

::

    $ sudo apt-get install unbound
    $ sudo service unbound stop

Configuration
-------------

The installed configuration file is very minimal.

A more extensive example configuration file is found at 
`/usr/doc/share/unbound/examples/unbound.conf`.


Server IP Address
^^^^^^^^^^^^^^^^^

Add IPv4 and IPv4 addresses to the server for the unbound daemon to listen to::

    $ sudo ip addr add 2001:db8::43/64 dev eth0
    $ sudo ip addr add 192.0.2.43/24 dev eth0

Make them persistent across reboots by adding them to the
:file:`/etc/network/interfaces` configuration file::

    ...

    # dns2.lan
    iface eth0 inet6 static
        address 2001:db8::43/64
    iface eth0 inet static
        address 192.0.2.43/24



Configure the unbound daemon to listen on those IP addresses by adding the 
following lines to :file:`/etc/unbound/unbound.conf`:

.. code-block:: ini

        interface: 192.0.2.43
        interface: 2001:db8::43


Internet Root DNS severs
^^^^^^^^^^^^^^^^^^^^^^^^

To bootstrap a DNS resolver, the IP addresses of the Internet root DNS servers
are needed. 

The official ICANN controlled DNS root servers are published on the FTP server
`FTP.INTERNIC.NET <ftp://FTP.INTERNIC.NET/>`_.

To download the ICANN root servers cache::

    $ sudo wget -O /var/lib/unbound/ICANN.cache ftp://FTP.INTERNIC.NET/domain/named.cache

But here is a alternative. The Open Root Server Network (ORSN) aims to provide the same service but with less governemental control.

To download the ORSN root servers cache::

    $ sudo wget -O /var/lib/unbound/ORSN.cache http://www.orsn.org/roothint/root-hint.txt


ICANN Trusted Anchors
^^^^^^^^^^^^^^^^^^^^^

See also `Howto enable DNSSEC <https://www.unbound.net/documentation/howto_anchor.html>`_ 
in the `unbound documentation <https://www.unbound.net/documentation/>`_.

To validate the answers to our DNS queries, we need the ICANN root public key.

Unbound provides a tool to automate the task of downloading and installing the
public key:

    1. It provides built-in default contents for the root anchor and root
       update certificate files;
    2. It tests if the root anchor file works;
    3. If not, it tests if an update is possible;
    4. It attempts to update the root anchor using the root update certificate;
    5. It performs a HTTPS fetch of :file:`root-anchors.xml` and checks the results;
    6. If all checks are successful, it updates the root anchor file. 
       Otherwise  the root anchor file is  unchanged. 
    7. It performs :RFC:`5011` tracking if DNSSEC information available.

During runtime, all this is done automatically by the service. But to make the
server start with a valid and current root anchor file, the tool should be run,
before every start of the unbound service.

For the tool to work, unbound needs write access to its configuration files and
directories::

    $ sudo chown -R unbound /etc/unbound
    $ sudo -u unbound unbound-anchor -v


::

    $ sudo wget -O /etc/unbound/dlv.isc.org.key http://ftp.isc.org/www/dlv/dlv.isc.org.key



Check Configuration
-------------------

Check unbound configuration with following command::

    $ sudo unbound-checkconf /etc/unbound/unbound.conf


Service 
-------

::

    $ sudo service unbound start



Local Addresses
---------------



Remote Control
--------------



Reference
---------

* `unbound documentation <https://www.unbound.net/documentation/>`_
