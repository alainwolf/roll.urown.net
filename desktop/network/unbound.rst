
Domain Name Resolver
====================

Here is how we handle Domain Name resolving on the desktop.


A little History
----------------

There where lots of changes with DNS resolving in Linux and Ubuntu Desktop.


In the beginning there was just a :file:`/etc/resolve.conf` file pointing to
your LANs or ISP DNS resolvers, either managed by your **DHCP client** or you 
just inserted the lines of your ISPs or Company DNS servers yourself::

    # /etc/resolve.conf
    nameserver 77.109.128.2
    nameserver 213.144.129.20


The more connected and mobile we became, the less this was enough. Connection
and network changes need to be managed instantly and automatically for a very
wide range of situations:
    
    * home-, office- or commute-networks (private car, public transport, car-sharing?)
    * private or public networks. 
    * secured or unsecured WiFi networks. 
    * free, paid, metered or unmetered data-plans
    * wired, wireless, mobile, bluetooth connection

This led to a lot of moving parts in the management of network connections and
DNS resolving as a integral part of it:

Already in 2006 **Network Manager** came along to help the Desktop user
switching network configurations. Also in this Year, Canonical introduced
**Upstart** as its own alternative to the **init.d** system which traditionally
manages system services.

By 2012 **Dnsmasq** would be installed as the standard local caching resolver.
By that time, there was already an open war between all these tools, on who gets
to decide whats written into :file:`/etc/resolv.conf`. Therefore **resolvconf**
had to be introduced. A tool, to control which tool controls
:file:`/etc/resolv.conf`. Also IPv6 privacy extensions where turned on by
default.

In 2015 Ubuntu **Systemd** replaced Canonicals own **Upstart**, but left DNS
resolving still in the hands of **Dnsmasq**.

In 2017 **systemd-resolved** replaced **Dnsmasq**, which up to today (2020) is
still used as default local DNS resolver.

None of these worked particularly great, especially if you rely on
:term:`DNSSEC`.


DNS Today
---------

In the wake of Edwards Snowdens global surveillance disclosures in 2013, a lot
of effort was made to increase security and privacy on the Internet, which lead
to a lot of improvements in the Web, Mail, Instant Messaging and many others.
But strange enough not on the service all others rely on: Which is DNS.

But in the last years, DNS security finally got more attention, not on only from
a trust persepective (DNSSEC) but also in the view of concerns with privacy and
censorship. Which in turn led to the introduction of new technologies like
:term:`DNS-over-HTTPS`, :term:`DNS-over-TLS` and :term:`DNSCrypt`.


Unbound and dnssec-trigger
--------------------------

In this document we will setup **unbound** as local DNS resolver on the Desktop. 

Additionally **dnssec-trigger** will test the upstream resolvers (of your local
network, your ISP, mobile provider or coffee-shop) will be tested if they are
able handle DNSSEC correctly.

Additionally **dnssec-trigger** also handles some special cases, like captive
portals in public WiFi networks.

If they do, they are used as upstream resolvers. If the don't, the local
**unbound** daemon will not use them and do all the resolving by itself,
bypassing any insecure upstream DNS resovler.

This is done by **NetowrkManager** calling **dnssec-trigger** on connection
changes, who performs its series of tests to asses the current situation and
subsequently writes the relevant options into the **unbound** configuration
files and finally instructing **unbound** to reload itself with the current
settings.


.. image:: unbound-logo.*
    :alt: unbound Logo
    :align: right


Unbound DNS Resolver
--------------------

`Unbound <https://nlnetlabs.nl/projects/unbound/about/>`_ is a validating,
recursive, caching DNS resolver. It is designed to be fast and lean and
incorporates modern features based on open standards. Late 2019, Unbound has
been rigorously audited, which means that the code base is more resilient than
ever.

To help increase online privacy, Unbound supports :term:`DNS-over-TLS` and
:term:`DNS-over-HTTPS` which allows clients to encrypt their communication. In
addition, it supports various modern standards that limit the amount of data
exchanged with authoritative servers. These standards do not only improve
privacy but also help making the DNS more robust. The most important are *Query
Name Minimisation*, the *Aggressive Use of DNSSEC-Validated Cache* and support
for *authority zones*, which can be used to load a copy of the root zone.


Unbound Installation
^^^^^^^^^^^^^^^^^^^^

The Unbound server is in the Ubuntu software repository::

    $ sudo apt install unbound


Disable Default Resolver
^^^^^^^^^^^^^^^^^^^^^^^^

Since we shouldn't run two different resolvers on the system, we disable the
default one::

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

    $ sudo systemctl reload unbound.service
    $ sudo undbound-control-setup


DNSSEC-Trigger Daemon
---------------------

`DNSSEC-Trigger <https://nlnetlabs.nl/projects/dnssec-trigger/about/>`_ is
experimental software that enables your computer to use DNSSEC protection for
the DNS traffic.

DNSSEC-Trigger relies on the Unbound DNS resolver running locally on your
system, which performs DNSSEC validation. It reconfigures Unbound in such a way
that it will signal it to to use the DHCP obtained forwarders if possible,
fallback to doing its own AUTH queries if that fails, and if that fails it will
prompt the user with the option to go with insecure DNS only. The software is
open source and uses the BSD license.


DNSSEC-Trigger Installation
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The DNSSEC-Trigger is in the Ubuntu software repository::

    $ sudo apt install dnssec-trigger


DNSSEC-Trigger Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

DNSSEC-Trigger uses two configuration files in the :file:`/etc/dnssec-trigger/`
directory.

The file :file:`dnssec-trigger.conf` controls how **dnssec-trigger** dameon is
working. Documentation is found on the
`dnssec-trigger.conf(8) <https://manpages.ubuntu.com/manpages/focal/en/man8/dnssec-trigger.conf.8.html>`_
man page and in the comments inside the configuration file.

The file :file:`dnssec.conf` controls the **dnssec-trigger-script**. The script
is called when after changes of network connectoins have been detected and
re-configures your unbound DNS resolver. There is no man page for this
configuration file, but the comments inside it file describe all the options.


Intitial Setup
^^^^^^^^^^^^^^

Call :file:`dnssec-trigger-control-setup` to setup keys and certificates for
dnssec-trigger to securely interact with the unbound daemon and restart the
service after that::

    $ sudo dnssec-trigger-control-setup
    $ sudo systemctl restart dnssec-triggerd.service


Network Manager Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is how we create a perfect harmony between **Network Manager**,
**dnssec-trigger** and **unbound**.

Tell network manager not to bother with **systemd-resolved** by creating the
file :file:`/etc/NetworkManager/conf.d/no-systemd-resolved.conf`::

    [main]
    systemd-resolved=false


By creating the file :file:`/etc/NetworkManager/conf.d/unbound-dns.conf` we tell
network manager that **unbound** and **dnssec-trigger** will be taking care of
things and not to interfere::

    # Configuration file for NetworkManager.
    # See "man 5 NetworkManager.conf" for details.
    [main]

    # NetworkManager will talk to unbound and dnssec-triggerd, using "Conditional
    # Forwarding" with DNSSEC support. 
    dns=unbound

    # NetworkManager should not touch /etc/resolv.conf, as it will be managed by
    # the dnssec-trigger daemon.
    rc-manager=unmanaged


Restart the Network Manager service, after saving and closing the configuration
file::

    $ sudo systemctl restart NetworkManager.service


References
----------

* `The DNS Privacy Project <https://dnsprivacy.org/wiki/>`_
