.. image:: tor-logo.*
    :alt: Tor Logo
    :align: right

Tor Anonymity Network
=====================

`Tor <https://www.torproject.org/>`_ is free software and an open network that
helps you defend against traffic analysis, a form of network surveillance that
threatens personal freedom and privacy, confidential business activities and
relationships, and state security.


Installation
------------

We add the package repository to get the most current and stable version of the
software directly from the Tor project::

    $ sudo -s
    $ echo "deb http://deb.torproject.org/torproject.org `lsb_release -sc` main" \
        > /etc/apt/sources.list.d/torproject.org-mainline.list

    $ echo "deb-src http://deb.torproject.org/torproject.org `lsb_release -sc` main" \
        >> /etc/apt/sources.list.d/torproject.org-mainline.list
    $ exit

All software packages released by the project are signed with a GPG key.
Add the signing key to the systems trusted keyring::

    $ gpg --keyserver keys.gnupg.net --recv 886DDD89
    $ gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -

Update the software package catalog::

    $ sudo apt-get update

Install the tor package::

    $ sudo apt-get install tor deb.torproject.org-keyring tor-arm

Reference:
 * https://www.torproject.org/docs/debian.html.en


Multiple Tor Services
---------------------

The Tor software has two different modes of operation:

 1. Tor Client
 2. Tor Relay

A Tor Client is what you use to connect yourself to the Tor network while Tor 
Relays are the ones who create and provide the Tor network to the Tor clients.

Additionally Hidden Services can be provided either by Tor Clients or Tor Relays. 

But running Hidden Services on a Relay is no recommended as there might be
potential security issues. Mostly because Tor Relays are publicly known services.
Their IP addresses are published along with various statistical data.

To provide Tor Hidden Services on a machine who acts also as a Relay, it is
recommended to run the Hidden Services from a client in a separate Tor process.

But since the Tor Software installation provides only a single init service, we
have to provide our own service scripts and configuration files.

The following pages describe how we setup a Relay and a Client on the same
machine:

.. toctree::
   :maxdepth: 1

   tor-relay
   tor-hidden-service

