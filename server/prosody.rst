Instant Messaging
==================

.. image:: prosody-logo.*
    :alt: Prosody Logo
    :align: right

`Prosody IM <https://prosody.im>`_ is a lightweight and relatively easy to use
XMPP instant messaging server.

.. contents::
    :local:


Topology
---------

XMPP server domain: example.net

XMPP virtual domain: example.org


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

    # xmpp.example.net
    iface eth0 inet static
        address 192.0.2.35/24
    iface eth0 inet6 static
        address 2001:db8::35/64


See :doc:`network`.

Firewall Rules
^^^^^^^^^^^^^^

The XMPP daemons listen on TCP ports 5000, 5222, 5269 and 5281 for incoming
connections. 

To support legacy SSL connections (aka direct TLS, without STARTTLS) we define
an additional TCP port for every virtual domain. This allows us to use the
dedicated certificate for SSL too.

We also assume your web-server is already reachable and accepting 
connections on TCP ports 80 and 443, as we will use it as reverse-proxy for a 
number of HTTP services on your XMPP server.

IPv4 NAT port forwarding:

======== ========= ========================= ===================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ===================================
TCP      80        |HTTPserverIPv4|          HTTP reverse proxy
TCP      443       |HTTPserverIPv4|          HTTPS reverse proxy
TCP      5000      |XMPPIPv4|                XMPP file transfers proxy
TCP      5222      |XMPPIPv4|                XMPP STARTTLS client connections
TCP      **5223**  |XMPPIPv4|                **example.net** XMPP SSL connection 
TCP      **5224**  |XMPPIPv4|                **example.org** XMPP SSL connection
TCP      5269      |XMPPIPv4|                XMPP STARTTLS server connections
TCP      5281      |XMPPIPv4|                XMPP BOSH client/server connections
======== ========= ========================= ===================================


Allowed IPv6 connections:

======== ========= ========================= ===================================
Protocol Port No.  Destination               Description
======== ========= ========================= ===================================
TCP      80        |XMPPIPv6|                HTTP reverse proxy
TCP      443       |XMPPIPv6|                HTTPS reverse proxy
TCP      5000      |XMPPIPv6|                XMPP file transfers proxy
TCP      5222      |XMPPIPv6|                XMPP client connections
TCP      **5223**  |XMPPIPv6|                **example.net** XMPP SSL connection
TCP      **5224**  |XMPPIPv6|                **example.org** XMPP SSL connection
TCP      5269      |XMPPIPv6|                XMPP server connections
TCP      5281      |XMPPIPv6|                XMPP BOSH client connections
======== ========= ========================= ===================================



XMPP Server DNS Records
-----------------------

Assuming our XMPP server is **example.net**.

Host Records
^^^^^^^^^^^^

The following public DNS host (A and AAAA) records are needed:

    * IPv4 host record (A) for **xmpp.example.net** pointing to your (dynamic)
      public IP address.
    * IPv6 host record (AAAA) for **xmpp.example.net** pointing to the dedicated
      IPv6 address.


================ ==== ===== ========================================
Name             Type TTL   IP Address                                      
================ ==== ===== ========================================
xmpp             A    300   |publicIPv4|                                 
xmpp             AAAA  3600 |XMPPIPv6|
================ ==== ===== ========================================

Reverse pointer records are not required but recommended.

Additional services (or components, as they are frequently called) like
"conference" below, should be added as sub-domain records. This is needed for 
XMPP users outside of your domain to be able to use these services:

================ ==== ====== ========================================
Name             Type TTL    IP Address                                      
================ ==== ====== ========================================
conference       A       300 |publicIPv4|
conference       AAAA   3600 |XMPPIPv6|
proxy            A       300 |publicIPv4|                                          
proxy            AAAA   3600 |XMPPIPv6|
upload           A       300 |publicIPv4|                                          
upload           AAAA   3600 |XMPPIPv6|
================ ==== ====== ========================================


Service Records
^^^^^^^^^^^^^^^

To inform clients and other domains servers, how to connect to our domain, the
following service records (SRV) are added:

============================ ==== ====== ======== ====== ===== ================
Name                         Type    TTL Priority Weight Port  Host                        
============================ ==== ====== ======== ====== ===== ================
_xmpp-client._tcp            SRV    3600       10     10  5222 xmpp.example.net
_xmpps-client._tcp           SRV    3600       10     10  5223 xmpp.example.net
_xmpp-server._tcp            SRV    3600       10     10  5269 xmpp.example.net
_xmpp-server._tcp.conference SRV    3600       10     10  5269 xmpp.example.net
============================ ==== ====== ======== ====== ===== ================

**Note:** The target of a SRV record MUST point to an existing A or AAAA record, 
it cannot point to a numeric IP address or a CNAME record.

Services (components) on sub-domains usually only use server-to-server records.


Text Records
^^^^^^^^^^^^

With text records you can inform clients about alternative or non-standard
connection method:

============ ==== ==== =========================================================
Name         Type  TTL Content                                                    
============ ==== ==== =========================================================
_xmppconnect TXT  3600 _xmpp-client-xbosh=https://xmpp.example.net:443/http-bind
============ ==== ==== =========================================================


DANE TLSA Records
^^^^^^^^^^^^^^^^^

TLSA (DANE) records allows connecting clients and servers to verify the TLS
certificates of our server independently of any third-party CA.

**Note:** TLSA records for XMPP should identify the hosted virtual domain
name, not the host-name which clients and servers will connect to.

===================== ==== ====== ===== ======== ===== =========================
Name                  Type    TTL Usage Selector Match Hash
===================== ==== ====== ===== ======== ===== =========================
_5222._tcp.           TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5223._tcp.           TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5269._tcp.           TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5269._tcp.xmpp       TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5269._tcp.conference TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5281._tcp.           TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
_5281._tcp.conference TLSA   3600     3        1     1 f8df4b2e.........76a2a0e5
===================== ==== ====== ===== ======== ===== =========================


XMPP Virtual Domain DNS Records
-------------------------------

Assuming our XMPP virtual domain **example.org** is hosted by the server 
**xmpp.example.net**.


Host Records
^^^^^^^^^^^^

The virtual **example.org** domain doesn't need any host records, as all
connections will be directed to the server **xmpp.example.net** outside of the
**example.org** domain.


Service Records
^^^^^^^^^^^^^^^

The service records of the virtual domain **example.org** are *virtually
identical* to the ones we already created for the hosting server
**example.net**.

The only difference is that the **_xmpps-client._tcp** SRV record points to this
virtual domains dedicated SSL  port **5224**.

============================ ==== ==== ======== ====== ========= ================
Name                         Type  TTL Priority Weight Port      Host                        
============================ ==== ==== ======== ====== ========= ================
_xmpp-client._tcp            SRV  3600       10     10  5222     xmpp.example.net
**_xmpps-client._tcp**       SRV  3600       10     10  **5224** xmpp.example.net
_xmpp-server._tcp            SRV  3600       10     10  5269     xmpp.example.net
_xmpp-server._tcp.conference SRV  3600       10     10  5269     xmpp.example.net
============================ ==== ==== ======== ====== ========= ================

**Note:** The target of a SRV record MUST point to an existing A or AAAA record, 
it cannot point to a numeric IP address or a CNAME record.

Services (components) on sub-domains usually only use server-to-server records.


Text Records
^^^^^^^^^^^^

Same here. Same record as in the hosting servers domain:

============ ==== ==== =========================================================
Name         Type  TTL Content                                                    
============ ==== ==== =========================================================
_xmppconnect TXT  3600 _xmpp-client-xbosh=https://xmpp.example.net:443/http-bind
============ ==== ==== =========================================================


DANE TLSA Records
^^^^^^^^^^^^^^^^^

In the server configuration, the virtual domain **example.org** will get its own
set of TLS certificate and private key. Therefore the TLSA records are not the
same as in the hosting servers **example.net** domain.

===================== ==== ====== ===== ======== ===== =========================
Name                  Type    TTL Usage Selector Match Hash
===================== ==== ====== ===== ======== ===== =========================
_5222._tcp.           TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
**_5224._tcp.**       TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
_5269._tcp.           TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
_5269._tcp.xmpp       TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
_5269._tcp.conference TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
_5281._tcp.           TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
_5281._tcp.conference TLSA   3600     3        1     1 76a2a0e5.........f8df4b2e
===================== ==== ====== ===== ======== ===== =========================


See this step-by-step example where a XMPP server needs to connect to the
**example.org** domain XMPP server:

#. The initiating server looks up the service record for XMPP server-to-server
   connections in the DNS: 

====================== =====================================
Question:              **SRV _xmpp-server._tcp.example.org**
DNSSEC trusted answer: **10 10 5269 xmpp.example.com**
====================== =====================================

#. The initiating server connects to **xmpp.example.com** on TCP port 5269 and 
   starts a TLS session with the target server by requesting a connection to the
   **example.org** domain.

#. The server **xmpp.example.com** will present a x.509 certificate which is 
   valid for the DNS host-name **example.org**.

#. The initiating server will look up the TLSA records for this server in DNS:

====================== ===================================
Question:              **TLSA _5269._tcp.exmple.org**
DNSSEC trusted answer: **3 1 1 76A2A0E5.........F8DF4B2E** 
====================== ===================================
   
   The long string of garbage at the end being the hash of a public-key.

#. He compares the hash(es) found in DNS with the public-key of the presented 
   certificate, and if a match is found, the certificate and therefore the 
   connection is verified and can be trusted.

Because:

A. The delegation of **example.org** to the 3rd-party **example.com** server (in 
   another domain) can be trusted as it is secured by DNSSEC.

B. The presented certificate by that 3rd-party server can be verified with 
   information obtained in trusted DNS records from original domains DNS (DANE).

See the `DANE + XMPP Presentation 
<https://datatracker.ietf.org/meeting/84/materials/slides-84-dane-3.pdf>`_ of 
IETF 84, Vancouver



TLS Certificate and Key
^^^^^^^^^^^^^^^^^^^^^^^

See :doc:`server-tls`.


Software Package Repository
---------------------------

Ubuntu 14.04 'Trusty Thar' has currently
`included <http://packages.ubuntu.com/trusty/prosody>`_ Prosody
`0.9.1 <https://prosody.im/doc/release/0.9.1>`_ in its package repository.

The latest version as of May 2014 is
`0.9.4 <https://prosody.im/doc/release/0.9.4>`_. Notable `improvements for
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
`LuaExpat <https://prosody.im/doc/depends#luaexpat>`_.

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

Another Lua library we install separately is the Lua bitop fast bit manipulation
library. It will be needed by the community-module `http_upload` added later,
therefore the prosody package installation does not know we need it, and won't
install it automatically::

    $ sudo apt-get install lua-bitop


Prosody Installation
^^^^^^^^^^^^^^^^^^^^

Finally we install the Prosody package::

    $ sudo apt-get install prosody


After installation we have on our server:

 * The user and group **prosody** which will run the server;
 * The group **ssl-cert**, with the user **prosody** added as member;
 * The directory :file:`/etc/ssl/private` and the key-file
   :file:`/etc/ssl/private/ssl-cert-snakeoil.key` have its group ownership
   changed to **ssl-cert** and group read access-rights added;
 * A directory structure for configuration files in :file:`/etc/prosody`;
 * A system service :command:`prosody` is created and started;


Third-party server modules
^^^^^^^^^^^^^^^^^^^^^^^^^^

A community repository of modules exists at the
`prosody-modules <https://modules.prosody.im/>`_ project.

The easiest way to fetch and install these is currently via Mercurial
( :command:`hg` ). Once you have it installed, simply run:

::

    $ sudo mkdir /usr/local/lib/prosody
    $ hg clone https://hg.prosody.im/prosody-modules/ /usr/local/lib/prosody/modules


Since this are mostly under heavy development, you need to update them from time
to time::

    $ cd /usr/local/lib/prosody/modules
    $ sudo hg pull --update
    $ sudo prosodyctl restart


Web Template
^^^^^^^^^^^^

A bootstrap theme for the user registration website::

    $ sudo mkdir -p /usr/local/lib/prosody/register-templates
    $ cd /usr/local/lib/prosody/register-templates/
    $ sudo git clone https://github.com/beli3ver/Prosody-Web-Registration-Theme


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


Registration Website Template
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Change the layout of the ugly mod_register_web plug-in from Prosody:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: -- Register Web Template files
    :end-before: -- Disable account creation by default, for security


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

    $ sudo chgrp ssl-cert /etc/ssl/private/example.net.key.pem


Certificate and private key for TLS authentication and encryption and enforce
our selected :ref:`cipher-suite`:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: Include "/usr/local/lib/prosody/xmpp-onion-map/onions-map.lua"
    :end-before: c2s_require_encryption = true


Force clients to use TLS encrypted connections:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after:     certificate = "/etc/ssl/certs/example.net.cert.pem";
    :end-before: -- Force certificate authentication for server-to-server


Virtual Host
^^^^^^^^^^^^

Create a new virtual host configuration file
:file:`/etc/prosody/conf.d/example.net.cfg.lua`:

.. literalinclude:: config-files/etc/prosody/conf.d/example.net.cfg.lua
    :language: lua


Tor Hidden Service
^^^^^^^^^^^^^^^^^^

Add a Tor Hidden Service by editing :file:`/etc/tor/torrc`::

    # Prosody XMPP Hidden Service for xmpp.example.net
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


Prosody Onions-Map
^^^^^^^^^^^^^^^^^^

**mod_onions** is a Prosody Plugin to interconnect XMPP servers trough Tor by
mapping tor hidden service addresses to XMPP server names.

The map file is `maintained on GitHub <https://modules.prosody.im/mod_onions.html>`_

To install the map file::

    $ cd /usr/local/lib/prosody
    $ sudo sudo git clone https://github.com/nickcalyx/xmpp-onion-map.git

To make prosody use the map file, reference it in the main configuration file
:file:`/etc/prosody/prosody.cfg.lua` as follows:

.. literalinclude:: config-files/etc/prosody/prosody.cfg.lua
    :language: lua
    :start-after: pidfile = "/var/run/prosody/prosody.pid";
    :end-before: -- SSL/TLS-related settings.

To update the map file periodically and reload the module::

    $ cd /usr/local/lib/prosody
    $ sudo git remote update
    $ sudo git pull
    $ sudo prosodyctl restart
    $ telnet localhost 5582


.. code-block:: text

    Trying ::1...
    Connected to localhost.
    Escape character is '^]'.
    |                    ____                \   /     _
                        |  _ \ _ __ ___  ___  _-_   __| |_   _
                        | |_) | '__/ _ \/ __|/ _ \ / _` | | | |
                        |  __/| | | (_) \__ \ |_| | (_| | |_| |
                        |_|   |_|  \___/|___/\___/ \__,_|\__, |
                        A study in simplicity            |___/


    | Welcome to the Prosody administration console. For a list of commands, type: help
    | You may find more help on using this console in our online documentation at
    | http://prosody.im/doc/console

    module:reload("onions")
    | Reloaded on example.net
    | Reloaded on example.net
    | Reloaded on localhost
    | OK: Module reloaded on 3 hosts



Configuration Syntax Check
^^^^^^^^^^^^^^^^^^^^^^^^^^^

To test if the LUA interpreter can understand your configuration files::

    $ sudo luac -p /etc/prosody/prosody.cfg.lua

If there is no output there are no syntax errors. Otherwise filename and
line-number are shown along with a error message.

Test if Prosody finds your configuration reasonable::

    $ sudo prosodyctl check


Restart Server
--------------

::

    $ sudo systemctl restart prosody.service


Add Users
---------
See `Creating Accounts <https://prosody.im/doc/creating_accounts>`_ on the
Prosody website.

::

    $ sudo prosodyctl adduser <username>@example.net
    Enter new password: ********
    Retype new password: ********


Monitoring
----------------------

.. todo:: Write how to log and monitor.


On-Line Test
^^^^^^^^^^^^

At the `IM Observatory <https://xmpp.net/>`_ website users and server
administrators can inspect the security of their XMPP servers.

The people behind the Android XMPP client 
`conversations <https://conversations.im>`_ set up the 
`XMPP Compliance Tester <https://compliance.conversations.im/>`_ 
website.

The site will check your XMPP server installation for compliance with the most
important XMPP extensions as of 2018. See 
`XEP-0387 XMPP Compliance Suites 2018 <https://xmpp.org/extensions/xep-0387.html>`_.

Any problems found are supplemented with hints tailored for your server software
and version. They might also tell you which modules are available to achieve
a better score.


Backup Considerations
---------------------

.. todo:: Write which data to backup for Prosody with ninjabackup.
