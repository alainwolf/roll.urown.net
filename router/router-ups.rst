.. _router-ups:

Uninterruptible Power Supply
============================

.. image:: nut-logo.*
    :alt: Network UPS Tools (NUT) Logo
    :align: right

.. note::
   The following is valid for OpenWRT Release 18.06. Earlier OpenWRT or LEDE
   versions used a different approach.


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

::

    router$ opkg update
    router$ opkg install nut-upsmon



Configuration
-------------

In our scenario, our UPS is connected directly to our server via USB. 

.. code-block:: text


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
                           |                         |
                           |--------- USB -----------|






We therefore connect the router to the NUT daemon running on the server to get
status information about our power supply and receive shutdown-commands.

Edit the :file:`/etc/config/nut-monitor`::

    config upsmon 'upsmon'
        option minsupplies 1
        option shutdowncmd /sbin/halt
        option notifycmd /usr/sbin/ssmtp
        list defaultnotify SYSLOG
        option pollfreq 5
        option pollfreqalert 5
        option hostsync 15
        option deadtime 15
        option powerdownflags /var/run/killpower
        option finaldelay 5 # final delay

    config slave
       option upsname ups
       option hostname 192.0.2.0.10
       option username upsmon
       option password secret


.. note::
   As of OpenWRT Release 18.06.0 some parts (luci-app) are missing. This is expected to change with 18.06.1 due at some time in August 2018.


Replace the non-working symbolic link in :file:`/etc/nut/upsmon.conf` pointing to the non-existing file :file:`/var/etc/nut/upsmon.conf` with a real file::

    router$ rm /etc/nut/upsmon.conf
    router$ touch /etc/nut/upsmon.conf


Edit the file :file:`/etc/nut/upsmon.conf` as follows::

    RUN_AS_USER nut
    MINSUPPLIES 1
    SHUTDOWNCMD "/sbin/halt"
    NOTIFYCMD "/usr/sbin/ssmtp"
    POLLFREQ 5
    POLLFREQALERT 5
    HOSTSYNC 15
    DEADTIME 15
    POWERDOWNFLAG /var/run/killpower
    NOTIFYFLAG ONLINE SYSLOG
    NOTIFYFLAG ONBATT SYSLOG
    NOTIFYFLAG LOWBATT SYSLOG
    NOTIFYFLAG FSD SYSLOG
    NOTIFYFLAG COMMOK SYSLOG
    NOTIFYFLAG COMMBAD SYSLOG
    NOTIFYFLAG SHUTDOWN SYSLOG
    NOTIFYFLAG REPLBATT SYSLOG
    NOTIFYFLAG NOCOMM SYSLOG
    NOTIFYFLAG NOPARENT SYSLOG
    RBWARNTIME 43200
    NOCOMMWARNTIME 300
    FINALDELAY 5
    CERTVERIFY 0
    FORCESSL 0
    MONITOR ups@192.0.2.0.10 1 monuser secret slave


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

    server$ sudo -u nut upsdrvctl -t shutdown
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


