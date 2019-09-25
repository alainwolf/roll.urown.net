Network
=======

Local DNS Resolvers
-------------------

There where lots of changes with DNS resolving in Ubuntu Desktop.

In the beginning there was just a :file:`/etc/resolve.conf` file pointing to your
LANs or ISP DNS resolvers, usually managed by your **DHCP client**.

**Gnome Network-Manager** came along and soon after DNSMasq would be installed as
local cache.

Then **resolveconf** was introduced. 

Not long after that all was moved out again in favor of **systemd-resolved**.

None of these worked particularly great, especially if you rely on DNSSEC.

Therefore I prefer to use **unbound** as local DNS resolver on the Desktop. 

Together wit the help of **dnssec-trigger** the local LAN or your ISPs
resolvers will be tested if they are able handle DNSSEC correctly.

If they do, they are used as upstream resolvers. If the don't, the local
unbound daemon will not use them and do all the resolving by itself.

Additionally some special cases like captive portals for WiFi networks are
also handled.


Software Installation
^^^^^^^^^^^^^^^^^^^^^

::

	$ sudo apt install unbound dnssec-trigger
	$ sudo systemctl stop systemd-resolved.service resolvconf.service
	$ sudo systemctl disable systemd-resolved.service resolvconf.service


Unbound Configuration
^^^^^^^^^^^^^^^^^^^^^

Unbound's remote control must be enabled, for dnssec-trigger to be able to
control it. Create a file called
:file:`/etc/unbound/unbound.conf.d/remote-control.conf` with the following
content::

	# Remote control config section.
	remote-control:
		# Enable remote control with unbound-control(8) here.
		# set up the keys and certificates with unbound-control-setup.
		# Default: no
		control-enable: yes

Unbound's remote control is protected by certificates. To setup the required
key-files call the :file:`unbound-control-setup-command` after saving and
closing the configuration file and reloading the unbound server::

	$> sudo systemctl reload unbound.service
	$> sudo undbound-control-setup


DNSSEC-Trigger Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Open the file :file:`/etc/dnssec-trigger.conf` to set some general options::

	# the domain example.com line (if any) to add to resolv.conf(5). default none.
	# domain: "example.net"

	# domain name search path to add to resolv.conf(5). default none.
	# the search path from DHCP is not picked up, it could be used to misdirect.
	# search: "example.com"

	# Forward RFC 1918 private addresses to global forwarders
	use-private-addresses: yes


Open the file :file:`/etc/dnssec.conf`::

	# Ensures that foward zones provided by NetworkManager connections will be
	# validated by Unbound.
	validate_connection_provided_zones=yes

	#  - Domains provided by WiFi connection will be ignored.
	add_wifi_provided_zones=no

	# Enable or disable writing of search domains to `/etc/resolv.conf`.
	set_search_domains=yes

	# Enable or disable adding reverse name resolution zones derived from
	# private IP addresses as defined in RFC 1918 and RFC 4193.
	use_private_address_ranges=yes


Call :file:`dnssec-trigger-control-setup` to setup keys and certificates for
dnssec-trigger to securely interact with the unbound daemon and restart the
service after that::

	$> sudo dnssec-trigger-control-setup
	$> sudo systemctl restart dnssec-triggerd.service


.. warning::

	At the time of this writing there is a 
	`serious bug (#4218) <https://www.nlnetlabs.nl/bugs-script/show_bug.cgi?id=4218>`_ 
	in the current dnssec-triggerd daemon version 0.17.

	dnssec-triggerd is very likely to crash soon after startup, leaving you without DNS resolution.


Here is a partial and temporary workaraound:

 #. Copy the file :file:`/lib/systemd/system/dnssec-triggerd.service` to :file:`/etc/systemd/system/`::

 	$> sudo cp /lib/systemd/system/dnssec-triggerd.service /etc/systemd/system/


 #. Open the file :file:`/etc/systemd/system/dnssec-triggerd.service` and comment out line 13 "ExecStartPost=-/usr/lib/dnssec-trigger/dnssec-trigger-script --update_all"::

	[Unit]
	Description=Reconfigure local DNSSEC resolver on connectivity changes
	After=NetworkManager.service unbound.service dnssec-triggerd-keygen.service
	Requires=unbound.service
	Wants=dnssec-triggerd-keygen.service

	[Service]
	PIDFile=/run/dnssec-triggerd.pid
	Type=simple
	Restart=always
	ExecStart=/usr/sbin/dnssec-triggerd -d
	ExecStartPre=-/usr/lib/dnssec-trigger/dnssec-trigger-script --prepare
	#ExecStartPost=-/usr/lib/dnssec-trigger/dnssec-trigger-script --update_all
	ExecStopPost=-/usr/lib/dnssec-trigger/dnssec-trigger-script --cleanup

	[Install]
	WantedBy=multi-user.target

 
 #. Save and close the file, then reload your services to activate the changes you just made::

 	$> sudo systemctl daemon-reload


 #. Restart the dnssec-triggerd daemon::

 	$> sudo systemctl restart dnssec-triggerd.service



Gnome Network Manager Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is how we create a perfect harmony between **Gnome Network Manager**,
**dnssec-trigger** and **unbound**.

Tell network manager not to bother with **systemd-resolved** by creating the
file :file:`/etc/NetworkManager/conf.d/no-systemd-resolved.conf`::

	[main]
	systemd-resolved=false

Tell network manager that **unbound** and **dnssec-trigger** will be taking care of things. by creating the
file :file:`/etc/NetworkManager/conf.d/unbound-dns.conf`::

	# Configuration file for NetworkManager.
	# See "man 5 NetworkManager.conf" for details.
	[main]

	# NetworkManager will talk to unbound and dnssec-triggerd, using "Conditional
	# Forwarding" with DNSSEC support. /etc/resolv.conf will be managed by
	# dnssec-trigger daemon.
	dns=unbound

	# Don't touch /etc/resolv.conf
	rc-manager=unmanaged


Restart the Network Manager service, after saving and closing the configuration file::

	$> sudo systemctl restart NetworkManager.service



DNS Updates
-----------

Non-servers, like personal computers, desktop or laptops/notebooks usually get
a dynamic temporary address. Portable devices might connect from different
networks.

The :file:`nsupdate` programm can contact your :doc:`domain name server
</server/dns/powerdns>` and update your hostname with the current address.

Nowadays NetworkManager is in charge of all these things, so updates should be
managed by that too.

TBD


TSIG key
^^^^^^^^

TBD


VPN
---

TBD
