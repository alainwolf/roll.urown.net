Bitcoin Full Node
=================

In this chapter we will install what is called a 
`full node <https://bitcoin.org/en/full-node>`_.

A full node is a program that fully validates transactions and blocks. Almost
all full nodes also help the network by accepting transactions and blocks from
other full nodes, validating those transactions and blocks, and then relaying
them to further full nodes.

Most full nodes also serve lightweight clients by allowing them to transmit
their transactions to the network and by notifying them when a transaction
affects their wallet. If not enough nodes perform this function, clients won’t
be able to connect through the peer-to-peer network — they’ll have to use
centralized services instead.

Many people and organizations volunteer to run full nodes using spare computing
and bandwidth resources — but more volunteers are needed to allow Bitcoin to
continue to grow. This document describes how you can help and what helping will
cost you.

The full node will be reachable over IPv4, IPv6 and as :doc:`Hidden Service
</server/tor/tor-hidden-service>` over the Tor network.


.. contents:: \ 


Prerequisites
-------------

Storage Space
^^^^^^^^^^^^^

The Bitcoin blockchain is very large and grows constantly. This is because every
Bitcoin mined and every transaction ever made is recorded in the blockchain.

As of April 2015 it is 32 Gigabytes. Along with indexes and other data a full
node occupies around 42 GB (Gigabytes) of disk storage space on the server.

You can see the growth of the blockchain over time on the
`Bitcoin Blockchain Size <https://blockchain.info/charts/blocks-size?timespan=all>`_ 
website.

To check the  available free space of the disk who will hold the Bitcoin database::

    $ df -h /var/lib
    Filesystem                   Size  Used Avail Use% Mounted on
    /dev/mapper/server--vg-root  456G  102G  331G  24% /


You can check the diskspace used by a running your full node as follows::

    $ sudo du -hs /var/lib/bitcoind/*|sort -h
    0       /var/lib/bitcoind/db.log
    20K     /var/lib/bitcoind/fee_estimates.dat
    84K     /var/lib/bitcoind/wallet.dat
    212K    /var/lib/bitcoind/debug.log
    952K    /var/lib/bitcoind/peers.dat
    732M    /var/lib/bitcoind/chainstate
    41G     /var/lib/bitcoind/blocks


IP Addresses
^^^^^^^^^^^^

This guide assumes we allocate the following IP addresses for our Bitcoin daemon:

 * |BitcoinIPv6| as global public IPv6 address;
 * |BitcoinIPv4| as private local IPv4 address (port forwarded from the public IPv4 address);
 * |publicIPv4| as the ISP provided dynamic public Internet address;

To add the IP addresses on the server::

    $ sudo ip addr add 192.0.2.39/24 dev eth0
    $ sudo ip addr add 2001:db8::39/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # btc.example.com
    iface eth0 inet static
        address 192.0.2.39/24
    iface eth0 inet6 static
        address 2001:db8::39/64


DNS Records
^^^^^^^^^^^

================ ==== ============================================ ======== ===
Name             Type Content                                      Priority TTL
================ ==== ============================================ ======== ===
btc              A    |publicIPv4|                                          300
btc              AAAA |BitcoinIPv6|
================ ==== ============================================ ======== ===

Check the "Add also reverse record" when adding the IPv6 entry.


Firewall Rules
^^^^^^^^^^^^^^

Bitcoin daemons listen on TCP ports 8333 and 18333 for incoming connections.

IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
TCP      8333      |BitcoinIPv4|             Bitcoin network
TCP      18333     |BitcoinIPv4|             Bitcoin test network
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
TCP      8333      |BitcoinIPv6|             Bitcoin network
TCP      18333     |BitcoinIPv6|             Bitcoin test network
======== ========= ========================= ==================================


Tor Hidden Service
^^^^^^^^^^^^^^^^^^

Add a Tor Hidden Service by editing :file:`/etc/tor/torrc`::

    # BitCoin Full Node Hidden Service for btc.example.com
    HiddenServiceDir /var/lib/tor/hidden_services/bitcoin
    HiddenServicePort 8333
    HiddenServicePort 18333

Reload the Tor client::

    $ sudo service tor reload

Read the newly generated \*.onion hostname::

    $ sudo cat /var/lib/tor/hidden_services/bitcoin/hostname
    duskgytldkxiuqc6.onion


Bitcoin Daemon User
^^^^^^^^^^^^^^^^^^^

For security reasons its best to run the daemon with its own unprivileged user
profile. Create this user on the server system with the following command::

    $ sudo adduser --system --group --home /var/lib/bitcoind bitcoin


Software Installation
---------------------

The Bitcoin reference software is not in the Ubuntu software packages
repository, we therefore add the Bitcoin Personal Package Archive (PPA) to your
system before installing the daemon::

    $ sudo apt-add-repository ppa:bitcoin/bitcoin
    $ sudo apt-get update
    $ sudo apt-get install bitcoind


Configuration
-------------

Create the configuration directory and an empty configuration file and also
adjust access rights::

    $ sudo mkdir /etc//bitcoin
    $ sudo touch /etc/bitcoin/bitcoin.conf
    $ sudo chmod 600 /etc/bitcoin/bitcoin.conf


We need a password for remote procedure calls to daemon. The program will create
it automatically if started without finding one:

.. code-block:: sh
    :emphasize-lines: 6

    $ bitcoind -conf=/etc/bitcoin/bitcoin.conf 
    Error: To use bitcoind, or the -server option to bitcoin-qt, you must set an rpcpassword in the configuration file:
    /etc/bitcoin/bitcoin.conf
    It is recommended you use the following random password:
    rpcuser=bitcoinrpc
    rpcpassword=HkFbv9YaWgEgyy7X4B9vi3GsENtGWgPNpwUf2ehsvXX1
    (you do not need to remember this password)
    The username and password MUST NOT be the same.
    If the file does not exist, create it with owner-readable-only file permissions.
    It is also recommended to set alertnotify so you are notified of problems;
    for example: alertnotify=echo %s | mail -s "Bitcoin Alert" admin@foo.com


The long random string displayed is the generated RPC password we need to add to
the configuration. Open the file 
:download:`/etc/bitcoin/bitcoin.conf <config-files/bitcoin.conf>` and add them
as follows:

.. literalinclude:: config-files/bitcoin.conf
    :language: ini


After saving, make sure the file is owned by our bitcoin user::

    $ sudo chown -R bitcoin:bitcoin /etc/bitcoin


Ubuntu Upstart Service
^^^^^^^^^^^^^^^^^^^^^^

The Bitcoin project recommends running the daemon as 
`Upstart service <http://upstart.ubuntu.com/>`_ in Ubuntu and prepared an 
`Upstart script for bitcoind 
<https://github.com/bitcoin/bitcoin/blob/master/contrib/init/bitcoind.conf>`_.

Download and install the Upstart Script::

    $ cd downloads
    $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/0.10/contrib/init/bitcoind.conf
    $ sudo cp bitcoind.conf /etc/init/

Start the Service::

    $ sudo start bitcoind
    bitcoind start/running, process 17019


When started for the first time, bitcoind will search for peers and start to
download and process the blockchain.

.. note::
    
    Depending on many factors like Internet connection bandwidth, disk speed,
    amount of RAM and CPU speed, it can take several hours or even days days
    until bitcoind has fully loaded and processed the blockchain.


Monitoring
----------

Follow transactions in the bitcoind debug log::

    $ sudo -u bitcoin multitail /var/lib/bitcoind/debug.log


To see if your node is known and reachable in the Bitcoin network got check the 
`Bitnodes <https://getaddr.bitnodes.io/>`_ website.

Examples:

 * https://getaddr.bitnodes.io/nodes/|BitcoinIPv4|-8333/

 * https://getaddr.bitnodes.io/nodes/|BitcoinIPv6|-8333/

You can also check your \*.onion Tor Hidden Service node, by entering its
address in the form at the bottom of the page and click "Check Node" button.
However no details will showed except if for the fact that the node is accepting
connections or not.

To see transactions which have been processed by your IPv4 node:

 * https://blockchain.info/ip-address/|BitcoinIPv4|

IPv6 and Tor Hidden Service Nodes are not supported by blockchain.info.


Backup Considerations
---------------------

As mentioned before, the database holding the BitCoin blockchain is huge.

But since it is a publicly available distributed peer-to-peer database, it
doesn't need to be backed up by individual nodes. In case of data loss on a node,
other nodes are equally usable and any node can re-download an re-process the
blockchain at any time.


Exclude from BackupNinja
^^^^^^^^^^^^^^^^^^^^^^^^

To make sure the huge bitcoind data folder :file:`/var/lib/bitcoind` never is
backed up accidentally by our :doc:`Backup Ninja </server/server-backup>` edit
the file :file:`/etc/backup.d/90.dup` and add a line as follows in the
"[source]" section:

.. code-block:: ini

    exclude = /var/lib/bitcoind


Reference
---------

 * https://rossbennetts.com/2015/04/running-bitcoind-via-tor/