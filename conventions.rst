:orphan:

Conventions
===========

This documentation shows alot of examples. However, while setting up your own
environment, the Internet IP addresses and domain names used in this
documentation **should NOT be used**!

Domains Names
-------------

The public domain "example.net"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The public internet domain for services available to the world outside is always
called *example.net*. This domain has been reserved for documentation purpose by
IANAA and can not be used for your own services.
See `IANA-managed Reserved Domains <https://www.iana.org/domains/reserved>`_.

Instead you should come up with your own domain name and register it yourself.


The private local domain "lan"
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The private local domain for servces available on the local network is called
*lan*. This is a non-existing top-level domain. As such it ensures, that any
servies available on this domain, will never be reachable from the outside. You
can use *lan* in your own environment or come up with your own, as long as it is
not available on the internet. You can find a list of all currently available
top-level domains on Wikipedia's `List of Internet top-level domains
<https://en.wikipedia.org/wiki/List_of_Internet_top-level_domains>`_ or directly
in IANA's `Root Zone Database <https://www.iana.org/domains/root/db>`_.

Also don't use "**local**"" as your local domain, as this will create problems
with mDNS, who uses "**local**"" already for service-discovery on local networks.


We use two categories of hostnames.

Machines Hostnames
------------------

Physical machines or devices have kind of a personality and should have an easy
to remember name across îts entire lifespan.

It should be named the first time it is put in service. Don't use your own name
or the name of you userprofile as computer hostname. Don't call it anyones name,
person or animal, present in your household or organization. Easy to use is any
list of uncommon words, like "cities in India", "rivers in Canada", "greek
goods", "planets in our starsystem", "characters of Star-Trek" or any list of
characters from your favourite TV series. Don't use numbers (we habe IP
addresses for that). Don't use roles (they will change over its lifetime),

Physical machines are always local and private and therefore only resolve to
names in the internal private domain "lan".

========== ============= =======================================================
Example    Your Hostname Description
========== ============= =======================================================
router                   Internet-Gateway, Firewall and WiFi router device
server                   Computer running Ubuntu Server
nas                      NAS device (Network Attached Storage)
desktop                  Personal computer device
tablet                   Tablet computer running CyanogenMod Android
smartphone               Smartphone running CyanogenMod Android
reader                   Reader device for electronic books
dlna                     A/V streaming client device with DLNA support
phone                    Telephony device with SIP client capabilities
========== ============= =======================================================


Service Hostnames
-----------------

Service hostnames on the other hand are a just the name of the services they
provide. Services run on different physical devices and a device might run
different services. They are just there, so you don't have to remember the IP
address of a service and not on which physical machine it is running.

There are private and public service hostnames, depending of the service they
provide.


Private Local Hosts
^^^^^^^^^^^^^^^^^^^

DNS resolvers for example are a local service provided on your internal
network only.

All private hostnames resolve to the its private IPv4 address and IPv6 address.

=========== ====================================================================
Hostname    Description
=========== ====================================================================
gw.lan      Internet-Gateway, Firewall and WiFi router device, LAN interface
ns1.lan     One of two recursive DNS resolvers
ns2.lan     One of two recursive DNS resolvers
sql.lan     Database server
admin.lan   Web-based administration interfaces
time.lan    Time server
=========== ====================================================================


Public Global Hosts
^^^^^^^^^^^^^^^^^^^

Webserver who host your website to the public need to be reachable globally.

All public hostnames resolve to the same single public (and dynamic) IPv4
address, but have their own IPv6 address.

================= ==============================================================
Hostname          Description
================= ==============================================================
gw.example.net    Internet-Gateway, Firewall and WiFi router, WAN Interface
vpn.example.net   VPN server
dns0.example.net  Domain name server, hidden master.
dns1.example.net  Secondary domain name server, slave, other location / network.
dns2.example.net  Secondary domain name server, slave, other location / network.
dns3.example.net  Secondary domain name server, slave, other location / network.
mail.example.net  Mail server
web.example.net   Web-Server
cloud.example.net Cloud server
xmpp.example.net  XMPP instant messaging server.
sip.example.net   SIP VoIP server
books.example.net Calibre books library server.
media.example.net DLNA gateway
bt.example.net    BitTorrent Tracker
btc.example.net   BitCoin server
================= ==============================================================

There can be more, but sometimes they are just aliases, running on the same IP
address (like ).


IP Addresses
------------

Public IPv4
^^^^^^^^^^^

Wherever the current public IPv4 address is needed, we use |publicIPv4| as IP
address. This is not a real address. It has been reserved for use in
documentation. Your public IPv4 address is usually assigned to you by your ISP
and might change periodically.


Local Private IPv4 Subnet
^^^^^^^^^^^^^^^^^^^^^^^^^

We use |IPv4subnet| as local private IPv4 subnet in this documentation. This is
also is from a range of addresses that has been reserved for documentation and
should never be used in real IP networks. Regardless if that network is private
or not.

You can choose your private network address freely as long as it is in the range
private network address space by :rfc:`1918`.
See `Private Network <https://en.wikipedia.org/wiki/Private_network>`_ on
Wikipedia.

However I advise against using any of the very common 192.168.0.0/24 or similar
subnets, which everyone uses or which are the default setting in many router
devices. Chances are, that you end up being in a private subnet in a friends
house or coffe-shop and can connect to you VPN at home, as both use the same
subnet.

Don't use any of the 10.0.0/8 blocks either, as they are very common to be used
in routing by mobile and other telecom providers as well as many bigger
organziations.


Use a random /24 block out of the 172.16.0.0/12 blocks and tell your friends to
do the same (with another random block of their own). That way you will have
little chances of being stuck between two private networks and can connect
different households by VPN easily.

================= ============
192.168.0.0/24     Avoid
192.168.1.0/24     Avoid
192.168.2.0/24     Avoid
192.168.100.0/24   Avoid
10.0.0/8           Avoid
172.16.0.0/24
     ...           Best
172.31.255.0/24
================= ============


Here is Linux command-line to find a random /24 subnet in the 172.16.0.0/12
block::

    $ echo 172.$((RANDOM%16+16)).$((RANDOM%255)).0/24

Use the following to find a random /24 subnet in the 192.168.0.0/20 block::

    $ echo 192.168.$((RANDOM%255+4)).$((RANDOM%255)).0/24


================ ============ ==================================================
Example          Your Subnet  Description
================ ============ ==================================================
|IPv4subnet|                  Local private IPv4 network (See :rfc:`1918`).
================ ============ ==================================================


Global Public IPv6 Subnet
^^^^^^^^^^^^^^^^^^^^^^^^^

We use |IPv6subnet| as the local public IPv6 network in this documentation. As
you might guess,this one too is not useable in real-life situations as it is
reserved for documentation only.

You will get your IPv6 prefix directly from your Internet service provider or
from a tunnel provider, like `Hurrican Electric <https://ipv6.he.net>`_ if your
ISP doesn't support IPv6. Either a ::/64 or a ::/48 prefix.


================ ============ ==================================================
Example          Your Subnet  Description
================ ============ ==================================================
|IPv6subnet|                  Public globally routed IPv6 network
================ ============ ==================================================


Hosts
^^^^^

====================== ================= =======================================
Name                   Address           Comments
====================== ================= =======================================
home.\ |publicDomain|  |publicIPv4|      Single Dynamic Public Address
www.\ |publicDomain|   |HTTPserverIPv4|  Web server
mail.\ |privateDomain| |mailserverIPv4|
mail.\ |publicDomain|  |mailserverIPv6|
sip.\ |publicDomain|   |SIPserverIPv4|
sip.\ |publicDomain|   |SIPserverIPv6|
====================== ================= =======================================


|BOOKserverIPv4|

|BOOKserverIPv6|

|OPDSserverIPv4|

|OPDSserverIPv6|

|DNSMasterIPv6|

|DNSSlaveAIPv6|

|DNSSlaveBIPv6|

|DNSSlaveCIPv6|

|DNSSlaveAIPv4|

|DNSSlaveBIPv4|

|DNSSlaveCIPv4|
