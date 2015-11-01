Instant Messageing
==================

`Prosody IM <https://prosody.im>`_ is a lightweight and relatively easy to use 
XMPP instant messageing server.

.. contents:: 
    :local: 

Prerequisites
-------------

IP Addresses
^^^^^^^^^^^^

.. note:: 
    In this document we use example IP addresses. Note that none of these
    will work in real situations.


Add dedicated IPv4 and IPv6 addresses for XMPP on the server::

    $ sudo ip addr add 192.0.2.35/24 dev eth0
    $ sudo ip addr add 2001:db8::35/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # xmpp.example.com
    iface eth0 inet static
        address 192.0.2.35/24
    iface eth0 inet6 static
        address 2001:db8::35/64


See :doc:`network`.


DNS
^^^

The following public DNS host (A and AAAA) records are needed:

    * IPv4 host record (A) for **xmpp.example.com** pointing to your (dynamic) 
      public IP address.
    * IPv6 host record (AAAA) for **xmpp.example.com** pointing to the dedicated 
      IPv6 address.

Any file-transfer proxy servers need host records too. 

================ ==== ============================================ ======== ===
Name             Type Content                                      Priority TTL
================ ==== ============================================ ======== ===
xmpp             A    |publicIPv4|                                          300
xmpp             AAAA |XMPPIPv6|
proxy            A    |publicIPv4|                                          300
proxy            AAAA |XMPPIPv6|
================ ==== ============================================ ======== ===

Check the "Add also reverse record" when adding the first IPv6 entry.


To inform clients and other domains servers, how to connect to our domain, the
following service records (SRV) are added:

============================ ==== ================================= ======== ===
Name                         Type Content                           Priority TTL
============================ ==== ================================= ======== ===
_xmpp-client._tcp            SRV  5 5222 xmpp.example.com
_xmpp-server._tcp            SRV  5 5269 xmpp.example.com
_xmpp-server._tcp.conference SRV  5 5269 xmpp.example.com
============================ ==== ================================= ======== ===

Additional services like "conference" above are added as subdomain
service records. There is no need for additional host records.

Provide an alternative connection method over HTTPS.

============================ ==== =========================================================== ======== ===
Name                         Type Content                           Priority TTL
============================ ==== =========================================================== ======== ===
_xmppconnect                 TXT  _xmpp-client-xbosh=https://xmpp.example.com:5281/http-bind
============================ ==== =========================================================== ======== ===


TLSA (DANE) records allow connecting clients and servers to verify the TLS certificates of our server:

===================== ==== =====================================================
Name                  Type Content                                                               
===================== ==== =====================================================
_5222._tcp.xmpp       TLSA 3 0 1 f8df4b2e...............................76a2a0e5
_5269._tcp.xmpp       TLSA 3 0 1 f8df4b2e...............................76a2a0e5
===================== ==== =====================================================    


Firewall/Gateway
^^^^^^^^^^^^^^^^

The XMPP daemons listen on TCP ports 5222, 5269 and 5281 for incoming
connections.

IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
TCP      5000      |XMPPIPv4|                XMPP file transfers proxy
TCP      5222      |XMPPIPv4|                XMPP client connections
TCP      5269      |XMPPIPv4|                XMPP server connections
TCP      5281      |XMPPIPv4|                XMPP BOSH client connections
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
TCP      5000      |XMPPIPv6|                XMPP file transfers proxy
TCP      5222      |XMPPIPv6|                XMPP client connections
TCP      5269      |XMPPIPv6|                XMPP server connections
TCP      5281      |XMPPIPv6|                XMPP BOSH client connections
======== ========= ========================= ==================================


TLS Certificate and Key
^^^^^^^^^^^^^^^^^^^^^^^

See :doc:`server-tls`.


Software Package Repository
---------------------------

Ubuntu 14.04 'Trusty Thar' has currently 
`included <http://packages.ubuntu.com/trusty/prosody>`_ Prosody 
`0.9.1 <https://prosody.im/doc/release/0.9.1>`_ in its package repository.

The latest version as of May 2014 is 
`0.9.4 <https://prosody.im/doc/release/0.9.4>`_. Notable `immprovements for 
security and encryption <http://blog.prosody.im/prosody-0-9-2-released/>`_ 
where introduced in version `0.9.2 <https://prosody.im/doc/release/0.9.2>`_.

Therefore using the 
`projects own package repository <https://prosody.im/download/package_repository>`_ 
is recommended.

Add these software repositories to the systems package list::

    $ sudo -s
     echo "deb http://packages.prosody.im/debian `lsb_release -sc` main" \
        > /etc/apt/sources.list.d/prosody.org-main.list
    $ echo "deb-src http://packages.prosody.im/debian `lsb_release -sc` main" \
        >> /etc/apt/sources.list.d/prosody.org-main.list
    $ exit


All software packages released by the project are signed with its own 
`GPG key <https://prosody.im/files/prosody-debian-packages.key>`_.

Add the signing key to the systems trusted keyring::

    $ wget -O - https://prosody.im/files/prosody-debian-packages.key | sudo apt-key add -


Update the systems packages list::

    $ sudo apt-get update


Installation
------------


LuaExpat
^^^^^^^^

Unfortunately there is one outdated LUA library in the Ubuntu package repository
which we need to get from another source: 
`LuaExpat <https://prosody.im/doc/depends#luaexpat>`_,

We use `LuaRocks <https://luarocks.org/>`_, the package manager for Lua modules,
to help us with download and installation of LuaExpat.

So first we have to install LuaRocks. LuaRocks is also available from the
Ubuntu package repository, but outdated as well. 

So here is how we download and install LuaRocks from its sources::

    $ sudo apt-get update
    $ sudo apt-get install build-essential liblua5.1-0-dev libreadline-dev
    $ cd /usr/local/src/
    $ wget https://keplerproject.github.io/luarocks/releases/luarocks-2.2.2.tar.gz
    $ tar -xzf luarocks-2.2.2.tar.gz
    $ cd luarocks-2.2.2
    $ ./configure
    $ make build
    $ sudo make install bootstrap


Now we can install the LuaExpat package using Luarocks::

    $ sudo luarocks install luaexpat


LuaBitop
^^^^^^^^

Another Lua library we install separetly is the Lua bitop fast bit manipulation
library. It will be needed by the community-module `http_upload` added later,
therefore the prosody package installation does not know we need it, and won't
install it automatically::

    $ sudo apt-get install lua-bitop


Prosody Installation
^^^^^^^^^^^^^^^^^^^^

Finally we install the Prosody package::

    $ sudo apt-get install prosody


    * The installation creates the user and group **prosody** which will run the 
      server.
    * Additionally the group **ssl-cert** is created, with the user **prosody** 
      added as member
    * The directory :file:`/etc/ssl/private` and the key-file 
      :file:`/etc/ssl/private/ssl-cert-snakeoil.key` have its group ownership 
      changed to **ssl-cert** and group read access-rights added.
    * A directory structure for configuration files is created in 
      :file:`/etc/prosody`.
    * A system service :command:`prosody` is created and started.


Third-party server modules
^^^^^^^^^^^^^^^^^^^^^^^^^^

A community repository of modules exists at the 
`prosody-modules <https://modules.prosody.im/>`_ project. 

The easiest way to fetch and install these is currently via Mercurial (hg). 
Once you have it installed, simply run: 

::

    $ sudo mkdir /usr/local/lib/prosody
    $ hg clone https://hg.prosody.im/prosody-modules/ /usr/local/lib/prosody/modules


Configuration
-------------

See `Configuring Prosody <https://prosody.im/doc/configure>`_ on the Prosody 
website.

All configuration files are in the :file:`/etc/prosody` directory.

Main Configuration File
^^^^^^^^^^^^^^^^^^^^^^^

:download:`/etc/prosody/prosody.cfg.lua <config-files/etc/prosody/prosody.cfg.lua>`.

IP Addresses
^^^^^^^^^^^^

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: -- blanks. Good luck, and happy Jabbering!
    :end-before: -- This is a (by default, empty)


Additional Modules
^^^^^^^^^^^^^^^^^^

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: --use_libevent = true;
    :end-before: -- This is the list of modules Prosody will load on startup.


.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: --"legacyauth"; -- Legacy authentication. Only used by some old clients and bots.
    :end-before: -- These modules are auto-loaded, but should you want


Administrators
^^^^^^^^^^^^^^

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: interfaces = {
    :end-before: -- Enable use of libevent

.. index:: Cipher Suite; Set in Prosody


Certificate and Key
^^^^^^^^^^^^^^^^^^^

Prosody must be able to read the protected key file::

    $ sudo chgrp ssl-cert /etc/ssl/private/example.com.key.pem


Certificate and private key for TLS authentication and encryption and enforce
our selected :ref:`cipher-suite`:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: pidfile =
    :end-before: -- TLS Client Encrpytion


Force clients to use TLS encrypted connections:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: -- TLS Client Encrpytion
    :end-before: -- Force certificate authentication for server-to-server


Virtual Host
^^^^^^^^^^^^

Create a new virtual host configuration file 
:file:`/etc/prosody/conf.d/example.com.cfg.lua`:

.. literalinclude:: config-files/etc/prosody/conf.d/example.com.cfg.lua
    :language: lua


Tor Hidden Service
^^^^^^^^^^^^^^^^^^

Add a Tor Hidden Service by editing :file:`/etc/tor/torrc`::

    # Prosody XMPP Hidden Service for xmpp.example.com
    HiddenServiceDir /var/lib/tor/hidden_services/xmpp-server
    HiddenServicePort 5000 192.0.2.35:5000
    HiddenServicePort 5222 192.0.2.35:5222
    HiddenServicePort 5269 192.0.2.35:5269
    HiddenServicePort 5280 192.0.2.35:5280
    HiddenServicePort 5281 192.0.2.35:5281


Reload the Tor client::

    $ sudo service tor reload

Read the newly generated \*.onion hostname::

    $ sudo cat /var/lib/tor/hidden_services/xmpp-server/hostname
    duskgytldkxiuqc6.onion


Create a new virtual host configuration file 
:download:`/etc/prosody/conf.d/duskgytldkxiuqc6.onion.cfg.lua <config-files/etc/prosody/conf.d/duskgytldkxiuqc6.onion.cfg.lua>`:

.. literalinclude:: config-files/etc/prosody/conf.d/duskgytldkxiuqc6.onion.cfg.lua
    :language: lua


Configuration Syntax Check
^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo luac -p /etc/prosody/prosody.cfg.lua

If there is no output there are no syntax errors. Otherwise filename and 
line-number are shown along with a error message.


Restart Server
--------------

::

    $ sudo service prosody restart


Add Users
---------
See `Creating Accounts <https://prosody.im/doc/creating_accounts>`_ on the 
Prosody website.

::

    $ sudo prosodyctl adduser <username>@example.com
    Enter new password: ********
    Retype new password: ********


Monitoring
----------------------

.. todo:: Write how to log and monitor.


Online Security Test
^^^^^^^^^^^^^^^^^^^^

On the https://xmpp.net/ website users and server administrators can inspect the 
security of their XMPP servers.


Backup Considerations
---------------------

.. todo:: Write which data to backup for Prosody with ninjabackup.
