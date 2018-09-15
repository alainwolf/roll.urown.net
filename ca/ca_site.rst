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

    # ca.example.net
    iface eth0 inet static
        address 192.0.2.28/24
    iface eth0 inet6 static
        address 2001:db8::28/64


Nginx Configuration
-------------------

For now a simple static website with some information and relevant files to
download will do.

The complete file is available for :download:`download
<config-files/ca.example.net.conf>`.

.. literalinclude:: config-files/ca.example.net.conf
    :language: nginx
    :linenos:


Information Page
----------------

The CA's website should contain the following information in human readable form:

 * General information about the CA.
 * Contact information.
 * Certification policies.
 * How to verify the root certificate of this CA.
 * How to set this CA's root certificate as trusted in various clients.
 * How to request a signed certificates from by this CA.
 * How to install signed certificates in various clients and servers.
 * How to request revocation in case of loss or compromise of private keys.


CA Files
--------

Install the CA certificates and CRLs on the server for users and clients to
download, so that clients can download them while verifying certificates:

 * Root CA Certificate :file:`/certs/root-ca.crt`
 * Root CA Revocation List :file:`/crl/root-ca.crl`
 * Intermediate CA Certificate :file:`/certs/intermed-ca.crt`
 * Intermediate CA Revocation List :file:`/crl/intermed-ca.crl`

