.. _router-ups:

Uninterruptible Power Supply
============================

.. image:: nut-logo.*
    :alt: Network UPS Tools (NUT) Logo
    :align: right


.. contents::

`Network UPS Tools (NUT) <https://networkupstools.org/>`_ is a client/server
monitoring system that allows computers to share uninterruptible power supply
(:index:`UPS`) and power distribution unit (:term:`PDU`) hardware. Clients
access the hardware through the server, and are notified whenever the power
status changes.

The package **nut-upsmon** provides the client program, that is responsible for the
most important part of UPS monitoring - shutting down the system when the power
goes out.

The :file:`upsmon` command can call out to other helper programs for
notification purposes during power events. :file:`upsmon` can monitor multiple
systems using a single process. Every UPS that is defined in the
:file:`upsmon.conf` configuration file is assigned a power value and a type
(slave or master).


Installation
------------

These are the OpenWrt software packages to install:

* **nut-server**: NUT server or standalone; only for the host attached directly
  to the UPS. Note will require a 'nut-dirver-xxx' driver to actually connect to
  the UPS.
* **nut-driver-usbhid-ups**: Driver for most USB attached UPS devices.
* **nut-driver-dummy-ups**: Allows to provides virtual UPS as alias of real
  ones.
* **nut-upsmon**: Monitoring and/or triggering shutdown (e.g. client mode; can
  be on a server too and is in fact recommended on all hosts).
* **nut-upssched**: Schedule script actions from some time after a UPS event.

::

    router$ opkg update
    router$ opkg install nut-driver-dummy-ups nut-driver-usbhid-ups nut-server \
        nut-upsmon nut-upssched luci-app-nut collectd-mod-nut


Topology
--------

In our scenario, our UPS is connected directly to our router via USB.

.. code-block:: text

                          |--------- USB -----------|
                          |                         |
                        |-----|                 |--------|
                        |     |... power-line...| Router |---WAN---
                        |     |                 |--------|
                        |     |                      |
                        |     |                     LAN
                        |     |                      |
                        |     |                 |--------|
                        | UPS |... power-line...| Switch |
                        |     |                 |--------|
                        |     |                      |
                        |     |                     LAN
                        |     |                      |
                        |     |                 |--------|
    |AC|...power-line...|     |... power-line...| Server |
                        |-----|                 |--------|

We therefore connect servers, NAS and other equipment to the NUT daemon running
on the router to get status information about our power supply and receive
shutdown-commands.


NUT Server
----------

The NUT server connects directly to UPS-device by USB-cable. It then provides
the UPS services to local and remote clients.

Edit the file :file:`/etc/config/nut_server`:

.. literalinclude:: /router/files/etc/config/nut_server


NUT Monitor
-----------

The NUT monitoring client connects to the local NUT dameon as a master and is
the one deciding what actions have to be taken based on the condition of the
power supply.

Edit the file :file:`/etc/config/nut_monitor`:

.. literalinclude:: /router/files/etc/config/nut_monitor


Notify Command Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In the above :file:`/etc/config/nut_monitor` file we defined the option
**notifycmd** as :file:`/usr/sbin/upssched`. And also added "EXEC" to the list
of acttions to be taken to **defaultnotify**

The **upssched** program needs additional configuration which is not provided by
OpenWrt's Luci interface and therefore is setup directly in the NUT
configuration file :file:`/etc/nut/upssched.conf`:

.. literalinclude:: /router/files/etc/nut/upssched.conf

NUT Monitor runs under the nutmon user profile. He needs to be able to read the
upssched configuration file::

  $ chown nutmon:nutom /etc/nut/upssched.conf

Create the directory for the FIFO pipe and lockfile in a custom persistent
location and set the owner to one used by the NUJT monitor on OpenWrt::

    $ mkdir -p /srv/nut/upssched
    $ chown nutmon /srv/nut/upssched


Notify Command Script
^^^^^^^^^^^^^^^^^^^^^

Copy the very minimal provided sample script :file:`/usr/bin/upssched-cmd` to
your own location, i.e. :file:`/root/upssched-cmd` and customize it to your
needs:

.. literalinclude:: /router/files//root/upssched-cmd


Turris OS notifications
^^^^^^^^^^^^^^^^^^^^^^^

If you happen to be the lucky owner of a `Turris <https://www.turris.com/en/>`_
device, you can use their built-in
`notification system <https://docs.turris.cz/basics/reforis/notifications/reforis-notifications/>`_.

The notifier displays important messages on the homepage of their reForis
web-interface. They are preserved accross reboots until aknowldged and deleted
by the user.

If setup correctly notifications will also be sent out by mail.


Testing
-------

Testing the whole chain of events, notifications and actions of network with
multiple devices, some of them unaware (i.e. Ethernet switches) is crucial.
You can be almost sure, something will not work as expected.

Things to look for while testing:

 * Can master and slaves still communicate while on battery power?
 * Do all slaves receive the shutdown command from the master when battery
   power is low?
 * Does the master wait long enough for all the slaves to react on the shutdown
   command?
 * Do all devices have enough time (default is 2 minutes) to power down?
 * Do all devices startup again when power returns?
 * What happens when power returns in the middle of the shutdown procedure?


Testing the Shutdown Sequence
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The first step is to see how :file:`upsdrvctl` will behave without actually
turning off power. To do so, use the :file:`-t` argument:

On the master::

    router$ nut upsdrvctl -t shutdown
    Network UPS Tools - UPS driver controller 2.7.2
    *** Testing mode: not calling exec/kill
       0.000000
    ...
       0.000690 Shutdown UPS: ups
       0.000711 exec:  /lib/nut/usbhid-ups -a ups -k


The second step is to let master actually tell the UPS to turn off the power::

    /usr/local/ups/sbin/upsmon -c fsd


The master and the slaves should then start their shutdown procedure as if the
battery had gone critical. Including turning off power by the UPS at the end.

This is much easier on your UPS equipment, and it beats crawling under a desk
to find the plug.


References
----------

 * `OpenWRT User Guides: NUT (Network UPS Tools) <https://openwrt.org/docs/guide-user/services/ups/software.nut>`_

 * `NUT manual: Configuring automatic shutdowns <https://networkupstools.org/docs/user-manual.chunked/ar01s06.html#UPS_shutdown>`_

 * `upsmon - UPS monitor and shutdown controller manual page <https://networkupstools.org/docs/man/upsmon.html>`_

 * `upsdrvctl - UPS driver controller maual page <https://networkupstools.org/docs/man/upsdrvctl.html>`_


