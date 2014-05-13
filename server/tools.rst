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
   The system must be able to send out mails, for this to work. See :doc:`/server/mail`


The **unattended-upgrades** package is used to automatically install updated packages. It is installed if selected during OS installation.

Check for it with::

    $ dpkg-query -W -f='${Status} ${Version}\n' unattended-upgrades


If it is not already, install it as follows::

    $ sudo apt-get install unattended-upgrades


To configure unattended-upgrades, edit 
:file:`/etc/apt/apt.conf.d/50unattended-upgrades` and adjust the following to fit your needs::

    Unattended-Upgrade::Allowed-Origins {
            "Ubuntu trusty-security";
    //      "Ubuntu trusty-updates";
    }; 

    Unattended-Upgrade::MinimalSteps "true";
    Unattended-Upgrade::Mail "root";
    Unattended-Upgrade::Remove-Unused-Dependencies "true";

 
Another useful package is **apticron**. apticron will configure a cron job to email an administrator information about any packages on the system that have updates available, as well as a summary of changes in each package.

To install the apticron package, in a terminal enter::

    $ sudo apt-get install apticron

Once the package is installed edit :file:`/etc/apticron/apticron.conf`, to set the email address and other options::

    EMAIL="root@example.com"


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

* htop
* pwgen
* MultiTail

To install these run::

    $ sudo apt-get install htop multitail pwgen
