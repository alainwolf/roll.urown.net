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


Configuration
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


Root Server Updates
^^^^^^^^^^^^^^^^^^^

The “root hints file” contains the names and IP addresses of the root servers,
so that a resolver can bootstrap the DNS resolution process. The list is
built-in most DNS server software, but changes from time to time.

The following script
:download:`/root/root-servers-update <files/root/root-servers-update>` checks
for newer versions online, downloads and installs if necessary.

.. literalinclude:: files/root/root-servers-update
   :linenos:


Configuration Files
-------------------

However, the init-script will still insist to copy our configuration files from
:file:`/etc/unbound/*` to :file:`/var/lib/unbound/` before the service starts.

This is to minimise strain on the flash memory chips, because unbound rewrites
part of its configuration files, like encryption keys, periodically.

The unbound binaries provided by OpenWrt with opkg, all have hard-coded
:file:`/var/lib/unbound/` as the default configuration directory to use.

The init-script will however not copy any subdirectories from
:file:`/etc/unbound/*` to :file:`/var/lib/unbound/`. So be avare, to reference
included configuration files with their full path to the :file:`/etc/unbound/`
directory.

Example::

    # File to read root hints.
    root-hints: "ICANN.cache" # <-- this will be read from /var/lib/unbound

    # Upstream DNS reslovers
    include: "myisp-resolver.conf" # <-- this will be read from /var/lib/unbound

    # Local Zones Settings
    include: "/etc/unbound/local-zones.d/*.conf" # <-- fully qualifed path specified.


Remote Control Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/remote-control.conf <files/etc/unbound/unbound.conf.d/remote-control.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/remote-control.conf
   :language: ini
   :linenos:


Main Configuration File
^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf <files/etc/unbound/unbound.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf
   :language: ini
   :linenos:


Access Control Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/access-control.conf <files/etc/unbound/unbound.conf.d/access-control.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/access-control.conf
   :language: ini
   :linenos:


Security and Privacy Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/security.conf <files/etc/unbound/unbound.conf.d/security.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/security.conf
   :language: ini
   :linenos:


Unbound DNSSEC Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/dnssec.conf <files/etc/unbound/unbound.conf.d/dnssec.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/dnssec.conf
   :language: ini
   :linenos:


Upstream Resolvers
^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/upstream-resolvers.conf <files/etc/unbound/unbound.conf.d/upstream-resolvers.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/upstream-resolvers.conf
   :language: ini
   :linenos:


Downstream DNS-over-TLS (DoT)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/unbound/unbound.conf.d/dns-over-tls.conf <files/etc/unbound/unbound.conf.d/dns-over-tls.conf>`

.. literalinclude:: files/etc/unbound/unbound.conf.d/dns-over-tls.conf
   :language: ini
   :linenos:


.. -*- mode: rst; tab-width: 4; indent-tabs-mode: nil -*-
