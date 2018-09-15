:orphan:

.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right

Tor Relay
=========

Installation
------------

Install the tor package::

    $ opgk update
    $ opkg install tor tor-fw-helper tor-geoip


Configuration
-------------

Edit :file:`/etc/tor/torrc`:

.. code-block:: ini
   :linenos:
   :emphasize-lines: 13

    SocksPort 192.0.2.1:9100
    SocksPolicy accept 192.0.2.0/24
    SocksPolicy reject *
    Log notice file /var/log/tor/notices.log
    RunAsDaemon 1
    DataDirectory /var/lib/tor
    ORPort 110
    OutboundBindAddress 192.0.2.1
    Nickname Example
    RelayBandwidthRate  12500 KB # Throttle traffic to 12.5 MB/s (100 Mbps)
    RelayBandwidthBurst 25000 KB # But allow bursts up to 25 MB/s (200 Mbps)
    DirPort 9030 # what port to advertise for directory connections
    ExitPolicy reject *:* # no exits allowed
    User tor


Allow access to the data directory:

::

    $ chmod +x /var /var/lib


(Re-)Start
----------

::

    $ /etc/init.d/tor start



Reference
---------

 * https://trac.torproject.org/projects/tor/wiki/doc/OpenWRT
 * https://www.torproject.org/docs/tor-doc-relay