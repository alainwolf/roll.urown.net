Virtual Private Network
=======================

.. image:: openvpn-logo.*
    :alt: OpenVPN Logo
    :align: right


`OpenVPN <https://openvpn.net/index.php/open-source.html>`_ is an open-source
software application that implements `virtual private network (VPN)
<https://en.wikipedia.org/wiki/Virtual_private_network>`_ techniques for
creating secure point-to-point or site-to-site connections in routed or bridged
configurations and remote access facilities. It uses a custom security
protocol[7] that utilizes SSL/TLS for key exchange. It is capable of traversing
network address translators (NATs) and firewalls.


Prerequisites
-------------

TLS Certficates for clients and servers from a :doc:`private CA </ca/index>`.


Preparation
-----------

Random MAC Address
^^^^^^^^^^^^^^^^^^

The virtual tunnel interface will get a randomly created MAC address. Radmon MAC
addresses are available at
`macvendorlookup.com <http://www.macvendorlookup.com/mac-address-generator>`_


Random IPv4 VPN Subnet
^^^^^^^^^^^^^^^^^^^^^^

VPN clients and the server will use their own /24 IP subnet, separate from the
LAN. The subnet will be routed by the OpenVPN server to and from your LAN and
the firewall will provide NAT with your public IP address to the outside world.

To get a random private IPv4 subnet for the VPN::

    $ echo 10.$((RANDOM%255)).$((RANDOM%255)).0/24
    10.135.39.0/24


IPv6 VPN Subnet
^^^^^^^^^^^^^^^

VPN clients and the server will use their own /64 subnet out of your delegated
/48 subnet.

To get the random IPv6 /64 subnet out of the delegated **2001:db8:beef::/48**
prefix::

    $ echo 2001:db8:c0de:`printf "%x\n" $RANDOM`::/64
    2001:db8:c0de:5f5e::/64



Software Installation
---------------------

OpenVPN is available as software package ready to install in the OpenWRT
software package repository (opkg)::

    $ opkg install openvpn-openssl


After installation you find a configuration directory :file:`/etc/openvpn/`.


Network Setup
-------------

Tunnel interface
^^^^^^^^^^^^^^^^

Create a virtual network interface who will be used to tunnel the network
traffic by OpenVPN::

    $ openvpn --mktun --dev tun0


Add OpenWRT network configuration of the tunnel interface in the file
:file:`/etc/config/network`.

::

    config interface 'vpn'
        option ifname 'tun0'
        option macaddr 'EC:C9:54:65:87:02'
        option _orig_ifname 'tun0'
        option _orig_bridge 'false'
        option proto 'static'
        option ipaddr '10.135.39.1'
        option netmask '255.255.255.0'
        option broadcast '10.135.39.254'
        option ip6addr '2001:db8:c0de:5f5e::1/64'
        option ip6ifaceid 'eui64'
        option ip6assign '64'
        option ip6prefix 2001:db8:c0de:5f5e::/64
        list dns '2001:db8:c0de::1'
        list dns '2001:db8:c0de::43'
        list dns '192.0.2.1'
        list dns '192.0.2.43'
        list dns_search 'example.net'
        list dns_search 'lan'
        list dns_search 'local'
        option metric '1'
        option defaultroute '0'


Add OpenWRT DHCP configuration of the tunnel interface in the file
:file:`/etc/config/dhcp`.

::

    config dhcp 'vpn'
        option start '100'
        option leasetime '12h'
        option limit '150'
        option interface 'vpn'
        option ra 'server'
        option dhcpv6 'server'
        option dhcpv4 'server'
        option ra_management '1'
        list dns '2001:db8:c0de::1'
        list dns '2001:db8:c0de::43'
        list dns '192.0.2.1'
        list dns '192.0.2.43'
        list domain 'example.net'
        list domain 'lan'
        list domain 'local'



Server Configuration
--------------------

Create static secret key file for use with the OpenVPN TLS-auth feature::

    $ openvpn --genkey --secret /etc/openvpn/tls-auth.key

This key needs to be shared between all connecting clients and the OpenVPN server.


Configuration
-------------

================== =======
Option             Value
================== =======
verb               3
tun_ipv6           yes
server             10.135.39.0 255.255.255.0
nobind             no
comp_lzo           adaptive
keepalive          10 60
client             yes
client_to_client   yes
================== =======
