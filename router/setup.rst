Initial Configuration
=====================

.. contents::


Web Administration
------------------

After a fresh installation of factory reset, OpenWRT is listenting on IP **192.168.1.1**.

To connect to the  your router point your browser to `192.168.1.1 <http://192.168.1.1/>`_. 

Login as user **root** without a password.

Default Configuration
^^^^^^^^^^^^^^^^^^^^^

======== =======================
URL      **http://192.168.1.1/**
User     **root**
Password *not set*
======== =======================


Administration Password
^^^^^^^^^^^^^^^^^^^^^^^

Before anything else, secure the administration account **root** with s secure password.

In the web administration interface, open the menu **System** and select **Administration**.

Setup a secure password with your :doc:`/desktop/secrets/keepassxc` and enter
it in the two form fields.


Setup SSH Access
----------------

Also on the System Administration page, setup the SSH server of the router.

Choose a 
:doc:`random TCP port </server/ssh-server>`, 
for the SSH server to listen to.

De-activate "Password authentication".

De-activate "Allow root logins with password".

De-activate "Gateway ports".

Paste the public SSH client-keys of your workstation. 

You can display your public keys by opening a terminal on your workstation and entering
the following command::

    workstation$ cat ~/.ssh/*.pub

Copy all of the displayed unreadable garbage into the clipboard and paste it
into the filed at the bottom of the System Administration page in your
browser.

Click the **Save & Apply** button when you are done.


Test SSH Access
^^^^^^^^^^^^^^^

You should be able to connect to the router by SSH now::

    workstation$ ssh -v -p <YOUR_RANDOM_TCP_PORT> root@192.168.1.1

    BusyBox v1.28.3 () built-in shell (ash)

      _______                     ________        __
     |       |.-----.-----.-----.|  |  |  |.----.|  |_
     |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|
     |_______||   __|_____|__|__||________||__|  |____|
              |__| W I R E L E S S   F R E E D O M
     -----------------------------------------------------
     OpenWrt 18.06.0, r7188-b0b5c64c22
     -----------------------------------------------------

    root@router:~# 


System Properties
-----------------

In the web administration interface, open the menu **System** and select **System**.

Set a Host Name
^^^^^^^^^^^^^^^

Enter a host-name and domain in the form fields.


Set the Timezone
^^^^^^^^^^^^^^^^

Select your timezone from the drop-down list. (i.e Zurich/Switzerland)


Time Synchronization
^^^^^^^^^^^^^^^^^^^^

The Network Time Protocol (:term:`NTP`) is used to keep the routers clock
accurate. This is very important for two reasons:

    #. Network devices like routers, usually don't have a battery-backed
       reatlime-clock, like PCs do. When the router has been switched off, it
       will not even remember in what century he is.
    #. Accurate time information is important for a lot of security and 
       encryption related tasks.

To setup the router as NTP client and synchronize its clock from the Internet.

Choose four servers from 
`the public NTP pool <http://support.ntp.org/bin/view/Servers/NTPPoolServers>`_, 
preferably in your own country, where the router should get its time from.

NTP server candidates (for Switzerland):

======== =================
Server 1 0.ch.pool.ntp.org
Server 2 1.ch.pool.ntp.org
Server 3 2.ch.pool.ntp.org
Server 4 3.ch.pool.ntp.org
======== =================


All hosts in a network should have reliable time synchronization. The router,
as the local network provider and manager is usually the best choice for local
hosts to synchronize their time with.

By activating the option **Provide NTP server**, other hosts in the local
network will be able to synchronize their clocks with the accurate time of the
router.

This way NTP time synchronization, will also work in the local network, even
if there is no Internet connection.

Click the **Save & Apply** button when you are done.


Setup your local network (LAN)

Setup WiFi Networks

Setup default Firewall rules

Upgrade packages

Install additional software

    * ca-certificates
    * diffutils
    * haveged
    * htop
    * nano
    * openssh-sftp-server

::

    router$ opkg install ca-certificates diffutils haveged htop nano openssh-sftp-server


Setup server certificates


Command-Line Interface
----------------------

The command-line shell **ash** interpreter in OpenWRT is very basic and lacks
some common configuration options that I am used to.

Configuration for the shell is stored globally in :file:`/etc/profile` and
:file:`/root/.profile` for the **root** user.

We want to show some additional features:

    * Show system uptime and load averages after login.
    * Show how long ago the installed packages where checked for updates.
    * List packages in need of an updates, if any.
    * Define some common command-line aliases.
    * Add some color.
    * Display hostname and path in your terminal window title.



.. literalinclude:: files/root/.profile
   :linenos:




References
----------

 * `OpenWRT Quick-Start Guide <https://openwrt.org/docs/guide-quick-start/begin_here>`_
 * `OpenWRT User Guide: Command-Line Interpreter <https://openwrt.org/docs/guide-user/base-system/user.beginner.cli>`_
