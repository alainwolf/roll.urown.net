Network Time Synchronization
============================

I noticed that my Ubuntu desktop computers are synchronizing their clocks with
*ntp.ubuntu.com*. This happens even the if they get addesses of local
NTP-servers trough DHCP.

timesyncd
---------

On Ubuntu the system clock is synchronized by the *timesyncd* systemd service.
*timesyncd* was introduced with Ubuntu 16.04 and replaced *chrony*. *chrony* did
replace the now depracated classic *ntp client*.

The *timesyncd* service is configured trough its configuration file
:file:`/etc/systemd/timesyncd.conf`.

The manpage of
`timesyncd.conf(5) <https://manpages.ubuntu.com/manpages/focal/en/man5/timesyncd.conf.5.html>`_
says the timeservers to contact are set with a space-separated list of NTP
server host names or IP addresses in the **"NTP="** seeting. 

During runtime this list is combined with any per-interface NTP servers acquired
from **systemd-networkd**.

The file also contains a **"FallbackNTP="** setting, which is only used no other
NTP server information is known.

If neither **"NTP="** nor **"FallbackNTP="** are set, a compiled-in list of NTP
servers is used instead.

Taking a look at the configuration shows that nothing is set, but the
compiled-in options are shown:

.. code-block:: ini

    #  This file is part of systemd.
    #
    # Entries in this file show the compile time defaults.
    # You can change settings by editing this file.
    # Defaults can be restored by simply deleting this file.
    #
    # See timesyncd.conf(5) for details.

    [Time]
    #NTP=
    #FallbackNTP=ntp.ubuntu.com
    #RootDistanceMaxSec=5
    #PollIntervalMinSec=32
    #PollIntervalMaxSec=2048


So I assume that *ntp.ubuntu.com* is used as time-server because the list
remains empty, even if our DHCP sever is sending out NTP server addesses to use.

Let's change that first, so it will no longer phone home by editing
:file:`/etc/systemd/timesyncd.conf`:

.. code-block:: ini

    #  This file is part of systemd.
    #
    # See timesyncd.conf(5) for details.

    [Time]
    FallbackNTP=ch.pool.ntp.org


Restart the service afterwards::

    $ sudo systemctl restart systemd-timesyncd.service 


systemd-networkd
----------------

In systemd-networkd is configured via :file:`/etc/systemd/networkd.conf` and
various configuration file in the directory :file:`/etc/systemd/network/`.

But the manpage for the
`systemd network-configuration <https://manpages.ubuntu.com/manpages/focal/en/man5/systemd.network.5.html>`_,
states that you can either set an NTP server address yourself with the
**"NTP="** setting in the **"[Network]"** section, or you can set the option
**"UseNTP="** in the **"[DHCPV4]"** and **"[DHCPv6]"** sections. Both are
**"true"** by default.

So if NTP servers supplied trough DHCP are passed on to timesyncd by default,
why isn't that actually happening?

As it turns out, Ubuntu Desktop doesn't actually use
**systemd-networkd.service**. Its disabled in favor of the
**NetworkManager**.


NetworkManager
--------------

Contrary to **systemd-networkd**, **NetworkManager** is not capable to
communicate with systemd-timesyncd to set the NTP server addesses automatically.

But with **NetworkManager**, scripts can be placed in specific subdirectories
of the :file:`/etc/NetworkManager/dispatcher.d/` directory to be triggered by
the *NetworkManager-dispatcher.service* on related network events.

The following script is inspired by the ArchLinux wiki, to be placed in
:download:`/etc/NetworkManager/dispatcher.d/10-update-timesyncd <../config-files/etc/NetworkManager/dispatcher.d/10-update-timesyncd>`:

.. literalinclude:: ../config-files/etc/NetworkManager/dispatcher.d/10-update-timesyncd


Make it executable by the **root** user only::

    $ chmod 0764 /etc/NetworkManager/dispatcher.d/10-update-timesyncd

References
----------

* `Synchronizing your systems time <https://ubuntu.com/server/docs/network-ntp>`_
* `systemd-timesyncd.service <https://manpages.ubuntu.com/manpages/focal/en/man8/systemd-timesyncd.8.html>`_ Ubuntu man page.
* `Gnome Network Manager <https://wiki.gnome.org/Projects/NetworkManager>`_
* `ArchLinux Wiki on Sytemd-timesyncd <https://wiki.archlinux.org/index.php/Systemd-timesyncd>`_
