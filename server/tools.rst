Server Additions
================

Following is recommended for a long-running system with no interactive users.


Suspend & Hibernate
-------------------

If you run your server on a laptop, it should not power-down, hibernate or
suspend, when idle or the lid is closed. In Ubuntu this is handled by *systemd*
and its *login-manager*. There is a configuration file called
:file:`/etc/systemd/logind.conf` and a man page called :manpage:`logind.conf`.

.. code-block:: nginx
   :linenos:
   :emphasize-lines: 20-22,27

    #  This file is part of systemd.
    #
    #  systemd is free software; you can redistribute it and/or modify it
    #  under the terms of the GNU Lesser General Public License as published by
    #  the Free Software Foundation; either version 2.1 of the License, or
    #  (at your option) any later version.
    #
    # See logind.conf(5) for details

    [Login]
    #NAutoVTs=6
    #ReserveVT=6
    #KillUserProcesses=no
    #KillOnlyUsers=
    #KillExcludeUsers=root
    Controllers=blkio cpu cpuacct cpuset devices freezer hugetlb memory perf_event net_cls net_prio
    ResetControllers=
    #InhibitDelayMaxSec=5
    #HandlePowerKey=poweroff
    HandleSuspendKey=ignore
    HandleHibernateKey=ignore
    HandleLidSwitch=ignore
    #PowerKeyIgnoreInhibited=no
    #SuspendKeyIgnoreInhibited=no
    #HibernateKeyIgnoreInhibited=no
    #LidSwitchIgnoreInhibited=yes
    IdleAction=ignore
    #IdleActionSec=30min


Restart of the :command:`systemd-logind` service is required to activate the
changes::

    $ sudo restart systemd-logind


Automatic Updates
-----------------

.. note::
   The system must be able to send out mails, for this to work. See
   :doc:`/server/mail/index`

There are to things here:

 1. Security updates should be installed automatically.

 2. Other updates should be just downloaded but not automatically installed.

In either case we will be notified by mail.


Unattended Upgrades
^^^^^^^^^^^^^^^^^^^

The **unattended-upgrades** package is used to automatically install updated
packages. It is installed if selected during OS installation.

If it is not already, install it as follows::

    $ sudo apt install unattended-upgrades

To configure **unattended-upgrades**, edit the file
:file:`/etc/apt/apt.conf.d/50unattended-upgrades` and adjust the following to
fit your needs::

    Unattended-Upgrade::Allowed-Origins {
            "${distro_id}:${distro_codename}";
            "${distro_id}:${distro_codename}-security";
    //      "${distro_id}:${distro_codename}-updates";
    //      "${distro_id}:${distro_codename}-proposed";
    //      "${distro_id}:${distro_codename}-backports";
    };

    Unattended-Upgrade::MinimalSteps "true";
    Unattended-Upgrade::Mail "root";


To activate **unattended-upgrades**, edit
:file:`/etc/apt/apt.conf.d/20auto-upgrades` and set the appropriate apt
configuration options::

    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Download-Upgradeable-Packages "1";
    APT::Periodic::AutocleanInterval "7";
    APT::Periodic::Unattended-Upgrade "1";


apticron
^^^^^^^^

**apticron** will configure a cron job to email an administrator information
about any packages on the system that have updates available, as well as a
summary of changes in each package.

To install the apticron package, in a terminal enter::

    $ sudo apt install apticron

Once the package is installed edit :file:`/etc/apticron/apticron.conf`, to set
the email address and other options::

    EMAIL="root@example.net"


Users and Groups
----------------

Webservers run as the user **www-data**, with the security benefit, that they
can't access anything in the system, unless the user or group **www-data** has
been specifically given access-rights. The downside is, server operators can't
see whats going on in the :file:`/var/www` directory or publish anything.

To promote your own user-profile on the server to a real webmaster, add it to
the **www-data** group::

  $ sudo adduser $USER www-data

You have to logout and back in for the change to take effect.


Useful Tools
------------

Some useful tools are not installed by default.

* `htop <http://manpages.ubuntu.com/manpages/trusty/en/man1/htop.1.html>`_
* `pwgen <http://manpages.ubuntu.com/manpages/trusty/man1/pwgen.1.html>`_
* `MultiTail <http://manpages.ubuntu.com/manpages/trusty/en/man1/multitail.1.html>`_
* `Molly Guard <http://manpages.ubuntu.com/manpages/trusty/en/man8/molly-guard.8.html>`_
* Git
* Mercurial

To install these run::

    $ sudo apt-get install htop multitail pwgen molly-guard git mercurial


Login Screen
------------

Display some system information on login::

    $ sudo apt install landscape-common

Create and edit the file :file:`/etc/landscape/client.conf`::

    $ sudo nano /etc/landscape/client.conf

.. code-block:: ini

   [sysinfo]
   exclude_sysinfo_plugins = LandscapeLink


Create and edit the file :file:`/etc/update-motd.d/60-system-uptime`::

    $ sudo nano /etc/update-motd.d/60-system-uptime

::

    #!/bin/sh
    #
    # 60-system-uptime - print system uptime information
    #
    printf "  Last reboot:  $(uptime --since)  \n"
    printf "  Uptime:       $(uptime --pretty) \n"


Make it executable and also disable the standard Ubuntu help text::

    $ sudo chmod +x /etc/update-motd.d/60-system-uptime
    $ sudo chmod -x /etc/update-motd.d/10-help-text
