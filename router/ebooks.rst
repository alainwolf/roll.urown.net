eBook Library Server
====================

Port Forwards
-------------

The following IPv4 connections from the Internet to the router are forwarded to
the HTTP server.

Using the OpenWRT web GUI
^^^^^^^^^^^^^^^^^^^^^^^^^

Using the OpenWRT web GUI, go to `Network <https://router.lan/cgi-bin/luci/admin/network/>`_ - `Firewall <https://router.lan/cgi-bin/luci/admin/network/firewall/>`_ - `Port Forwards <https://router.lan/cgi-bin/luci/admin/network/firewall/forwards/>`_ and add a **new port forward**:

==================== ====================
Name                 HTTP Port Forwarding
Protocol             TCP
Source Zone          wan
Source MAC address   
Source IP address    any
Source port          any
External IP address  any
External port        80
Internal zone        lan
Internal IP address  |HTTPserverIPv4|
Internal port        443
Enable NAT loopback  checked
Extra arguments
==================== ====================

==================== =====================
Name                 HTTPS Port Forwarding
Protocol             TCP
Source Zone          wan
Source MAC address   
Source IP address    any
Source port          any
External IP address  any
External port        443
Internal zone        lan
Internal IP address  |HTTPserverIPv4|
Internal port        443
Enable NAT loopback  checked
Extra arguments
==================== =====================


Using the firewall configuration file 
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/config/firewall <config/firewall>` on the OpenWRT router:

.. literalinclude:: config/firewall
    :language: lua
    :start-after: # HTTP Port Forwarding
    :end-before: # SMTP Port Forwarding


Traffc Rules
------------

