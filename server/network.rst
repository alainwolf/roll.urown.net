Network
========

.. note::
   The IP addresses shown here, are documentation examples. You need to use your own addresses. See :doc:`/router/index` for network and IP configuration.


We have dual-Stack IPv4 and IPv6 on our internal network (LAN).

The IPv6 addresses are globally routed official internet addresses assigned to us by our IPv6 internet provider.

The IPv4 addresses are 
`private network <https://en.wikipedia.org/wiki/Private_network>`_ 
addresses.

The router supplies most of the relevant settings by autoconfiguration, and we like to keep it that way. The only exception are additional fixed IP addresses for hosted services.

Interface Configuration
-----------------------

Edit the :file:`/etc/network/interfaces`.

Leave the ethernet interface at its default settings::

	# The loopback network interface
	auto lo
	iface lo inet loopback

	# The primary network interface
	auto eth0

	# Autoconfigured IPv4 interface
	iface eth0 inet dhcp

	# Autoconfigured IPv6 interface
	iface eth0 inet6 auto


Add additional static IPv4 and IPv6 addresses for each service and virtual host::

	# Port-forwarded connections from firewall-router
	iface eth0 inet static
	    address 192.0.2.10/24
	iface eth0 inet6 static
	    address 2001:db8::10/64

	# www.example.com
	iface eth0 inet static
	    address 192.0.2.11/24
	iface eth0 inet6 static
	    address 2001:db8::11/64

	# cloud.example.com
	iface eth0 inet static
	    address 192.0.2.12/24
	iface eth0 inet6 static
	    address 2001:db8::12/64

	# xmpp.example.com
	iface eth0 inet static
	    address 192.0.2.13/24
	iface eth0 inet6 static
	    address 2001:db8::13/64

	# voip.example.com
	iface eth0 inet static
	    address 192.0.2.14/24
	iface eth0 inet6 static
	    address 2001:db8::14/64

Add as many adresses as needed, as long as they are not already defined on other devices or assigned trough autoconfiguration. This gets easier if you reserve a range like **10** to **90** to this server and only assign addresses from that range.

For easier recognition and administration the last number of any IPv4 and IPv6 address is identical (e.g. 192.0.2.\ **10** and 2001:db8::\ **10**\ ).

Restart the network services with::

	$ sudo service networking restart

