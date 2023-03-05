.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right


Tor Onion Services
===================

While using the Tor network, may help you to connect to Internet services
without revealing your IP address, location or personal identity, the sites
and services you are connecting to over Tor will still remain visible and may
be surveilled and tracked by third parties. Since you access the Internet
trough one of the publicly known Tor exit relays, you have to assume that the
Internet traffic coming from Tor Exit relays is subjected to additional
surveillance, tracking and blocking.

`Tor Onion services <https://support.torproject.org/onionservices/>`_. allows
clients to connect to to network sites and services without leaving the Tor
network at all. The network connections are not visible outside of the
anonymous Tor network.

Tor Onion Servers get the same anonymity as Tor Clients. They are not visible
on the Internet, nobody knows their IP address or their location, or who is
connecting to them.

Onion services are often relied on for anonymous file sharing,
safer interaction between journalists and their sources like with
`SecureDrop <https://securedrop.org/>`_ or
`OnionShare <https://onionshare.org/>`_, safer software updates, and more
secure ways to reach popular websites like Proton Mail or Facebook.

Tor Onion services use the special-use top level domain (TLD) `.onion
<https://en.wikipedia.org/wiki/.onion>`_ (instead
of .com, .net, .org, etc.) and are not accessible on the normal Internet.

You can run Tor Onion Services from behind your Firewall, without the need to
open or forward ports with NAT rules. That is also great for remote
access to administrative web-interfaces or SSH services on your LAN.

.. note::

    The Tor network only works with TCP connections. Other IP protocols, like
    UDP don't work.


Preparations
------------

 * Installed Tor as described in :doc:`index`
 * Services to hide are reachable on local UNIX sockets or trough TCP ports on
   the local LAN.


The locally installed Tor client will act as a Proxy and forward the TCP
packets to the locally running SSH server on behalf of the remote Tor client
connected to this specific Onion Service.

Since Tor client and SSH server are both running on the same machine, the
preferable way to connect them is trough UNIX socket files. Its a little more
efficient, as it bypasses the IP networking stack. Its also is a little safer,
as we can restrict access with the usual UNIX file system permissions and
users and groups. But most of all, we don't have to create another set of IP
addresses or juggle with port numbers.

Not every server software will accept connections on UNIX sockets, but most do.

Only a few easy steps are needed to create a new Tor Hidden Service. We create a
hidden :doc:`SSH Service </server/ssh-server>` in the following steps as an
example.


Tor Onions Service Directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

    sudo -u debian-tor mkdir -p /var/lib/tor/onion-services


SSH Onion Service
-----------------

As an example let's make our local SSH server available as Tor Onion Service.
SSH doesn't currently accept connections on UNIX sockets, so we have to stick
with IP addresses and TCP ports here. Apparently their was `brief discussion
<https://lists.archive.carbon60.com/openssh/dev/64710>`_ to add this in OpenSSH,
after the Tor project introduced UNIX socket connections for Tor Onion services,
but I didn't find any followups on it.


.. Make SSH available trough UNIX socket
.. ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. Open the SSH server configuration file with your preferred editor and ad the
.. following line::


IP Address
^^^^^^^^^^

Add IPv4 and IPV6 network addresses for the Tor client::

    $ sudo ip addr add 192.0.2.48/24 dev eth0
    $ sudo ip addr add 2001:db8::48/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # tor client and hidden services
    iface eth0 inet static
        address 192.0.2.48/24
    iface eth0 inet6 static
        address 2001:db8::48/64


Hidden Services Root Directory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Hidden Services will each have a private key and hostname saved as files in
a specified directory.

::

    $ sudo -u debian-tor mkdir /var/lib/tor/hidden_services


Local Service Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Make sure the service you want to hide is reachable on a TCP port, preferably on
*localhost* (e.g **::1** or **127.0.0.1**).

For our SSH daemon example we add the following lines to the SSH server
configuration file :file:`/etc/ssh/sshd_config`:

.. code-block:: bash

    ListenAddress ::1
    ListenAddress 127.0.0.1

Then restart the SSH server::

    $ sudo restart ssh

You should be able to connect to the server locally from a session
already running on the server as follows::

    $ ssh localhost


Tor Configuration
^^^^^^^^^^^^^^^^^

Here is how you add a HiddenService in the tor configuration file
:file:`/etc/tor/torrc`::

    # Hidden Service SSH_Server
    HiddenServiceDir /var/lib/tor/hidden_services/SSH_server
    HiddenServicePort 22


Where the directory name "SSH_server" is to help you to distinguish what service
is reachable at which \*.onion address.


Tor Client Restart
^^^^^^^^^^^^^^^^^^

For the new Hidden Service configuration settings to be read and the service
descriptors to be created, the Tor client service needs to be restarted::

    $ sudo -u debian-tor tor --verify-config --hush
    $ sudo service tor reload


Connect to Hidden Server
^^^^^^^^^^^^^^^^^^^^^^^^

After the Tor client service is running again, you should now find your new
hidden service \*.onion address as follows::

    $ sudo cat /var/lib/tor/hidden_services/SSH_server/hostname
    duskgytldkxiuqc6.onion


The address `duskgytldkxiuqc6.onion` is where you find your hidden service.

To connect to it with your SSH client from a remote machine running a tor client
you can use the following command::

    $ torsocks ssh duskgytldkxiuqc6.onion


Adding More Hidden Services
---------------------------

You can add as many Hidden Services as you like. They might be reachable on the
same \*.onion address on different TCP ports or on various \*.onion addresses of
their own.

Various services are added throughout this guide as part of the respective
service documentation.

 * :doc:`/server/ssh-server`
 * :doc:`/server/nginx/nginx-config/nginx-servers`
 * :doc:`/server/ebooks`
 * :doc:`/server/bitcoin/bitcoin-full-node`
 * :doc:`/server/bitcoin/electrum-server`


Reference
---------

 * https://www.torproject.org/docs/tor-hidden-service.html.en
