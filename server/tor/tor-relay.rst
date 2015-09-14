.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right

Tor Relay
=========

The Tor network relies on volunteers to donate bandwidth. The more people who
run relays, the faster the Tor network will be. 

If you have at least 2 megabits per second for both upload and download, you can
help out Tor by configuring your Tor to be a relay too.

.. warning::
    
    Its not advised to run a Tor **Exit Node** on Internet connections used for
    other tasks like providing mail and web services or surfing the web etc.
    This guide describes the setup of a *non-exit-Relay*.


.. contents:: 
    :depth: 1
    :local:
    :backlinks: top

Prerequisites
-------------

IP Address
^^^^^^^^^^

Add IPv4 and IPV6 network adresses for the Tor relay::

    $ sudo ip addr add 192.0.2.49/24 dev eth0
    $ sudo ip addr add 2001:db8::49/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # tor-relay.example.com
    iface eth0 inet static
        address 192.0.2.49/24
    iface eth0 inet6 static
        address 2001:db8::49/64


DNS Records 
^^^^^^^^^^^

================ ==== ============================================ ======== ===
Name             Type Content                                      Priority TTL
================ ==== ============================================ ======== ===
tor-relay        A    |publicIPv4|                                          300
tor-relay        AAAA |TorServerIPv6|
================ ==== ============================================ ======== ===

Check the "Add also reverse record" when adding the IPv6 entry.


Firewall Rules
^^^^^^^^^^^^^^

IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
TCP      110, 9001 |TorServerIPv4|           Incoming Tor connections
TCP      995, 9030 |TorServerIPv4|           Incoming Tor directory connections
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
TCP      110, 9001 |TorServerIPv6|           Incoming Tor connections
TCP      995, 9030 |TorServerIPv6|           Incoming Tor directory connections
======== ========= ========================= ==================================


Service Files
-------------

Stop any running tor services::
    
    $ sudo service tor stop

Create copies of the installed Tor init.d script, service defaults:


SysV Init Script
^^^^^^^^^^^^^^^^

::

    $ sudo cp /etc/init.d/tor /etc/init.d/tor-relay

Change the copied file 
:download:`/etc/init.d/tor-relay <config-files/init.d/tor-relay>` as follows:

.. literalinclude:: config-files/init.d/tor-relay
    :language: bash
    :linenos:
    :lineno-start: 1
    :lines: 1-35
    :emphasize-lines: 4,25-26,28,29,32


SysV Defaults
^^^^^^^^^^^^^

::

    $ sudo cp /etc/default/tor /etc/default/tor-relay


AppArmor Profile
^^^^^^^^^^^^^^^^

Change the file 
:download:`/etc/apparmor.d/local/system_tor <config-files/apparmor.d/local/system_tor>` 
as follows:

.. literalinclude:: config-files/apparmor.d/local/system_tor
    :language: bash
    :linenos:

Make AppArmor re-read its configuration to activate the new profile::

    $ sudo service apparmor recache
    $ sudo service apparmor restart 


Data Directory
--------------

::

    $ sudo -u debain-tor mkdir /var/lib/tor-relay


Tor Relay Configuration 
-----------------------

Configuration is stored in the file 
:download:`/etc/tor/tor-relay <config-files/tor-relay>`.

See ``man tor`` or the 
`Tor-stable manual <https://www.torproject.org/docs/tor-manual.html.en>`_ 
for reference of all possible configuration options. 

.. literalinclude:: config-files/tor-relay
    :language: bash
    :linenos:


Control Connection Password
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create a secure password with KeePassX or Diceware that doesn't contain any
symbols, special characters or whitespace.

Then let Tor create and display a hash of your password for as follows::

    $ tor --hush --hash-password ********
    16:7B79E57C592CE09660D745F88A1317263BB43CE09FBA46CBF31C6C13B0
    $ history -c

The second command clears your command-line history, as it contains your
password in clear-text.


Bandwidth Limits
^^^^^^^^^^^^^^^^

Decide on how much bandwidth of your Internet connection you would like to
donate to the Tor network.

See the 
`Rate Limiting FAQ entry <https://www.torproject.org/docs/faq.html.en#BandwidthShaping>`_
on the Tor project website.

Make sure to use the right unit. Limits can be defined as bytes, KBytes, MBytes,
GBytes or as KBits, MBits and GBits.


Contact Information
^^^^^^^^^^^^^^^^^^^^

Think of a name for your relay and also create a mail address (or mail alias)
and a GPG key. So that you can be contacted by the Tor project. The mail address
will be published on Tor related websites, so you might not want to use your
regular personal mail address.


Verify Configuration
^^^^^^^^^^^^^^^^^^^^

::

    $ sudo -u debian-tor tor -f /etc/tor/tor-relay --verify-config --hush


Start the Relay Server
----------------------

::

    $ sudo service tor restart

It can take up to an hour until your new relay is visible on the Tor network.
Check the `Tor Atlas <https://atlas.torproject.org/>`_ or 
`Tor Globe <https://globe.torproject.org/>`_ websites to see the current status 
of your relay.

It will take several days until your new relay starts picking up traffic. 
Read `The lifecycle of a new relay 
<https://blog.torproject.org/blog/lifecycle-of-a-new-relay>`_ about how and why.

.. image:: relay-stats.*
    :alt: Tor Relay Statistics



Monitoring the Relay
--------------------

Installation
^^^^^^^^^^^^

The `Anonymizing Relay Monitor (arm) <http://www.atagar.com/arm>`_ is a terminal
status monitor for Tor, intended for command-line aficionados, ssh connections,
and anyone with a TTY terminal. This works much like ``htop`` does for system
usage, providing real time statistics for:

 * Bandwidth, CPU, and memory usage;
 * Relay's current configuration;
 * Logged events;
 * Connection details:

   - IP;
   - Hostname;
   - Fingerprint;
   - Consensus data;

 * etc.

Install arm::

    $ sudo apt-get install tor-arm


Configuration
^^^^^^^^^^^^^

Configuration is stored in the file :file:`~/.arm/armrc` in your home directory.
Uncompress and copy the sample configuration file::

    $ mkdir ~/.arm

.. code-block:: ini

    # Startup options
    startup.interface.socket /var/run/tor-relay/control
    startup.controlPassword ********


Running Arm
^^^^^^^^^^^

Arm needs access to the Tor configuration file :file:`/etc/tor/torrc` and the data directory :file:`/var/lib/tor` it is therefore best run as the Tor user::

    $ sudo -u debian-tor arm


Backup Considerations
---------------------

Tor Node Identity
^^^^^^^^^^^^^^^^^

Tor nodes are referred to by name and or fingerprint. The name can be anything
and its not sure if its unique. It just a help for humans to refer to. The
fingerprint is unique and tied to the private RSA identity key. The fingerprint
is store along the name in the file :file:`/var/lib/tor/fingerprint`.

The Tor identity key in the file :file:`/var/lib/tor/keys/secret_id_key` is the
one who identifies your Tor relay on the network during its whole lifetime.
Other keys in the :file:`/var/lib/tor/keys` directory change periodically.

In case you have to restore your relay on a new machine, you should need backups
of the following files:

 * :file:`/etc/tor/tor-relay`
 * :file:`/var/lib/tor-relay/fingerprint`
 * :file:`/var/lib/tor-relay/keys/secret_id_key`

You should backup those files on a secure storage device along with other
server-keys.


Daily Backup
^^^^^^^^^^^^

Make sure the following directories are included in your daily backup set:

 * :file:`/etc/tor`
 * :file:`/var/lib/tor-relay`


References
----------

 * https://www.torproject.org/docs/tor-doc-relay