Bridged Access Point
====================

In some cases you want to use your OpenWRT router as wireless access point
only, without any routing, firewall and DNS or DHCP functionality.

This might be the case, when you already have a capable router device, but it
has no adequate Wireless capability or you want improve your wireless
connectivity by deploying additional access points in a larger area.


Ethernet Ports
--------------

Don't use the WAN port!

Use any of the available LAN ports to connect your device to the LAN. 


Network Configuration
---------------------

The LAN network for an OpenWRT Access Point is nearly the same as for a
Router. Some things to look out for:

 #. Make sure not to use the same LAN IP address as the router.
 #. Disable DHCP on all interfaces.
 #. Don't configure the WAN interface.
 #. Set up static default routes pointing to your router.


:file:`/etc/config/network`::

    config interface 'lan'
        option type 'bridge'
        option ifname 'eth0'
        option _orig_ifname 'eth0 wlan0 wlan1'
        option _orig_bridge 'true'
        option proto 'static'
        option ipaddr '192.0.2.2'
        option netmask '255.255.255.0'
        option gateway '192.0.2.1'
        option broadcast '192.0.2.255'
        option dns '192.0.2.2 192.0.2.1'
        option ip6gw 'fe80::4e5e:cff:fe40:11a5'
        option ip6addr '2001:db8:c0de:10:2cb0:5dff:fe7f:2dba/64'

    config interface 'wan'
        option ifname 'eth1'
        option proto 'dhcp'
        option auto '0'

    config interface 'wan6'
        option ifname 'eth1'
        option proto 'dhcpv6'
        option auto '0'
        option reqaddress 'try'
        option reqprefix 'auto'

    config route
        option interface 'lan'
        option target '0.0.0.0'
        option netmask '0.0.0.0'
        option gateway '192.0.2.1'

    config route6
        option interface 'lan'
        option target '::/0'
        option gateway 'fe80::4e5e:cff:fe40:11aa'
        option metric '1024'


:file:`/etc/config/dhcp`::

    config dhcp 'lan'
        option interface 'lan'
        option ignore '1'


Wireless Network
----------------

Setup Wireless as usual. 

If you have multiple access points ...

 #. Use the same SSID (wireless network name) and PSK (Wi-Fi password) on all
    access points and the router in your network. Clients will automatically
    select the nearby station with the best connection quality.
 #. Use different radio channels or set them up to auto-select channels,
    to minimize radio interference between the stations.


Disable unused Services
-----------------------

Many services are not needed on device used only as access point.

Disable at least the following services, as they might interfere with your
router and network:

 * Firewall
 * Dnsmasq, DHCP and DNS service
 * odhcp, IPv6 DHCP server

::

    router$ /etc/init.d/firewall disable 
    router$ /etc/init.d/firewall stop 

    router$ /etc/init.d/dnsmasq disable 
    router$ /etc/init.d/dnsmasq stop

    router$ /etc/init.d/odhcp disable 
    router$ /etc/init.d/odhcp stop


Depending on the desired setup, the OpenWRT device can still be of use for
other services as fail-over or load-balancing. For exampleits common to
have multiple DNS resolvers in a network.


References
----------

 * `OpenWrt User Guide » Network » WiFi configuration » Dumb AP / Access Point Only <https://openwrt.org/docs/guide-user/network/wifi/dumbap>`_
 * `OpenWrt User Guide » Network » WiFi configuration » Bridged AP <https://openwrt.org/docs/guide-user/network/wifi/bridgedap>`_
