Router Backup
=============

Goto `Sytem - Backup / Flash Firmware 
<https://router.lan/cgi-bin/luci/admin/system/flashops/>`_


Installed Packages
------------------

Create a list of all installed packages and save it to a file for later backup::

    $ opkg list-installed > /root/opkg-list-installed.txt


System Default Backup
---------------------

System default and installed packages backup:

 * :file:`/etc/config/ddns`
 * :file:`/etc/config/dhcp`
 * :file:`/etc/config/dropbear`
 * :file:`/etc/config/firewall`
 * :file:`/etc/config/luci`
 * :file:`/etc/config/network`
 * :file:`/etc/config/ntpclient`
 * :file:`/etc/config/openvpn`
 * :file:`/etc/config/openvpn.opkg`
 * :file:`/etc/config/qos`
 * :file:`/etc/config/radvd`
 * :file:`/etc/config/system`
 * :file:`/etc/config/ubootenv`
 * :file:`/etc/config/ucitrack`
 * :file:`/etc/config/uhttpd`
 * :file:`/etc/config/upnpd`
 * :file:`/etc/config/wifitoggle`
 * :file:`/etc/config/wireless`
 * :file:`/etc/dropbear/authorized_keys`
 * :file:`/etc/dropbear/dropbear_dss_host_key`
 * :file:`/etc/dropbear/dropbear_rsa_host_key`
 * :file:`/etc/firewall.user`
 * :file:`/etc/group`
 * :file:`/etc/hosts`
 * :file:`/etc/inittab`
 * :file:`/etc/ntp.conf`
 * :file:`/etc/openvpn/alainwolf.net.crl.pem`
 * :file:`/etc/openvpn/alainwolf.net_CA.cert.pem`
 * :file:`/etc/openvpn/dh1024.pem`
 * :file:`/etc/openvpn/dh2048.pem`
 * :file:`/etc/openvpn/home.alainwolf.net.cert.pem`
 * :file:`/etc/openvpn/home.alainwolf.net.key.pem`
 * :file:`/etc/openvpn/road-warrior-server.conf`
 * :file:`/etc/openvpn/tls-auth.key`
 * :file:`/etc/passwd`
 * :file:`/etc/profile`
 * :file:`/etc/rc.local`
 * :file:`/etc/shadow`
 * :file:`/etc/shells`
 * :file:`/etc/sysctl.conf`
 * :file:`/etc/uhttpd.crt`
 * :file:`/etc/uhttpd.key`
 * :file:`/etc/unbound/unbound.conf`


Manually added
--------------

Unbound DNS resolver:

 * :file:`/etc/unbound/ICANN.cache`
 * :file:`/etc/unbound/ORSN.cache`
 * :file:`/etc/unbound/root.key`
 * :file:`/etc/unbound/dlv.isc.org.key`
 * :file:`/etc/unbound/unbound.conf.d/local-zone.conf`
 * :file:`/etc/unbound/unbound.conf.d/root-auto-trust-anchor-file.conf`

Custom DNS resolver files:

 * :file:`/etc/resolv.conf.google`
 * :file:`/etc/resolv.conf.lan`
 * :file:`/etc/resolv.conf.local`

List of Installed software packages:

 * :file:`/root/opkg-list-installed.txt`





