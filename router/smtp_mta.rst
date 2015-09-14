SMTP MTA
========

Firewall rules needed for SMTP MTA.

.. contents:: \ 


Port Forwards
-------------

The following IPv4 connections from the Internet to the router are forwarded to
the mail server.

SMTP Mail Server
^^^^^^^^^^^^^^^^

Forward SMTP connections to the mail server.

Using the OpenWRT web GUI, go to `Network 
<https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall 
<https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Port Forwards 
<https://router.lan/cgi-bin/luci/admin/network/firewall/forwards/>`_ and add a 
**new port forward**:

==================== ====================
Name                 SMTP Port Forwarding
Protocol             TCP
Source Zone          wan
Source MAC address   
Source IP address    any
Source port          any
External IP address  any
External port        25
Internal zone        lan
Internal IP address  |mailserverIPv4|
Internal port        25
Enable NAT loopback  checked
Extra arguments
==================== ====================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # SMTP Port Forwarding
    :end-before: # IMAP Port Forwarding


Traffc Rules
------------


SMTP to MTA (IPv4)
^^^^^^^^^^^^^^^^^^

Allow IPv4 SMTP connections from anywhere to the mail server.

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Traffic Rules <https://router.lan/cgi-bin/luci/admin/network/firewall/rules/>`_ and add a **new forward rule**:

========================== ==================
Name                       SMTP to MTA (IPv4)
Restrict to address family IPv4 only
Protocol                   TCP
Match ICMP type            any
Source zone                Any zone
Source MAC address         any
Source address             any
Source port                any
Destination zone           lan
Destination address        |mailserverIPv4|
Destination port           25
Action                     accept
Extra arguments
========================== ==================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # SMTP to MTA (IPv4)
    :end-before: # SMTP to MTA (IPv6)


SMTP to MTA (IPv6)
^^^^^^^^^^^^^^^^^^

Allow IPv6 SMTP connections from anywhere to the mail server.

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Traffic Rules <https://router.lan/cgi-bin/luci/admin/network/firewall/rules/>`_ and add a **new forward rule**:

========================== ==================
Name                       SMTP to MTA (IPv6)
Restrict to address family IPv6 only
Protocol                   TCP
Match ICMP type            any
Source zone                Any zone
Source MAC address         any
Source address             any
Source port                any
Destination zone           lan
Destination address        |mailserverIPv6|
Destination port           25
Action                     accept
Extra arguments
========================== ==================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # SMTP to MTA (IPv6)
    :end-before: # SMTP from MTA (IPv4)


SMTP from MTA (IPv4)
^^^^^^^^^^^^^^^^^^^^

Allow IPv4 SMTP connections from the mail server to anywhere.

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Traffic Rules <https://router.lan/cgi-bin/luci/admin/network/firewall/rules/>`_ and add a **new forward rule**:

========================== ====================
Name                       SMTP from MTA (IPv4)
Restrict to address family IPv4 only
Protocol                   TCP
Match ICMP type            any
Source zone                lan
Source MAC address         any
Source address             |mailserverIPv4|
Source port                any
Destination zone           Any zone (forward)
Destination address        any
Destination port           25
Action                     accept
Extra arguments
========================== ====================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # SMTP from MTA (IPv4)
    :end-before: # SMTP from MTA (IPv6)


SMTP from MTA (IPv6)
^^^^^^^^^^^^^^^^^^^^

Allow IPv6 SMTP connections from the mail server to anywhere.

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Traffic Rules <https://router.lan/cgi-bin/luci/admin/network/firewall/rules/>`_ and add a **new forward rule**:

========================== ====================
Name                       SMTP from MTA (IPv6)
Restrict to address family IPv6 only
Protocol                   TCP
Match ICMP type            any
Source zone                lan
Source MAC address         any
Source address             |mailserverIPv6|
Source port                any
Destination zone           Any zone (forward)
Destination address        any
Destination port           25
Action                     accept
Extra arguments
========================== ====================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # SMTP from MTA (IPv6)
    :end-before: # Block all other SMTP

Block all other SMTP
^^^^^^^^^^^^^^^^^^^^

Block all other SMTP connections in and out. This is known as SMTP port
management and helps to prevent infectced personal computers to send spam.

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Traffic Rules <https://router.lan/cgi-bin/luci/admin/network/firewall/rules/>`_ and add a **new forward rule**:

========================== ====================
Name                       Block all other SMTP
Restrict to address family IPv4 and IPv6
Protocol                   TCP
Match ICMP type            any
Source zone                Any zone
Source MAC address         any
Source address             any
Source port                any
Destination zone           Any zone (forward)
Destination address        any
Destination port           25
Action                     reject
Extra arguments
========================== ====================

Using the firewall configuration file 
:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # Block all other SMTP
    :end-before: # SUBMISSION Mail
