CA Website
==========

As we need a place to inform our users about the CA, distribute our certificates
and publish revocation information, we create a website.


IP Addresses
------------

In this example we use |CAsiteIPv4| and |CAsiteIPv6| as IP addresses for the
website.

To add the IPv4 address::

    $ sudo ip addr add 192.0.2.28/24 dev eth0

To add the IPv6 address::  

    $ sudo ip addr add 2001:db8:26:845::28/64 dev eth0


Edit :file:`/etc/network/interfaces`::

    ...

    # ca.example.com
    iface eth0 inet static
        address 192.0.2.28/24
    iface eth0 inet6 static
        address 2001:db8::28/64


Nginx Configuration
-------------------

For now a simple static website with some information and relevant files to
download will do.

The complete file is available for :download:`download 
<config-files/ca.example.com.conf>`.

.. literalinclude:: config-files/ca.example.com.conf
    :language: nginx
    :linenos:


Information Page
----------------

