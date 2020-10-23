MicroTik WinBox
===============

`Winbox <https://help.mikrotik.com/docs/display/ROS/Winbox>`_ is a small 
utility that allows administration of MikroTik RouterOS using a fast and simple 
GUI. 

It is a native Win32 binary, but can be run on Linux and MacOS (OSX) using Wine. 

All Winbox interface functions are as close as possible mirroring the console 
functions, that is why there are no Winbox sections in the manual. 

Some of advanced and system critical configurations are not possible from 
winbox, like MAC address change on an interface Winbox.


Linux Installation
------------------

There are a few scripts available on GitHub which help to setup WinBox nicely 
in your Linux Desktop environment. We use 
`WinBox Installer <https://github.com/mriza/winbox-installer>`_ from Mohammad 
Riza Nurtam here.

::

    $ cd /tmp
    $ git clone https://github.com/mriza/winbox-installer.git
    $ cd winbox-installer
    $ sudo bash ./winbox-setup install
    $ sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor


Updating
--------

WinBox will update itself whenever needed.
