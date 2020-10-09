Network Design
==============

.. contents::
  :local:

Networks, subnets, port, and corresponding access rules and rights are already
complex and get more complex, the more servers and services are added.
:doc:`/server/wireguard` add another layer on top of all that and changes all
all these already hard to grasp parts. Therefore a clear design concept is
needed for reference as we go one.

.. note::

    All IP addresses in this document have been reserved for documentation and
    testing in :RFC:`5737` and :RFC:`4849` or for use in private networks
    according to :RFC:`1918`. They will not work in the real world.


Providers
---------

Make a list of all providers (hosting companies, co-location data-centers,
friends, family members, employers or other companies who agreed to host a
device on there premises for you). Decide on a abbreviation for each to use
throughout the design.

You can find out the provider by using the :file:`whois` command of any public
IP address::

    $ whois 203.0.113.54


Or for a host name::

    $ whois $(dig +short roll.urown.net)


Some examples:

================= ==========
Provider          Short Name
================= ==========
Hetzner Online AG heztner
OVH               ovh
Digital Ocean     do
Linode            linode
Rackspace         rack
Your Home         home
Your Office       office
Mothers House     mama
================= ==========


Locations
---------

Make a list of all geographical or physical remote locations that have one or
more servers running. Most providers have their own naming.

Some examples:

============= ==========
Location      Short Name
============= ==========
San Francisco SFO
New York City NYC
Toronto       TOR
Berlin        BER
London        LON
Amsterdam     AMS
Frankfurt     FRA
Singapore     SGP
Bangalore     BLR
============= ==========


Public IPs and Subnets
----------------------

You get these normally from your provider and they are location based.
Nowadays you should get an IPv6 as well or change your provider otherwise.

In the best case you get a subnet, maybe you get additional IPs for a price.

List the subnet with their net-mask, which tells you the size and number of
IPs. A single IPv4 host has a net-mask of /32. A single IPv6 address has a net-mask of /128

Some examples:

======== ======== ================== ========================
Provider Location IPv4 Subnet        IPv6 Subnet
======== ======== ================== ========================
hetzner  SFO      203.0.113.54/32     n/a
rack     LON      198.51.100.7/32    2001:db8:48d1::/64
roller   PHO      192.0.2.14/32      2001:db8:2d07:5b57::/128
home     FRA      dynamic            2001:db8:3414::/48
office   FRA      dynamic            dynamic
mama     BER      dynamic            n/a
======== ======== ================== ========================


Private Subnets
---------------

Some locations need a private subnet, if there are multiple hosts behind a NAT
router. Define one from the range private network address spaces set by by
:rfc:`1918`.

See `Private Network <https://en.wikipedia.org/wiki/Private_network>`_ on
Wikipedia:


Private IPv4 Addresses
^^^^^^^^^^^^^^^^^^^^^^

=============== =============== ==========
Network Address Net Mask        Prefix
=============== =============== ==========
10.0.0.0        255.0.0.0       10/8
172.16.0.0      255.240.0.0     172.16/12
192.168.0.0     255.255.0.0     192.168/16
fd00::/48       n/a             fd00::/48
=============== =============== ==========

First we define a global private subnet out of one of the private address
spaces::

    $ echo 172.$((RANDOM%16+16)).0.0/24
    172.27.0.0/24


================== =========== =============
Global IPv4 Subnet Netmask     Prefix
================== =========== =============
172.27.0.0         255.255.0.0 172.27.0.0/16
================== =========== =============

Next we define /24 subnets out of our global private subnets for locations who need that::

    $ echo home 172.27.$((RANDOM%255+16)).0/24
    $ echo office 172.27.$((RANDOM%255+16)).0/24
    $ echo mama 172.27.$((RANDOM%255+16)).0/24

======== ======== ================= ============= ===============
Provider Location Local IPv4 Subnet Netmask       Prefix
======== ======== ================= ============= ===============
home     FRA      172.27.88.0       255.255.255.0 172.27.88.0/24
office   FRA      172.27.126.0      255.255.255.0 172.27.126.0/24
mama     BER      172.27.74.0       255.255.255.0 172.27.74.0/24
======== ======== ================= ============= ===============


Private IPv6 Addresses
^^^^^^^^^^^^^^^^^^^^^^

For IPv6 subnets we can use the on-line tool
`IPv6 private address range generator <https://www.ultratools.com/tools/rangeGenerator>`_.

It will create a random global ID and subnet IDs out of the unique local address
(ULA) block :file:`fd00::/8`.

========= ===========
Global ID c1d89eb128
========= ===========

=================== ===================
Global IPv6 Subnet  Prefix
=================== ===================
fdc1:d89e:b128::/48 fdc1:d89e:b128::/48
=================== ===================

Repeat for every location, by providing the same global ID to generate a /64
subnet for each.

`<https://www.ultratools.com/tools/rangeGeneratorResult?globalId=c1d89eb128&subnetId=>`_

======== ======== ========= ========================
Provider Location Subnet ID Local IPv6 Subnet
======== ======== ========= ========================
home     FRA      13a6      fdc1:d89e:b128:13a6::/64
office   FRA      2615      fdc1:d89e:b128:2615::/64
mama     BER      41c5      fdc1:d89e:b128:41c5::/64
======== ======== ========= ========================


The VPN Subnet
--------------

To glue all our locations subnets together we need another one. The tunnel
subnet connects all the VPN hosts and gateways together.


IPv4 VPN Addresses
^^^^^^^^^^^^^^^^^^

For IPV4 Telco's traditionally choose something out of the private 10/8 block.

This makes it easy to distinguish the virtual space from the physical
locations within the 172.16/12 space::

    $ echo 10.$((RANDOM%255+16)).$((RANDOM%255+16)).0/24
    10.195.171.0/24


IPv6 VPN Addresses
^^^^^^^^^^^^^^^^^^

The IPv6 address of the tunnel subnet we define an additional subnet ID.

========= ===========
Global ID c1d89eb128
========= ===========
Subnet ID 6a04
========= ===========


Combined IPv4 and IPv6 together it may look like the following:

======== ========== =============== ========================
Provider Location   IPv4 Subnet     IPv6 Subnet
======== ========== =============== ========================
n/a      Global     172.27.0.0/16   fdc1:d89e:b128::/48
home     FRA        172.27.88.0/24  fdc1:d89e:b128:13a6::/64
office   FRA        172.27.126.0/24 fdc1:d89e:b128:2615::/64
mama     BER        172.27.74.0/24  fdc1:d89e:b128:41c5::/64
VPN      Virtual    10.195.171.0/24 fdc1:d89e:b128:6a04::/64
======== ========== =============== ========================


Register a Domain
-----------------

Register a domain for where all your networks and hosts reside in. 

It doesn't matter if it is the same domain where our public services are
hosted or a different one. The important thing is, that all subnets, sub-
domains and host-names reside under **one domain-name which we fully
control**.

That way we can establish trust between all entities based on DNS information
secured by DNSSEC. This will simplify things in many areas (e.g. trusting SSH
servers keys).

=========== =========
Domain      Registrar
=========== =========
example.net name.com
=========== =========


Sub-Domains for Sub-Nets
^^^^^^^^^^^^^^^^^^^^^^^^

Locations with multiple hosts and IP subnets, get their own sub-domain.
Standalone rented servers in data-centers don't need sub-domains.

========== ========== =============== ========================
Subdomain  Location   IPv4 Subnet     IPv6 Subnet
========== ========== =============== ========================
.          Global     172.27.0.0/16   fdc1:d89e:b128::/48
home       FRA        172.27.88.0/24  fdc1:d89e:b128:13a6::/64
office     FRA        172.27.126.0/24 fdc1:d89e:b128:2615::/64
mama       BER        172.27.74.0/24  fdc1:d89e:b128:41c5::/64
========== ========== =============== ========================


VPN Sub-domain
^^^^^^^^^^^^^^

The VPN sub-domain allows us to make sure, that a connection is authenticated
and encrypted at a glance, without memorizing IP addresses. Since the VPN
stretches throughout the planet, only is needed.

Let's call this **vpn**.

========== ========== =============== ========================
Subdomain  Location   IPv4 Subnet     IPv6 Subnet
========== ========== =============== ========================
vpn        Virtual    10.195.171.0/24 fdc1:d89e:b128:6a04::/64
========== ========== =============== ========================


Host Names
----------

Over time you will iterate trough many physical and virtual devices, providing
similar services and devices changing their roles and locations, its best to
avoid service names, role names, company names, real peoples (e.g. owners)
names or household names for devices.

Just take a list, any list, of names or words, preferably a long one and
iterate over it.

Here is a good `starting point <https://en.wikipedia.org/wiki/Category:Lists_of_lists>`_.

I leave it up to you, the reader, to guess from which list the following host
names are coming from ...

========= ======== ======== ======
Host      Location Provider Role
========= ======== ======== ======
dolores   SFO      hetzner  Server
maeve     LON      rack     Server
bernard   PHO      roller   Server
arnold    FRA      home     Router
hector    FRA      home     NAS
kiki      FRA      home     Wi-Fi
charlotte FRA      home     Server
teddy     FRA      office   Router
logan     FRA      office   NAS
armistice BER      mama     Router
========= ======== ======== ======


DNS Records
-----------

We now have all the information needed to document our network design in
DNS under the example.net domain.

Top-Level Domain
^^^^^^^^^^^^^^^^

E.g. **example.net** (public hosts): 

Here we only register the hosts who need to be accessible from the global
public Internet (read: from the outside) for some reason, like servers routers
and VPN gateways.

Some of these won't get a fixed IP address, due to the providers policy. For
these we need a DynDNS solution not discussed here.

===================== ============ =======================
Domain Name           IPv4 Address IPv6 Address
===================== ============ =======================
dolores.example.net   203.0.113.54 N/A
maeve.example.net     198.51.100.7 2001:db8:48d1::1 
bernard.example.net   192.0.2.14   2001:db8:2d07:5b57::0
arnold.example.net    dynamic      2001:db8:3414:6b1d::1
charlotte.example.net dynamic      2001:db8:3414:6b1d::10
teddy.example.net     dynamic      dynamic
===================== ============ =======================


VPN Sub-Domain
^^^^^^^^^^^^^^

**vpn.example.net**:

========================== ============== =========================
Domain Name                IPv4 Address   IPv6 Address
========================== ============== =========================
dolores.vpn.example.net    10.195.171.142 fdc1:d89e:b128:6a04::7de4
maeve.vpn.example.net      10.195.171.47  fdc1:d89e:b128:6a04::961
bernard.vpn.example.net    10.195.171.174 fdc1:d89e:b128:6a04::3354
charlotte.vpn.example.net  10.195.171.241 fdc1:d89e:b128:6a04::29ab
========================== ============== =========================


Location Sub-Domains
^^^^^^^^^^^^^^^^^^^^

**home.example.net**:

========================== ============== =========================
Domain Name                IPv4 Address   IPv6 Address
========================== ============== =========================
arnold.home.example.net    172.27.88.1    fdc1:d89e:b128:13a6::1
charlotte.home.example.net 172.27.88.10   fdc1:d89e:b128:13a6::10
kiki.home.example.net      172.27.88.3    fdc1:d89e:b128:13a6::3
========================== ============== =========================

Sub-domain **office.example.net**:

========================== ============== =========================
Domain Name                IPv4 Address   IPv6 Address
========================== ============== =========================
teddy.office.example.net   172.27.126.1   fdc1:d89e:b128:2615::1
logan.office.example.net   172.27.126.10  fdc1:d89e:b128:2615::10
========================== ============== =========================

Sub-domain **mama.example.net**:

========================== ============== =========================
Domain Name                IPv4 Address   IPv6 Address
========================== ============== =========================
armistice.mama.example.net 172.27.74.1    fdc1:d89e:b128:41c5::1
========================== ============== =========================


DNS Reverse Records
^^^^^^^^^^^^^^^^^^^

TBD.
