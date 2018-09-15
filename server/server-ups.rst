.. _server-ups:

Uninterruptible Power Supply
============================

.. image:: nut-logo.*
    :alt: Network UPS Tools (NUT) Logo
    :align: right


.. contents::
  :local:


`Network UPS Tools (NUT) <https://networkupstools.org/>`_ is a client/server
monitoring system that allows computers to share uninterruptible power supply
(:index:`ups`) and power distribution unit (PDU) hardware. Clients
access the hardware through the server, and are notified whenever the power
status changes.


Topology
--------

In the following scenario, the server acts as the master. He monitors and
controls the UPS via USB data cable and keeps the slaves updated about the
current situation. 

.. image:: UPS.*
    :alt: UPS Diagram
    :align: center


The router and the :abbr:`NAS (Network Attached Storage)` act as slaves. They
get status updates about the UPS battery state and power supply from the
master.

If the master gets notified by the UPS that its battery is getting close to
depletion, he will instruct the slaves to shutdown.

The master will start its own shutdown procedure and instruct the UPS to cut
the power, after he has confirmation from all the slaves, that they are
shutting down.

The Wi-Fi :abbr:`AP (Access Point)` has no Network UPS Tools installed, thus
he is not aware of the current situation. He will however be shut down by the
master via remote SSH command, in case the battery is low during a power
outage.

The Ethernet switch, has also no knowledge about the UPS. He will shut down
uncontrolled, when the UPS battery is depleted or when the UPS is ordered to
cut the power by the master.


Shutdown Plan
-------------

Here is what happens step-by-step in case of main power loss:

#. Main power failure occurs:

    #. UPS device switches power to battery.

    #. UPS device notifies master with a "On Battery" event message.

    #. Master notifies slaves with a "On Battery" event message.

#. USP Battery is getting close to depletion:

    #. UPS device notifies master with a "Battery Low" event message.

    #. Master issues "Forced Shutdown" command message to all slaves.

    #. Master issues remote shutdown commands by SSH to any unmanaged devices.

    #. Unmanaged devices start their shutdown procedure.

    #. Slaves receive the "Forced Shutdown" command message.

    #. Slaves may issue "Shutdown" notification message to their users.

    #. Slaves wait the set "Final Delay" time. This is to process the above notifications.

    #. Slaves notify the master with a "Notify Shutdown" event message.

    #. Slaves start their shutdown procedure:

        #. Ends all running processes.

        #. Unmounts all file systems.

        #. Remounts file systems as read-only.

        #. Halts the system (but doesn't power off).

    #. Master waits until he received "Notify Shutdown" event messages from all slaves.

    #. Master issues a "Shutdown" notification message to its users.

    #. Master waits the set "Final Delay" time. This is to process the above notifications.

    #. Master starts his shutdown procedure:

        #. Sets the "Killpower" flag

        #. Ends all running processes.

        #. Unmounts all file systems.

        #. Remounts file systems as read-only.

        #. Looks for the "Killpower" flag.

        #. Issues the "Kill Power" command to the UPS device.

        #. Halts the system (but doesn't power off).

    #. UPS device receives the "Kill Power" command from the master:

        #. UPS waits for the "Shutdown Delay" time to pass. This is to give all system enough time to properly shut down.

        #. UPS device cuts power on all outlets. 

    #. All connected systems loose power.

#. Main power supply has been restored:

    #. UPS device starts to reload its battery.

    #. UPS device waits for the "Startup Delay" time to pass. This is to reload the battery to a safe minimum level.

    #. UPS device restores power on all outlets.

    #. All connected systems start up.


Installation
------------

::

    sudo apt install nut


Configuration
-------------


nut.conf 
^^^^^^^^

This file tells the installed Network UPS Tools in which mode it should run.
Depending on this setting the required modules are then started.

:download:`/etc/nut/nut.conf </server/config-files/etc/nut/nut.conf>`

.. literalinclude:: /server/config-files/etc/nut/nut.conf
    :language: ini
    :linenos:


See the 
`nut.conf(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/nut.conf.5.html>`_ 
manpage for more possible options.


ups.conf
^^^^^^^^

This file is read by the driver controller. It tells the Network UPS Tools
what kind of UPS device it has to work with. Some settings to control
communications with the device. Also some of the UPS device parameters can be
overridden.

:download:`/etc/nut/ups.conf </server/config-files/etc/nut/ups.conf>`

.. literalinclude:: /server/config-files/etc/nut/ups.conf
    :language: ini
    :linenos:


See the 
`ups.conf(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/ups.conf.5.html>`_ 
and 
`usbhid-ups(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/usbhid-ups.8.html>`_
manpages for more possible options.


upsd.conf
^^^^^^^^^

Here we control access to the server and set some other miscellaneous
configuration values. 

:download:`/etc/nut/upsd.conf </server/config-files/etc/nut/upsd.conf>`

.. literalinclude:: /server/config-files/etc/nut/upsd.conf
    :language: ini
    :linenos:


See the 
`upsd.conf(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/upsd.conf.5.html>`_ 
manpage for more possible options.


upsd.users
^^^^^^^^^^

Administrative commands such as setting variables and the instant commands are
powerful, and access to them needs to be restricted. This file defines who may
access them, and what is available.

Each user gets its own section. The fields in that section set the parameters
associated with that user’s privileges. The section begins with the name of
the user in brackets, and continues until the next user name in brackets or
EOF. These users are independent of :file:`/etc/passwd`.


:download:`/etc/nut/upsd.users </server/config-files/etc/nut/upsd.users>`

.. literalinclude:: /server/config-files/etc/nut/upsd.users
    :language: ini
    :linenos:


See the 
`upsd.users(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/upsd.users.5.html>`_ 
manpage for more possible options.


upsmon.conf
^^^^^^^^^^^

This file’s primary job is to define the systems that 
`upsmon(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/upsmon.8.html>`_ 
will monitor and to tell it how to shut down the system when necessary.

Additionally, other optional configuration values can be set in this file.


:download:`/etc/nut/upsmon.conf </server/config-files/etc/nut/upsmon.conf>`

.. literalinclude:: /server/config-files/etc/nut/upsmon.conf
    :language: ini
    :linenos:


See the 
`upsmon.conf(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/upsmon.conf.5.html>`_ 
manpage for more possible options.


upssched.conf
^^^^^^^^^^^^^

This file controls the operations of 
`upssched(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/upssched.8.html>`_, 
the timer-based helper program for 
`upsmon(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/upsmon.8.html>`_.

Here we can define our own script, which will be executed on certain events.

:download:`/etc/nut/upssched.conf </server/config-files/etc/nut/upssched.conf>`

.. literalinclude:: /server/config-files/etc/nut/upssched.conf
    :language: sh
    :linenos:


See the 
`upssched.conf(5) <http://manpages.ubuntu.com/manpages/bionic/en/man5/upssched.conf.5.html>`_ 
manpage for more possible options.


Securing Configuration Files
----------------------------

Secure the configuration files, to protect the various access crontrols and
credentials.

::

    $ sudo chown -R root:nut /etc/nut
    $ sudo chmod 0770 /etc/nut
    $ sudo chmod 0640 /etc/nut/*



Scheduled Command Script
------------------------

We use this to send out remote commands by SSH to systems who's power-lines
are connected to the UPSm but they don't have Network UPS Tools installed and
so won't be able to know by themselves when they should shutdown.

In the following example this will be a MikroTik device called "ap.example.com"

We assume that there is a user profile called **nut** on the remote device and
that it has a properly installed SSH public key. to allow password-less
logins.

We create the script for sending out remote commands:

:download:`/usr/local/bin/ups-scheduled-tasks </server/config-files/etc/nut/ups-scheduled-tasks>`

.. literalinclude:: /server/config-files/etc/nut/ups-scheduled-tasks
    :language: sh
    :linenos:


Make the script executable by the **nut** system user::

    $ sudo chown nut:nut /usr/local/bin/ups-scheduled-tasks
    $ sudo chmod 740 /usr/local/bin/ups-scheduled-tasks



Powering Off the UPS
--------------------

After the server has terminated all processes, unmounted file-systems and re-mounted them read-only, it is safe to cut off the power.

The following script will be executed by the 
`systemd-halt.service(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/systemd-halt.service.8.html>`_ 
just before turning off the CPU, by placing it in the directory :file:`/lib/systemd/system-shutdown`.

:download:`/lib/systemd/system-shutdown/nut.shutdown </server/config-files/etc/nut/nut.shutdown>`


.. literalinclude:: /server/config-files/etc/nut/nut.shutdown
    :language: sh
    :linenos:


Make it executable::

    $ sudo chmod +x /lib/systemd/system-shutdown/nut.shutdown


See `upsdrvctl(8) <http://manpages.ubuntu.com/manpages/bionic/en/man8/upsdrvctl.8.html>`_



UPS Device Configuration
------------------------

Depending on your model, some settings of your USP device can be set, by
changing values of variables stored in the device :term:`EEPROM`.

This is done the
`upsrw <http://manpages.ubuntu.com/manpages/bionic/en/man8/upsrw.8.html>`_ 
command. 

To get a list of the writable configuration variables on your model::

    $ upsrw apc@localhost

    [battery.charge.low]
    Remaining battery level when UPS switches to LB (percent)
    Type: STRING
    Maximum length: 10
    Value: 10

    [battery.runtime.low]
    Remaining battery runtime when UPS switches to LB (seconds)
    Type: STRING
    Maximum length: 10
    Value: 120

    [input.sensitivity]
    Input power sensitivity
    Type: STRING
    Maximum length: 10
    Value: medium

    [input.transfer.high]
    High voltage transfer point (V)
    Type: STRING
    Maximum length: 10
    Value: 294

    [input.transfer.low]
    Low voltage transfer point (V)
    Type: STRING
    Maximum length: 10
    Value: 176

    [ups.delay.shutdown]
    Interval to wait after shutdown with delay command (seconds)
    Type: STRING
    Maximum length: 10
    Value: 20




Timing
------

For the above procedure to work as intended timing is critical.

To be on the safe side:

    #. Every device needs to have enough time to be safely halted.

    #. Additional processing time and delays have to be added.

    #. The UPS device needs to send its "Low Battery" notification, when there
       is just about enough battery time left for the whole process to
       complete.


.. image:: UPS-FSD-Timeline.*
    :alt: UPS Forced Shutdown Timeline
    :align: center


Power Down Time
^^^^^^^^^^^^^^^^

For every device, the master, the slaves and any remote controller device:

 #. Have a stop watch ready
 #. Start the stopwatch and initiate a full power down of the device.
 #. Stop the stopwatch, when the device has turned its power down.
 #. Note the time of slowest device.
 #. Add configured delays from :file:`upsmon.conf` like HOSTSYNC and FINALDELAY.

Device power down times:

============================ ========== ====== ==========
Device                       Power Down Delays Total Time
============================ ========== ====== ==========
Server (master)                  20 sec 20 sec     40 sec
**NAS (slave, slowest)**         90 sec  5 sec **95 sec**
Router (slave)                   10 sec  5 sec     15 sec 
Wi-Fi AP (remote controlled)     10 sec  5 sec     15 sec
============================ ========== ====== ==========


"Low Battery" Time
^^^^^^^^^^^^^^^^^^

The minimum required "Low Battery" time of the UPS is at least the time needed
to shut down the slowest device.

We can set this by programming the :term:`EEPROM` of the UPS device with the
`upsrw <http://manpages.ubuntu.com/manpages/bionic/en/man8/upsrw.8.html>`_ 
command::

    $ upsrw -s battery.runtime.low=120 -u adminuser apc@localhost


"Shutdown Delay" Time
^^^^^^^^^^^^^^^^^^^^^

If the slowest device is a slave, the master will tell the UPS to cut the
power, before that slave has completed his shutdown.

The UPS must therefore delay the the power-off, until the last slave has
completed his shutdown:

Slowest slave time - master time = "Shutdown Delay" time

95 sec - 40 sec = 55 sec

Luckily our UPS device can be programmed to delay the power-off::


    $ upsrw -s ups.delay.shutdown=60 -u adminuser apc@localhost



"Power-On Delay" Time
^^^^^^^^^^^^^^^^^^^^^

When the power comes back, the UPS should reload the battery to a safe level,
before turning the power back on. By safe level, I mean: The battery must have
been charged enough that all devices can fully boot, and there would be still
enough power for the whole configured "Low Battery" time.

Without an appropriate re-charging delay, the power could come back just for a
short time (which is often the case in power-failures), the devices start to
boot up, but will be powered off again uncontrolled either during boot or
during shutdown.

Unfortunately this feature not supported on my UPS device model.

There might be features who provide similar functionality:

    * ups.delay.start

    * "Reboot Delay" time
    
    * "Minimum Charge" to return online

    * "Load On Delay" time (load.on.delay)


If I could, I would set my UPS to roughly charge double from what is needed by
the "Low Battery" time::

    $ upsrw -s ups.delay.poweron=240 -u adminuser apc@localhost


References
----------

 * `Network UPS Tools User Manual <https://networkupstools.org/docs/user-manual.chunked/index.html>`_