Network
=======

.. note::

    We use systemd for network configuration here. To override the traditional
    Ubuntu network configuration you need to enable the systemd network service.

    ::

        $ systemctl enable systemd-networkd.service
        $ systemctl start systemd-networkd.service


We have dual-Stack IPv4 and IPv6 on our internal network (LAN).

The IPv6 addresses are globally routed official internet addresses assigned to
us by our IPv6 internet provider.

The IPv4 addresses are
`private network <https://en.wikipedia.org/wiki/Private_network>`_
addresses.

.. note::

   The IP addresses shown here, are documentation examples. You need to use your
   own addresses. See :doc:`/router/index` for network and IP configuration.


The router supplies most of the relevant settings by auto-configuration, and we
like to keep it that way. The only exception are additional fixed IP addresses
for hosted services.



Device Configuration
--------------------

Our server has two 1Gbit/s Ethernet devices. **eth0** and **eth1**.

These days those names vary, depending on the manufacturer of the card and
device driver they use.

You can list the interfaces on you system with the following command::

    $ ifconfig


Link-Aggregation
^^^^^^^^^^^^^^^^

By bonding them together two one virtual interface we can increase throughput
and redundancy.

When bonded both interfaces can be used to send and receive traffic over what
appears to the system as one link.

Should one of the bonded links fail for some reason (broken cable or socket,
network card failure, accidental unplugging, etc.) the link will still be online
and usable, as long as one of the bonded interfaces still work.

This is done using the :term:`Link Aggregation Control Protocol` (:term:`LACP`)
also know as :term:`802.3ad`. The Ethernet switch or router that connects our
server to the network needs to support LACP as well for this to work.

The bonded interface will be called **bond0** and can be used as any other
interface by the system.

We define the **bond0** network device in the following configuration file
:file:`/etc/systemd/network/bond0.netdev`:

.. code-block:: ini

    [NetDev]
    Name=bond0
    Kind=bond

    [Bond]
    Mode=802.3ad
    TransmitHashPolicy=layer2
    LACPTransmitRate=fast
    MIIMonitorSec=1s
    UpDelaySec=100
    DownDelaySec=0
    AdSelect=bandwidth

The parameters in the [bond] section of the configuration may need to be
adjusted for your switch or router. See the "[Bond] Section Options" of the
`systemd netdev <http://manpages.ubuntu.com/manpages/xenial/en/man5/systemd.netdev.5.html#contenttoc16>`_
manual page.

Adding the physical Ethernet devices themselves to our created device is very
simple and self-explanatory:

Create and or edit the :file:`/etc/systemd/network/eth1.network`.

.. code-block:: ini

    [Match]
    Name=eth0

    [Network]
    Bond=bond0


Create and or edit the :file:`/etc/systemd/network/eth1.network`.

.. code-block:: ini

    [Match]
    Name=eth1

    [Network]
    Bond=bond0


Once this is done, we can move over to the configuration of **bond0** device as
our network interface.


Interface Configuration
-----------------------

Create and or edit the :file:`/etc/systemd/network/bond0.network`.

The match section just specifies which device will be used for this network
interface.

.. code-block:: ini

    [Match]
    Name=bond0

You can find additional configuration options in the [match] section of the
`systemd network man page <http://manpages.ubuntu.com/manpages/xenial/en/man5/systemd.network.5.html#contenttoc3>`_

Configuration of the [network] section is described
`here <http://manpages.ubuntu.com/manpages/xenial/en/man5/systemd.network.5.html#contenttoc5>`_

.. code-block:: ini

    [Network]
    BindCarrier=eth0 eth1
    Address=192.0.2.0.10/24
    Address=2001:db8:c0de::10/64
    Gateway=192.0.2.0.1
    DNS=192.0.2.0.14
    DNS=2001:db8:c0de::14
    DNS=192.0.2.0.1
    DNS=2001:db8:c0de::1
    Domains=lan
    DNSSEC=allow-downgrade
    DNSSECNegativeTrustAnchors=lan
    IPv6PrivacyExtensions=true
    IPv6AcceptRouterAdvertisements=true


IP Addresses
------------

We add the static IP addresses of our hosted services directly to the [network]
section.

Add as many addresses as needed, as long as they are not already defined on
other devices or assigned trough auto-configuration. This gets easier if you
reserve a range like **10** to **90** to this server and only assign addresses
from that range.

For easier recognition and administration the last number of any IPv4 and IPv6
address is identical (e.g. 192.0.2.\ **10** and 2001:db8::\ **10**\ ).

.. code-block:: ini

    [Network]
    ...

    ; Port-forwarded HTTP/HTTPS connections from firewall/router
    Address=192.0.2.10/24
    Address=2001:db8::10/64

    ; www.example.net
    Address=192.0.2.11/24
    Address=2001:db8::11/64

    ; cloud.example.net
    Address=192.0.2.12/24
    Address=2001:db8::12/64

    ; xmpp.example.net
    Address=192.0.2.13/24
    Address=2001:db8::13/64

    ; ns1.example.net
    Address=192.0.2.14/24
    Address=2001:db8::15/64

    ...


Legacy Network Leftovers
------------------------

It is recommended to alter the traditional Ubuntu configuration
:file:`/etc/network/interfaces` to the bare minimum, to not interfere with
systemd-networkd service::


    # The loopback network interface
    auto lo
    iface lo inet loopback


In practice I left them as they where when I switched to systemd on my host and
had no issues whatsoever.


Restart the Network Service
---------------------------

Restart the network services with::

    $ systemctl restart systemd-networkd



Useful Commands
----------------


Add new IP address
^^^^^^^^^^^^^^^^^^

Here is how to add a new IP addresses on the fly, without restarting the service.

..  note::

    If the newly added address is not added in the
    :file:`/etc/systemd/network/bond0.network` it will be lost after system
    reboot.

Add IPv4 address::

    $ sudo ip addr add 192.0.2.99/24 dev eth0

Add IPv6 address::

    $ sudo ip addr add 2001:db8:26:845::99/64 dev eth0


Show IP addresses
^^^^^^^^^^^^^^^^^

To show all currently active IP addresses::

    $ ip addr show


Network Restart
^^^^^^^^^^^^^^^

Restart the network services with::

    $ systemctl restart systemd-networkd

Although there is a networking service, it can not be restarted. The usual
command `sudo service networking restart` fails with a message like the
following::

    stop: Job failed while stopping
    start: Job is already running: networking

This is intentional on Ubuntu servers since 14.04

Instead of the service, the interfaces have to be restarted::

    sudo ifdown eth0 && sudo ifup eth0


Removing a IPv6 Route
^^^^^^^^^^^^^^^^^^^^^

::

    sudo ip -6 route del ::/0 via fe80::2cb0:5dff:fe7f:2dba

