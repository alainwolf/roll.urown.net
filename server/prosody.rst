Instant Messageing
==================

`Prosody IM <https://prosody.im>`_ is a lightweight and relatively easy to use 
XMPP instant messageing server.

Prerequisites
-------------

IP Addresses
^^^^^^^^^^^^

Dedicated IPv4 and IPv6 addresses for XMPP on the server:




See :doc:`network`.


DNS
^^^

The following public DNS records are needed:

 * IPv4 host record (A) for **xmpp.example.com** pointing to your (dynamic) 
   public IP address.
 * IPv6 host record (AAAA) for **xmpp.example.com** pointing to the dedicated 
   IPv6 address.


Firewall/Gateway
^^^^^^^^^^^^^^^^


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

 ::

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


Configuration
-------------

See `Configuring Prosody <https://prosody.im/doc/configure>`_ on the Prosody 
website.

All configuration files are in the :file:`/etc/prosody` directory.

Main Configuration File
^^^^^^^^^^^^^^^^^^^^^^^

:file:`/etc/prosody/prosody.cfg.lua`.

IP Addresses
^^^^^^^^^^^^

.. literalinclude:: prosody/prosody.cfg.lua
	:language: lua
	:start-after: -- blanks. Good luck, and happy Jabbering!
	:end-before: -- This is a (by default, empty)


Administrators
^^^^^^^^^^^^^^

.. literalinclude:: prosody/prosody.cfg.lua
	:language: lua
	:start-after: interfaces = {
	:end-before: -- Enable use of libevent


Certificate and Key
^^^^^^^^^^^^^^^^^^^

Prosody must be able to read the protected key file::

	$ sudo chgrp ssl-cert /etc/ssl/private/example.com.key.pem


Certificate and private key for TLS authentication and encryption:

.. literalinclude:: prosody/prosody.cfg.lua
	:language: lua
	:start-after: pidfile =
	:end-before: -- TLS Client Encrpytion


Force clients to use TLS encrypted connections:

.. literalinclude:: prosody/prosody.cfg.lua
	:language: lua
	:start-after: -- TLS Client Encrpytion
	:end-before: -- Force certificate authentication for server-to-server


Virtual Host
^^^^^^^^^^^^

Create a new virtual host configuration file 
:file:`/etc/prosody/conf.d/exmaple.com.cfg.lua`:

.. code-block:: lua


	-- Prosody XMPP vitual host example.com
	VirtualHost "example.com"

	--
	-- Components
	
	---- Set up a MUC (multi-user chat) room server on conference.example.com:
	Component "conference.example.com" "muc"

	---- Set up a SOCKS5 bytestream proxy for server-proxied file transfers:
	Component "proxy.example.com" "proxy65"


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


Logging and Monitoring
----------------------


Backup Considerations
---------------------
