DNS Resolver
============

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

::

	$ sudo ip addr add 2001:db8:4a5c::43/64 dev eth0
	$ sudo ip addr add 192.0.2.43/24 dev eth0

.. code-block:: ini

		interface: 192.0.2.43
		interface: 


Internet Root DNS severs
^^^^^^^^^^^^^^^^^^^^^^^^

To boostrap a DNS resolver, the IP addresses of the Internet root DNS servers
are needed. 

The official ICANN controlled DNS root servers are published on the FTP server
`FTP.INTERNIC.NET <ftp://FTP.INTERNIC.NET/>`_.

To download the ICANN root servers cache::

	$ sudo wget -O /var/lib/unbound/ICANN.cache ftp://FTP.INTERNIC.NET/domain/named.cache

But here is a alternative. The Open Root Server Network (ORSN) aims to provide the same service but with less governemental control.

To download the ORSN root servers cache::

	$ sudo wget -O /var/lib/unbound/ORSN.cache http://www.orsn.org/roothint/root-hint.txt


Trusted Anchors
^^^^^^^^^^^^^^^



::

	$ sudo wget -O /etc/unbound/dlv.isc.org.key http://ftp.isc.org/www/dlv/dlv.isc.org.key

