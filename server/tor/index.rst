.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right

Tor Anonymity Network
=====================

`Tor <https://www.torproject.org/>`_ is a program you can run on your computer
(or in this case a server) that helps keep you safe on the Internet. It
protects you by bouncing your communications around a distributed network of
relays run by volunteers all around the world: it prevents somebody watching
your Internet connection from learning what sites you visit, and it prevents
the sites you visit from learning your physical location. This set of
volunteer relays is called the Tor network.

The way most people use Tor is with
`Tor Browser <https://www.torproject.org/download/>`_, which is a version of
Firefox that fixes many privacy issues. You can read more about Tor on our
about page.


Installation
------------

.. note::

    Its highly recommended to use the
    `software repository of the Tor project
    <https://support.torproject.org/apt/tor-deb-repo/>`_ and not use the
    packages provided by your Linux distribution.

Get and install the release key of Tor project software repository, the URL
for the download of the key is found on their `Tor Debian Package Repository
page <https://support.torproject.org/apt/tor-deb-repo/>`_::

    $ TOR_APT_KEY="/usr/share/keyrings/tor-archive-keyring.gpg"
    $ curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
            | gpg --dearmor | sudo tee "$TOR_APT_KEY" > /dev/null


Get your systems CPU architecture::

    $ ARCHITECTURE="$( dpkg --print-architecture )"

Get your the release code-name of your Linux distribution::

    $ DISTRIBUTION="$( lsb_release -sc )"

Add the Tor project software repository to your systems software catalog::

    $ echo "deb     [arch=${ARCHITECTURE} signed-by=${TOR_APT_KEY}] https://deb.torproject.org/torproject.org $DISTRIBUTION main" \
        | sudo tee /etc/apt/sources.list.d/tor.list > /dev/null
    $ echo "deb-src [arch=${ARCHITECTURE} signed-by=${TOR_APT_KEY}] https://deb.torproject.org/torproject.org $DISTRIBUTION main" \
        | sudo tee -a /etc/apt/sources.list.d/tor.list > /dev/null

We are now ready to update the software package catalog::

    $ sudo apt update

Install the tor package::

    $ sudo apt install tor deb.torproject.org-keyring


Multiple Tor Services
---------------------

The Tor software has two different modes of operation:

 1. Tor Client
 2. Tor Relay

A Tor Client is what you use to connect yourself to the Tor network while Tor
Relays are the ones who create and provide the Tor network to the Tor clients.

Additionally "Tor Onion Services" can be provided either by Tor Clients or Tor
Relays.

But running Tor Onion Services on a Relay is no recommended as there might be
potential security issues. Mostly because Tor Relays are publicly known
services. Their IP addresses are published along with various statistical
data.

If you want to provide Tor Onion Services on a machine who also runs a Tor
Relay, it is strongly recommended to run the Tor Onion Services from a Tor
client which runs in a separate process as the Tor client providing the Tor
Relay service.

But since the Tor Software installation provides only a single init service, we
have to provide our own service scripts and configuration files.

The following pages describe how we setup a Relay and a Client on the same
machine:

.. toctree::
   :maxdepth: 1

   tor-relay
   tor-onion-services

