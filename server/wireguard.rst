.. image:: wireguard-logo.*
    :alt: WireGuard Logo
    :align: right

Virtual Private Network
=======================

.. contents::
  :local:

`WireGuard <https://www.wireguard.com/>`_ is an extremely simple yet fast and
modern VPN that utilizes state-of-the-art cryptography. It aims to be faster,
simpler, leaner, and more useful than IPSec, while avoiding the massive
headache. It intends to be considerably more performant than OpenVPN. WireGuard
is designed as a general purpose VPN for running on embedded interfaces and
super computers alike, fit for many different circumstances.

.. warning::

    As of this writing (Dec. 2017) the WireGuard code ..

     * is pre-release software.

     * has to be considered as experimental and not yet complete.

     * has not undergone proper degrees of security auditing.

     * is still subject to change.

     * may contain security vulnerabilities which would not be eligible for CVEs.


Usage Scenario
--------------

Several of our internal services have either no built-in support for encrypted
communications (Redis) or its hard to get it right (e.g. MariaDB, Memcached).

Others may provide additional features or caches or APIs (e.g. PowerDNS REST
API, Postfix lookup tables, status queries) which are meant to be used on the
same machine or inside a local network.

With the WireGuard VPN we can let them talk to each other across the globe without disclosing any data to outsiders.


.. code-block:: text

    Server-1                     Server-2
    --------                     --------
    public IP <--- Internet ---> public IP
        |                            |
        |                            |
    WireGuard                     WireGuard
        |                            |
        |                            |
    private IP <----- VPN -----> private IP
        |                            |
        |                            |
     MariaDB                      MariaDB
     Redis                        Redis
     Postfix                      Postfix
     Rspamd                       Rspamd



In the following sections we will build a Virtual Private Network with the following hosts:

===================== ============ =======================
Domain Name           IPv4 Address IPv6 Address
===================== ============ =======================
dolores.example.net   203.0.113.54 N/A
maeve.example.net     198.51.100.7 2001:db8:48d1::1 
bernard.example.net   192.0.2.14   2001:db8:2d07:5b57::0
arnold.example.net    dynamic      2001:db8:3414:6b1d::1
charlotte.example.net dynamic      2001:db8:3414:6b1d::10
teddy.example.net     dynamic      dynamic
===================== ============ =======================

After the VPN is setup, they will be reachable from *inside* the VPN as follows:

========================== ============== =========================
Domain Name                IPv4 Address   IPv6 Address
========================== ============== =========================
dolores.vpn.example.net    10.195.171.142 fdc1:d89e:b128:6a04::7de4
maeve.vpn.example.net      10.195.171.47  fdc1:d89e:b128:6a04::961
bernard.vpn.example.net    10.195.171.174 fdc1:d89e:b128:6a04::3354
charlotte.vpn.example.net  10.195.171.241 fdc1:d89e:b128:6a04::29ab
========================== ============== =========================

Please see :doc:`/topology` for information.


WireGuard Port Number
^^^^^^^^^^^^^^^^^^^^^

We need a UDP port number where our VPN hosts will listen for incoming
connections.

WireGuard does not recommend a specific port number, like most IP network
services do.

The port numbers from 49,152 to 65,535 have been reserved by :term:`IANA` for
dynamic and/or private use. To select a random number from this range::

    $ shuf -i 49152-65535 -n 1
    55867

Although :term:`IANA` is responsible for 
`official port numbers <https://www.iana.org/assignments/service-names-port-numbers/>`_, 
many unofficial uses of both well- known and registered port numbers occur in
practice.

To avoid any potential conflicts, I usually check if a port number is already
known to be uses by any software or services. 
The `Speed Guide Ports Database <https://www.speedguide.net/ports.php>`_ is a 
good resource for this:

`<https://www.speedguide.net/port.php?port=55867>`_

Wikipedia also maintains a 
`list <https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers>`_.


Software Installation
---------------------

On each host::

    $ sudo add-apt-repository ppa:wireguard/wireguard
    $ sudo apt update
    $ sudo apt install wireguard-dkms wireguard-tools
    $ sudo touch /etc/wireguard/.reload-module-on-update


Key Generation
--------------

On each host.

Create a private key::

    $ cd /etc/wireguard
    $ umask 077
    $ wg genkey > privatekey


Create the public key::

    $ wg pubkey < privatekey > publickey


Create public and private keys::

    $ wg genkey | tee privatekey | wg pubkey > publickey


Configurations
--------------

Create a fresh configuration file :file:`/etc/wireguard/wg0.conf` on each host:

The file format is derived from the old windows INI files and fairly simple
(at least for a VPN). 

Interface
^^^^^^^^^

Each configuration has one section called
:file:`[Interface]` where the server-part is defined.

It contains the private key of the local WireGuard server, the UDP port it
should listen for incoming connections and its own VPN IP addresses.

For the **Dolores** host this looks like the following:

.. code-block:: ini

    # WireGuard Configuration for dolores.example.net
    # Hetzner, San Francisco

    [Interface]
    PrivateKey = qNoBKylRuEUtBuTANIS6rSZoCqG8cFYzEWeS7fx63Vk=
    ListenPort = 55867
    Address = 10.195.171.142/24, fdc1:d89e:b128:6a04::7de4/64


For **Maeve**:

.. code-block:: ini

    ; WireGuard Configuration for maeve.example.net
    ; Rackspace, London

    [Interface]
    PrivateKey = cIsZsNNMJmHSjsi/VBmoJk3DHN+mOG6OY6otkKOqQm4=
    ListenPort = 55867
    Address = 10.195.171.126/24, fdc1:d89e:b128:6a04::2615/64


**Bernard**:

.. code-block:: ini

    ; WireGuard Configuration for bernard.example.net
    ; Rollnet, Phoenix

    [Interface]
    PrivateKey = gAjbms8705vj8Yg1p7EDKi6ZiRonQQTmzyFjaDey+Gw=
    ListenPort = 55867
    Address = 10.195.171.74/24, fdc1:d89e:b128:6a04::41c5/64


**Charlotte**

.. code-block:: ini

    ; WireGuard Configuration for charlotte.example.net
    ; Home, Frankfurt

    [Interface]
    PrivateKey = qNoBKylRuEUtBuTANIS6rSZoCqG8cFYzEWeS7fx63Vk=
    ListenPort = 55867
    Address = 


Peers
^^^^^

The :file:`[Peer]` sections define the other members of the VPN network.
You can add as many as needed.

They contain their public key, which must match the peers private key in its
:file:`[Interface]` section.

The hostname (or IP address) and port set as **Endpoint** is optional:

 * If an **Endpoint** is defined, the local system is capable of connecting to
   the remote peer on its own.

 * If the peer don't has an **Endpoint** defined, the local system will just
   wait for an incoming connection from that peer. This is useful for peers
   with dynamic IP addresses and for road-warriors who need to connect from
   anywhere.

Note that any incoming connection is first authenticated against one of the
public keys. If the connection is not from a verified peer, the incoming
packets are just silently ignored. Since connections from hosts who don't own
a matching private key are not answered at all, a WireGuard VPN does not only
provide encrypted communication, it also remains hidden from outsiders. Except
for its members, no one knows that it exists.

Once you have figured out the peer section of all your WireGuard hosts, you just
copy and paste them to the configuration file of every other host participating
in your VPN network.

So the :file:`[Peer]` section are nearly the same on every system, with the
exception that the servers should not have peer definitions that point to
themselves. We want to avoid a peer trying to connect with himself.


For the **Dolores** host this looks like the following:

.. code-block:: ini

    [Peer]
    #
    # dolores.example.net, Hetzner, San Francisco
    #
    PublicKey = xFXzNIDQ5NJkY0Pgg5hG1fZg0RAD51nnu5MMBbhlpCg=
    Endpoint = dolores.example.net:55867
    #
    # Allow dolores.vpn.example.net
    AllowedIPs = 10.195.171.142/32, fdc1:d89e:b128:6a04::7de4/128


For **Maeve**:

.. code-block:: ini

    [Peer]
    #
    # maeve.example.net, Rackspace, London
    #
    PublicKey = Bj7G2pqXZRjrcBTwOWDrkjcy3PzhhJd3cX8QvBTaRDI=
    Endpoint = maeve.example.net:55867
    #
    # Allow maeve.vpn.example.net
    AllowedIPs = 10.195.171.47/32, fdc1:d89e:b128:6a04::961/128


**Bernard**:

.. code-block:: ini

    [Peer]
    #
    # bernard.example.net, Rollernet, Phoenix
    #
    PublicKey = 5SAd89dXTesrxFZpNaRvwL/M11WjuevHJH/7Cv5LI3c=
    Endpoint = bernard.example.net:55867
    #
    # Allow bernard.vpn.example.net
    AllowedIPs = 10.195.171.174/32, fdc1:d89e:b128:6a04::3354/128


Charlotte and Teddy have their own subnets (home and office) behind them. If
these peers are capable of routing packets, we can access these private
networks trough the VPN.

**Charlotte**:

.. code-block:: ini

    [Peer]
    #
    # charlotte.example.net, Home, Frankfurt
    #
    PublicKey = xFXzNIDQ5NJkY0Pgg5hG1fZg0RAD51nnu5MMBbhlpCg=
    Endpoint = charlotte.example.net:55867
    #
    # Allow charlotte.vpn.example.net
    AllowedIPs = 10.195.171.241/32, fdc1:d89e:b128:6a04::29ab/128
    #
    # Allow home.example.net
    AllowedIPs = 172.27.88.0/24, fdc1:d89e:b128:13a6::/64


**Teddy**

.. code-block:: ini

    [Peer]
    #
    # teddy.example.net, Office, Frankfurt
    #
    PublicKey = 
    Endpoint = teddy.example.net:55867
    #
    # Allow teddy.vpn.example.net
    AllowedIPs = 10.195.171.0/32, fdc1:d89e:b128:6a04::/128
    #
    # Allow office.example.net
    AllowedIPs = 172.27.126.0/24, fdc1:d89e:b128:2615::/64


Open Up the Firewall
^^^^^^^^^^^^^^^^^^^^

If there is a Firewall, you need to open it up for UPD connections on our
chosen WireGuard port. Do this on all hosts.

Allow Incoming WireGuard Connections::

    $ sudo ufw allow 55867/udp


After connection, verification and encryption the VPN is set up, all
communication to and from the VPN are then coming from the automatically
created new virtual network interface :file:`wg0`.

To enable unrestricted network access from the VPN::

    $ sudo ufw allow in on wg0


Of course you are free to define you own more restrictive policy, depending on
how much you trust your peers.


Starting the VPN
----------------

Systemd takes care of the rest, with the help of the `wg-quick script
<https://manpages.debian.org/unstable/wireguard-tools/wg-quick.8.en.html>`_::

    sudo systemctl start wg-quick@wg0


References
----------

 * `WireGuard <https://www.wireguard.com/>`_

 * `WireGuard Quick Start <https://www.wireguard.com/quickstart/>`_

 * `Linode Ubuntu Tutorial <https://www.linode.com/docs/networking/vpn/set-up-wireguard-vpn-on-ubuntu/>`_

 * `Digital Ocean Ubuntu Tutorial <https://www.digitalocean.com/community/tutorials/how-to-create-a-point-to-point-vpn-with-wireguard-on-ubuntu-16-04>`_
