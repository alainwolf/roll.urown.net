Linux Login with Yubikey
========================

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right


Software Installation
---------------------

This module implements PAM over U2F, providing an easy way to integrate the
YubiKey (or other U2F compliant authenticators) into your existing
infrastructure.

We don't need YubiKey NEO Manager, since November 2015 YubiKeys are shipped with
all modes of operations alreeady already enabled by default.


::

    $ sudo apt install libpam-u2f


Yubikey Registration
---------------------

A mappings file needs to be created and filled with the users registered U2F
keys.

There is a command-line tool to help with registration process. Replace
**USERNAME** with the name of the user, which belongs to the Yubikey::

    $ sudo pamu2fcfg -u${USERNAME} >> /etc/u2f_mappings


Nothing will happen in your console, but your Yubikey should start to blink as
it wants to be touched now. Touch it, the command exits, and the file
:file:`/etc/u2f_mappings` will contain the necessary challenges for the Yubikey
belonging to that user.

If you a have a second key::

    $ sudo pamu2fcfg -n >> /etc/u2f_mappings


Configuration
-------------

Create a a new PAM service file :file:`/etc/pam.d/u2f`::

  $ echo "auth sufficient pam_u2f.so cue authfile=/etc/u2f_mappings debug" > sudo tee /etc/pam.d/u2f


This tells the PAM module that it can look up information about each users U2F
keys in the :file:`/etc/u2f_mappings` file.


Testing with sudo
^^^^^^^^^^^^^^^^^

Then we can include the file in other PAM service file. For example for the
:file:`sudo` command edit the file :file:`/etc/pamd.d/sudo` as follows::

	#%PAM-1.0

	session    required   pam_env.so readenv=1 user_readenv=0
	session    required   pam_env.so readenv=1 envfile=/etc/default/locale user_readenv=0
	@include u2f
	@include common-auth
	@include common-account
	@include common-session-noninteractive


Make sure line "@include u2f" sits before the "common-auth" include line,


Going Live
^^^^^^^^^^

Open the PAM service file :file:`/etc/pam.d/u2f` again and remove the **debug** string::

	$ echo "auth sufficient pam_u2f.so authfile=/etc/u2f_mappings" | sudo tee /etc/pam.d/u2f


Open the PAM service file :file:`/etc/pam.d/gdm-password` and the following line before the “@include common-auth” line::

	@include u2f
	@include common-auth


Do the same with :file:`/etc/pam.d/login` and :file:`/etc/pam.d/polkit-1`.


Lock the Desktop with Yubikey
-----------------------------

This is how we setup our desktop to immediately lock Gnome shell desktop
sessions, when the Yubikey is removed.

In Linux most hardware devices are managed by the **udev** service. Using
**udev-rules** actions can be triggered when certain hardware events (device is
added or removed) occur. Each USB device has a Vendor ID and a Product ID that
can be used to identify the device. For all YubiKeys, Yubico’s USB vendor ID
(VID) is **0x1050**. Yubico publishes a list of
`YubiKey USB ID Values <https://support.yubico.com/hc/en-us/articles/360016614920-YubiKey-USB-ID-Values>`_
where you can see all the Product IDs.

To get a list of all currently attached USB devices on your system::

    $ lsusb

To show only USB devices manufactured by Yubico::

    $ lsusb -d 1050:

In this example **0116** is the product ID for a Yubike NEO. You might have a
different product ID.

.. note::

    Note that The USB product ID will change depending on which of the
    features on your Yubikey have been enabled with **Yubikey Manager**.

Let's create an udev rule for this specific device with the file
:file:`/etc/udev/rules.d/85-yubikey-screen-lock.rules`::

    #
    # udev rules file for Yubikey NEO USB devices
    #
    # See https://support.yubico.com/hc/en-us/articles/360016614920-YubiKey-USB-ID-Values
    #

    # Lock all (gnome-)sessions when Yubikey NEO is unplugged
    SUBSYSTEM=="usb", ACTION=="remove", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0110|0111|0112|0113|0114|0115|0116", RUN+="/usr/bin/loginctl lock-sessions"



References
----------

 * `Yubico Support: Ubuntu Linux Login Guide - U2F <https://support.yubico.com/support/solutions/articles/15000011356-ubuntu-linux-login-guide-u2f>`_
 * `Yubico developers site: pam-u2f <https://developers.yubico.com/pam-u2f/>`_
 * :file:`/usr/share/doc/libpam-u2f/README.gz`
 * :file:`/usr/share/doc/libpam-u2f/changelog.Debian.gz`

