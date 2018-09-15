.. image:: Electrum-logo.*
    :alt: Electrum Logo
    :align: right

Electrum Server
===============

`Electrum <https://electrum.org/>`_ is a lightweight Bitcoin wallet.

Electrum's focus is speed, with low resource usage and simplifying Bitcoin.
Startup times are instant because it operates in conjunction with
`Electrum Servers <https://github.com/spesmilo/electrum-server/>`_ that handle
the most complicated parts of the Bitcoin system.

Electrum Servers are run by volunteers around the Internet.

This document describes how to setup an Electrum Server who will be reachable
over IPv4, IPv6 and as Hidden Service over the Tor network.

.. contents:: \


Prerequisites
-------------

 * A :doc:`TLS certificate </server/server-tls>`.


Storage Space
^^^^^^^^^^^^^

The Electrum database needs another 17 GB of storage, additionally to the
~ 40 GB of a Bitcoin Node.

To check the  available free space of the disk who will hold the Electrum
database::

    $ df -h /var/lib
    Filesystem                   Size  Used Avail Use% Mounted on
    /dev/mapper/server--vg-root  456G  102G  331G  24% /


Bitcoin Full Node
^^^^^^^^^^^^^^^^^

The Electrum Server relies on a installed and running :doc:`bitcoin-full-node`.
The bitcoin node should have processed all blocks and caught up to the current
height of the network.

The Electrum server needs to be able to communicate with the Bitcoin node trough
RPC.

Additionally the Bitcoin Node needs to maintain a full index of historical
transaction IDs, a feature which is not enabled by default.

To enabled this, the following line needs to be added to the Bitcoin
configuration file :file:`/etc/bitcoin/bitcoin.conf`:

.. code-block:: ini

    # Maintain a full index of historical transaction IDs
    # Required for Electrum Server
    txindex=1


Don't forget to re-adjust the file ownership if it was edited by the root user::

    $ sudo chown -R bitcoin:bitcoin /etc/bitcoin


If this was not the case before on a running Bitcoin Node, the blockchain index
needs to be rebuilt. Which means, shut down the Bitcoin service and start a full
re-index. Since this can take again several hours or even days to complete its
strongly recommended to run this in a screen session::

    $ sudo stop bitcoind
    $ sudo -u bitcoin \
        bitcoind -conf=/etc/bitcoin/bitcoin.conf \
                 -datadir=/var/lib/bitcoind \
                 -daemon -server -disbalewallet \
                 –reindex


IP Addresses & DNS Records
^^^^^^^^^^^^^^^^^^^^^^^^^^

We use the same IP addresses and hostname as our Bitcoin node:

 * |BitcoinIPv6| as global public IPv6 address;
 * |BitcoinIPv4| as private local IPv4 address (port forwarded from the public IPv4 address);
 * |publicIPv4| as the ISP provided dynamic public Internet address;


================ ==== ============================================ ======== ===
Name             Type Content                                      Priority TTL
================ ==== ============================================ ======== ===
btc              A    |publicIPv4|                                          300
btc              AAAA |BitcoinIPv6|
================ ==== ============================================ ======== ===


Firewall Rules
^^^^^^^^^^^^^^

Electrum Server listens on TCP ports **50001** and **50002** for incoming
connections. Port 50001 is for plain unencrypted connections and port 50002 is
TLS encrypted. We allow only secured connections on IPv4 and IPv6.


IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
TCP      50002     |BitcoinIPv4|             Electrum Server TLS Connections
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
TCP      50002     |BitcoinIPv6|             Electrum Server TLS Connections
======== ========= ========================= ==================================


Tor Hidden Service
^^^^^^^^^^^^^^^^^^

We also use the same Hidden Service \*.onion address for our BitCoin full Node
and the Electrum Server. But since Electrum Server can not be persuaded to
listen on multiple IP addresses (except all of them, which we don't want), we
tell the Tor client to proxy the eth0 IP |BitcoinIPv4| of the server instead of
the usual localhost.

Add the following two highlighted lines to our Bitcoin Hidden Service by editing
:file:`/etc/tor/torrc`:

.. code-block:: bash
    :emphasize-lines: 5,6

    # BitCoin Full Node & Electrum Server Hidden Service for btc.example.net
    HiddenServiceDir /var/lib/tor/hidden_services/bitcoin
    HiddenServicePort 8333
    HiddenServicePort 18333
    HiddenServicePort 50001 192.0.2.39:50001
    HiddenServicePort 50002 192.0.2.39:50002

Reload the Tor client::

    $ sudo service tor reload

The \*.onion hostname is found in the file
:file:`/var/lib/tor/hidden_services/bitcoin/hostname`::

    $ sudo cat /var/lib/tor/hidden_services/bitcoin/hostname
    duskgytldkxiuqc6.onion


Electrum Server User
^^^^^^^^^^^^^^^^^^^^

For security reasons its best to run the server with its own unprivileged user
profile. Create this user on the server system with the following command::

    $ sudo adduser --system --group --home /var/lib/electrum electrum


Software Installation
---------------------


Software Dependencies
^^^^^^^^^^^^^^^^^^^^^

Electrum Server is a Python program and depends on various Python libraries::

    $ sudo apt-get install python-setuptools python-openssl python-leveldb libleveldb-dev
    $ sudo easy_install jsonrpclib irc plyvel


Download
^^^^^^^^

The Electrum Server software is not available as installable software package.
They don't seem to release versions either. Instead the software is installed
directly from the source code repository on GitHub::

    $ cd /var/lib/electrum
    $ sudo -Hu electrum git clone https://github.com/spesmilo/electrum-server.git

Install
^^^^^^^

You can see from the output below, that the next step takes several hours too.
Because of the 13 GB database download.

::

    $ cd electrum-server
    $ sudo ./configure


.. code-block:: text

    Creating config file
    username for running daemon (default: electrum)
    Path for database (default: /var/electrum-server) /var/lib/electrum/electrum-db
    Database not found in /var/lib/electrum/electrum-db.
    Do you want to download it from the Electrum foundry to /var/lib/electrum/electrum-db ? y
    -2015-04-27 20:09- http://foundry.electrum.org/leveldb-dump/electrum-fulltree-100-latest.tar.gz
    Resolving foundry.electrum.org (foundry.electrum.org)... 78.46.103.75
    Connecting to foundry.electrum.org (foundry.electrum.org)|78.46.103.75|:80... connected.
    HTTP request sent, awaiting response... 200 OK
    Length: 14266991234 (13G) [application/x-gzip]
    Saving to: ‘STDOUT’

    100%[=====================================================>] 14'266'991'234  947KB/s   in 2h 3m

    2015-04-27 22:12:25 (1.84 MB/s) - written to stdout [14'266'991'234/14'266'991'234]

    rpcuser (from your bitcoin.conf file):
    rpcpassword (from your bitcoin.conf file): ********
    Configuration written to /etc/electrum.conf.
    Please edit this file to finish the configuration.
    If you have not done so, please run 'python setup.py install'
    Then, run 'electrum-server' to start the daemon


The Python installation script, will build and install the electrum-server
executable in :file:`/usr/local/bin/electrum-server`::

    $ sudo python setup.py install


Configuration
^^^^^^^^^^^^^

The installation script created a configuration file
:download:`/etc/electrum.conf <config-files/electrum.conf>` and filled parts of
it for us, but it still needs a little bit of work:

.. literalinclude:: config-files/electrum.conf
    :language: ini


The following steps are done as the **electrum** user in his home directory
:file:`/var/lib/electrum` on the server::

    $ sudo -u electrum -Hs
    $ cd ~


References
----------
 * https://github.com/spesmilo/electrum-server/blob/master/HOWTO.md
 * https://rossbennetts.com/2015/04/howto-install-electrum-server/
