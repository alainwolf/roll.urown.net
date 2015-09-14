.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right


Tor Hidden Services
===================

Tor allows clients and relays to offer hidden services. That is, you can offer a
web server, SSH server, etc., without revealing your IP address to its users. In
fact, because you don't use any public address, you can run a hidden service
from behind your firewall.

Tor hidden services use the pseudo-top-level-domain `.onion
<https://en.wikipedia.org/wiki/.onion>`_ for clients to connect to.


Prerequisites
-------------

 * Installed Tor as described in :doc:`index`
 * Services to hide are reachable on local TCP ports


Configuration
-------------

Only a few easy steps are needed to create a new Tor Hidden Service. We create a
hidden :doc:`SSH Service </server/ssh-server>` in the following steps as an
example.

IP Address
^^^^^^^^^^

Add IPv4 and IPV6 network adresses for the Tor client::

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
configuraiton file :file:`/etc/ssh/sshd_config`:

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