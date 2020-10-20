.. image:: unbound-logo.*
    :alt: unbound Logo
    :align: right

DNS Resolver
============

.. contents::


`Unbound <https://unbound.net/>`_ is a validating, recursive, and caching DNS
server software product from NLnet Labs, VeriSign Inc., Nominet, and Kirei. It
is distributed free of charge in open source form under the BSD license.

Unbound is designed as a set of modular components that incorporate modern
features, such as enhanced security (DNSSEC) validation, Internet Protocol
Version 6 (IPv6), and a client resolver application programming interface
library as an integral part of the architecture. Originally written for POSIX-
compatible Unix-like operating system, it runs on FreeBSD, OpenBSD, NetBSD, OS
X, and Linux, as well as Microsoft Windows.

OpenWrt uses `dnsmasq <http://www.thekelleys.org.uk/dnsmasq/doc.html>`_ as 
default pre-installed software as DHCP server and DNS resolver.

Since we already run Unbound as our DNS resolver of choice on other
:doc:`servers </server/dns/unbound>` and synchronize its configuration, we want
to use Unbound instead of dnsmasq on our OpenWrt router too.


Installation
------------

::
    
    $ opkg update
    $ opkg install unbound-daemon-heavy unbound-anchor unbound-control


Prerequisites
-------------

Disable dnsmasq Resolver
^^^^^^^^^^^^^^^^^^^^^^^^

Disable the default dnsmasq resolver, by settting the TCP listening port to 0.
This way only the DNS server is disabled, while it still might be used as DCHP
and TFTP services:

In :file:`/etc/config/dhcp`::

    config dnsmasq
        option port '0'


OpenWrt Integration
^^^^^^^^^^^^^^^^^^^

OpenWrt's unified configuration interface (UCI) does a lot of things with
Unbound. See :file:`/etc/init.d/unbound`. One reason is, the preservation of CPU
resources, memory and file-space on smaller devices, another is the conservation
of the flash memory, by limiting write operations, and finally it intergrates
the unbound services with OpenWrt's own upstream IPS DNS resolvers, leased out
DCHP server addresses and other things.

In our case, we don't need any of this. We therefore run unbound in "unmanaged"
mode.

In :file:`/etc/config/unbound`::

    config unbound
        option manual_conf '1'
        option root_age '9'
        option unbound_control '1'


In this manual mode, our unbound configuration in :file:`/etc/unbound/` is, for
the most part, left untouched.


Remote Control Setup
^^^^^^^^^^^^^^^^^^^^

Unbound remote server control utility :file:`unbound-control` performs remote
administration on the unbound DNS server. It reads the configuration file,
contacts the unbound server over a TLS encrypted connection, sends the command
and displays the result.

The connection requirees a set of self-signed certificates and private keys for
unbound-control client and the unbound server. The script
:file:`unbuond-control-setup` creates these::

    $ unbound-control-setup


Remote control still needs to be activated in the configuration. See under
"Remote Control" further down.


Root Server Updates
^^^^^^^^^^^^^^^^^^^

The “root hints file” contains the names and IP addresses of the root servers,
so that a resolver can bootstrap the DNS resolution process. The list is
built-in most DNS server software, but changes from time to time, it's therefore
considered as good practice to provide regularly updated root hints.

The following script
:download:`/root/root-hints-update <files/root/root-hints-update>` checks
for newer versions online, downloads and installs if necessary.

.. literalinclude:: files/root/root-hints-update
   :linenos:

Let's call the script once manually::

    $ /root/root-hints-update

Let's call this on a random weekday and time with cron::

    $ min="$(awk 'BEGIN{srand();print int(rand()*59)}')"
    $ hour=$(awk 'BEGIN{srand();print int(rand()*23)}')
    $ wday=$(awk 'BEGIN{srand();print int(rand()*7)}')
    echo "$min   $hour   *    *     $wday    /root/root-hints-update" >> /etc/crontabs/root


Local Settings
--------------

.. note::

    The init-script of OpenWrt will copy your configuration files from
    :file:`/etc/unbound/*` to :file:`/var/lib/unbound/` before the service
    starts, but without any subdirectories. The unbound binaries provided in
    OpenWrt have hard-coded :file:`/var/lib/unbound/` as their configuration
    directory. Keep that in mind when including configuration files in Unbonud
    for OpenWrt.

This is to minimise strain on the flash memory chips, because unbound rewrites
part of its configuration files, like encryption keys, periodically.


Main Configuration File
^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf <files/etc/unbound/unbound.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf
   :language: ini
   :linenos:


Performance Tuning
^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/tuning.conf <files/etc/unbound/tuning.conf>`

.. literalinclude:: files/etc/unbound/tuning.conf
   :language: ini
   :linenos:


Root Hints
^^^^^^^^^^

:download:`/etc/unbound/root-hints.conf <files/etc/unbound/root-hints.conf>`

.. literalinclude:: files/etc/unbound/root-hints.conf
   :language: ini
   :linenos:


Common Settings
---------------

Access Control
^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/access-control.conf <files/etc/unbound/unbound.conf.d/access-control.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/access-control.conf
   :language: ini
   :linenos:


DNS-over-TLS (DoT)
^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/dns-over-tls.conf <files/etc/unbound/unbound.conf.d/dns-over-tls.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/dns-over-tls.conf
   :language: ini
   :linenos:


DNSSEC
^^^^^^

:download:`/etc/unbound/unbound.conf.d/dnssec.conf <files/etc/unbound/unbound.conf.d/dnssec.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/dnssec.conf
   :language: ini
   :linenos:


Remote Control
^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/remote-control.conf <files/etc/unbound/unbound.conf.d/remote-control.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/remote-control.conf
   :language: ini
   :linenos:


Security and Privacy
^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/security.conf <files/etc/unbound/unbound.conf.d/security.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/security.conf
   :language: ini
   :linenos:


Upstream Settings
^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/upstream.conf <files/etc/unbound/unbound.conf.d/upstream.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/upstream.conf
   :language: ini
   :linenos:


Upstream Resolvers
^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/upstream-resolvers.d/init7.conf <files/etc/unbound/upstream-resolvers.d/init7.conf>`

.. literalinclude:: files/etc/unbound/upstream-resolvers.d/init7.conf
   :language: ini
   :linenos:


Local and Private Zones
-----------------------

Private Domains
^^^^^^^^^^^^^^^

Hostnames and domains which resolve to private IP addresses (e.g. 192.168.0.1)
are considered dangerous for so-called DNS-rebinding attacks. Therefore Unbound
does not pass down DNS answers to its clients, which contain private addresses.

The definition of which addreses are considered "private" is set with the
"private-address" configuration. See the section "Security and Privacy" where 
the :file:`security.conf` file listing is found.

The "private-domain" configuration setting, allows to define domains, which are 
allowed to contain private addreses.

We add our location specific subdomains, which a reachable on LAN and VPN
connections only,

:download:`/etc/unbound/local-zones.d/home.example.net.conf <files/etc/unbound/local-zones.d/home.example.net.conf>`

.. literalinclude:: files/etc/unbound/local-zones.d/home.example.net.conf
   :language: ini
   :linenos:


Stub Zones
^^^^^^^^^^

For some zones (aka Internet domains and subdomains), its difficult or not
possible to get a proper domain registration or DNSSEC delegation.

Some examples: 
  
  * Reverse DNS for private IPs;
  * Upstream is not secured with DNSSEC, and therefore also can't delegate;

On our own network, we still want these domains to be resolvable, reverse
lookups possible and all of this secured by DNSSEC.

With Unbound's "stub-zones", specific authoritative name servers can be set for
a domain. All queries about this domain will then direcly be asked to one of
these servers, instead of the usual lookups at the root and TLD servers.

If you also want to have DNSSEC validation for these a domaiin, you need to
define trust-anchors. 

To get the trust-anchor from your trusted authoritative name server::

    $ dig @dns1.example.net +nosplit -t DNSKEY 27.172.in-addr.arpa.
    27.172.in-addr.arpa.	40176	IN	DNSKEY	256 3 5 AwEAAa......xkenu7


:download:`/etc/unbound/local-zones.d/172.27.conf <files/etc/unbound/local-zones.d/172.27.conf>`

.. literalinclude:: files/etc/unbound/local-zones.d/172.27.conf
   :language: ini
   :linenos:


Overrides
^^^^^^^^^

Another special case are domains who's servers are picky from where they allow
to be queried.

The the spam DNS blacklist barracudacentral.org is one such example. For
understandable reasons. They require you to register a user profile and provide
the addresses of your servers, which require access to their data.

Of course DNS queries trough your usual upstream provider will no longer work.
Therefore we need to tell Unbound resolver to query their servers directly:

:download:`/etc/unbound/local-zones.d/barracudacentral.org.conf <files/etc/unbound/local-zones.d/barracudacentral.org.conf>`

.. literalinclude:: files/etc/unbound/local-zones.d/barracudacentral.org.conf
   :language: ini
   :linenos:



References
----------

 * `unbound.conf(5) manual <https://nlnetlabs.nl/documentation/unbound/unbound.conf/>`_
 * `Unbound on OpenWrt <https://openwrt.org/docs/guide-user/services/dns/unbound>`_
 * `Unbound with UCI <https://github.com/openwrt/packages/blob/openwrt-19.07/net/unbound/files/README.md>`_


.. -*- mode: rst; tab-width: 4; indent-tabs-mode: nil -*-
