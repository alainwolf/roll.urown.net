.. _nas-ups:

Uninterruptible Power Supply
============================

Synology :term:`DSM` has already built in UPS support.

In DSM using an administrative account open **Control Panel** - **Hardware &
Power** - **UPS**.

In the configuration you have the choice between "Synology UPS server" and
"SNMP UPS".

The bad news is, that "SNMP UPS" are mostly very expensive. Professional UPS
devices from APC have a so called "smart slot" where a proprietary optional
network card from APC can be installed. While these are available for the
higher-priced devices, the cards alone sometimes cost more then the UPS device
itself.

The good news is, "Synology UPS server" is nothing else then a hidden
installation of `Network UPS Tools (NUT) <https://networkupstools.org/>`_.
The same software we already use in our other devices, like server and 
:ref:`server-ups`. 

This makes it easy to use "Synology UPS server" with non-Synology masters. The
only thing to keep in mind, is that Synology uses a hard-coded values for UPS
device name, the user and the password. This makes it easy for all Synology
devices to connect to each other. The user just needs to provide the IP
address.

The values are:

=============== =======
UPS device name ups
slave user name monuser
slave password  secret
=============== =======

On the NAS these are found in the file :file:`/usr/syno/etc/ups/upsmon.conf`.

So any NUT master server can be used as "Synology UPS server", as long as its
UPS device is called "ups" and a slave user "monuser" with the matching
password is present.

On the master this is set up in the :file:`/etc/nut/ups.conf` by adding a
section explicatively called **[ups]** as follows::

	[ups]
	driver = usbhid-ups
	port = auto


"Driver" and "port" values may vary according to your UPS device.

And in the file :file:`/usr/syno/etc/ups/upsd.users`::

	[monuser]
	password = secret
	upsmon = slave

