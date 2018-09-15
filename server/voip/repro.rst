.. todo:: *Add references*

.. todo:: *Add entry in glossar*

repro
=====

.. image:: Repro-logo.*
    :alt: Repro Logo
    :align: right

`repro <http://www.resiprocate.org/About_Repro>`_ is an open-source, free SIP
server. SIP is changing the way people communicate using the Internet. It is
not only about making phone calls over the Net. The SIP protocol and its
extensions defines the way of establishing, modifying and ending interactive
sessions, no matter if they are voice, video, IM or a combination of them. At
the heart of SIP architecture, there are certain services which need to be
provided at some place in the network. repro provides SIP proxy, registrar,
redirect, and identity services. These services are the foundation needed to
run a SIP service.


Prerequesites
-------------


IP-Addresses
^^^^^^^^^^^^

See doc:`server/networking`.

As usual we setup fresh local private IP4 and global IPv6 addresses for the
SIP proxy server::

  $ sudo ip addr add 192.0.2.15/24 dev eth0
  $ sudo ip addr add 2001:db8::15/64 dev eth0


To make these addresses persistent across system restarts, they need to be added
to :file:`/etc/network/interface` as well.

.. code-block:: ini

  ...
  # bt.example.net
  iface eth0 inet static
      address 192.0.2.15/24
  
  iface eth0 inet6 static
      address 2001:db8::15/64


DNS Records
^^^^^^^^^^^

.. todo:: *DNS records for repro*

See doc:`server/dns`

SIP calls are routed over the internet towards its destination in a similar way
as emails. Therefore DNS plays an important role.

Add the following records to your domain *example.net* using the poweradmin web
interface:

=========== ======== ========================================== ============ =======
**Name**    **Type** **Content**                                **Priority** **TTL**
sip-proxy   A        |publicIPv4|                                          0     300
sip-proxy   AAAA     |SIPserverIPv6|                                       0   86400
_sips._tcp  SRV      1 5061 sip-proxy.example.net                          0   86400
.           NAPTR    0 "s" "SIPS+D2T" "" _sips._tcp.example.net           10   86400
=========== ======== ========================================== ============ =======

Use your public Internet IPv4 address for the **A** record.


Firewall Rules
^^^^^^^^^^^^^^

.. todo:: *Firewall configuration for repro*


Software Installation
---------------------

Repro is available as package in the Ubuntu software repository::

    $ sudo apt-get install repro

The installation creates the following items:

 * The system user and group **repro**.
 * The system user and group **turnserver**.
 * The system service **repro** (see :file:`/etc/init.d/repro`).
 * The system service **turnserver** (see :file:`/etc/init.d/rfc5766-turn-server`).
 * The configuration directory :file:`/etc/init.d/repro` with various files.
 * A plugin directory :file:`/usr/lib/x86_64-linux-gnu/resiprocate/repro`.
 * A database directory :file:`/var/lib/repro` with various BerkleyDB files.
 * A logging directory :file:`/var/log/repro`.

The **repro** server runs a SIP service on TCP and UDP ports 5060 on all
available network interfaces and IP addresses. It also starts is own web-server
on TCP port 5080 on localhost for the web administration interface and a
command-server on localhost TCP port 5081 listening for XML RPCs (remote
procdeure calls).

The **turnserver** service is not started after installation. See
:file:`/etc/default/rfc5766-turn-server` for instructions on enabling
turnserver.


Configuration
-------------


Administration Website
----------------------

To access the web administration interface, we need to change the IP address, as
we cant reach localhost.

Open :file:`/etc/init.d/repro/repro.config`, look for the line starting with
**HttpBindAddress** and change the IP to your servers main address.

.. code-block:: ini

	# Comma separated list of IP addresses used for binding the HTTP configuration interface
	# and/or certificate server. If left blank it will bind to all adapters.
	HttpBindAddress = 192.0.2.10, 2001:db8::10

Then restart the server::

	$ sudo service repro restart

Now you should be able to point your browser to `<http://server.lan:5080/>`_ and
access the web interface. Login with the default user and password **admin**.


Monitoring
----------

.. todo:: *Monitoring and log-files for repro*


Backup Considerations
---------------------

.. todo:: *BackupNinja daily backup for repro*


References
----------
Recommended reading: 
 * `repro 1.8 Overview document <http://www.resiprocate.org/images/f/f0/Repro_1.8_Overview.pdf>`_ (PDF)
 * `Using Repro <http://www.resiprocate.org/Using_Repro>`_

