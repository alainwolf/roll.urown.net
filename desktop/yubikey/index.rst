Yubikey NEO
===========

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right

.. toctree::
   :maxdepth: 2

   yubikey_luks
   yubikey_pam
   yubikey_gpg
   yubikey_ssh
   yubikey_piv


YubiKey is an authentication device capable of generating One Time Passwords
(OTPs). The YubiKey connects to a USB port and identifies itself as a standard
USB HID keyboard, which allows it to be used in most computer environments using
the system’s native drivers.

Its available for around € 45.00 from
`Yubico's website <https://www.yubico.com/store/>`_

We will use the device with the following services:

 * :doc:`yubikey_luks`
 * :doc:`yubikey_pam`
 * :doc:`yubikey_gpg`
 * :doc:`yubikey_ssh`

Other possible uses:

 * Password Management (KeePassX using static password)
 * S/Mime mail signing and encryption (as SmartCard)
 * SSL/TLS browser client login on web servers (as SmartCard)
 * SSL/TLS Certificate Management (as SmartCard with XCA, OpenSSL)
 * ownCloud user login (TOTP TwoFactor App for OwnCloud 9.1)
 * WordPress user login (with U2F)
 * Prosody XMPP server login (via PAM Challenge-Response)
 * Bitcoin Wallet (?)
 * Various WebServices (TOTP with Yubico Authenticator or U2F)

     * Google Services
     * Cloud Servers (Digital Ocean, AmazonWS)
     * CDN (Cloudflare)
     * Code Repository (GitHub)
     * NAS Devices (Synology DiskStation)
     * Domain Registration (GandiNet)
     * Mail Providers (mailbox.org)


Prerequisites
-------------

 * Havegd
 * Gnupg 2.0 or later


Installation
------------

Yubico provides a software package repository on Launchpad::

    $ sudo add-apt-repository ppa:yubico/stable
    $ sudo apt-get update


The following Linux Software packages are provided:

 * YubiKey NEO Manager (to set which operation-modes are active on connection);
 * YubiKey Personalization Tool (used to program the two configuration slots in your YubiKey);
 * YubiKey PIV Manager (to configure private keys and certificates on the PIV smart-card in your YubiKey)
 * Yubico Authenticator for Linux (manages your TOTP and HOTP one time passwords);
 * Yubico PAM module (to use your Yubikey for Login on your Linux Desktop or Server)


USB Device Rules
^^^^^^^^^^^^^^^^

**udev** rules control how Linux handles certain devices. i.e. when they are 
plugged in or out, programs to start or access restrictions to be set.

Yubico provides a set of such rules, not only for its own Yubikeys, but also a
range of other USB security devices from various vendors.

To install these device rules on your system::

    $ sudo wget -O /etc/udev/rules.d/70-u2f.rules \
        https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules


YubiKey Software
^^^^^^^^^^^^^^^^

We don't need YubiKey NEO Manager, since November 2015 YubiKeys are shipped with
all modes of operations already already enabled by default.

::

    $ sudo apt-get install yubikey-personalization-gui
    $ sudo apt install yubikey-manager-qt


YubiKey Applications
--------------------

 * :doc:`yubikey_pam`
 * :doc:`yubikey_gpg`


References
----------

 * `NEO-Manager QuickStart Guide <https://www.yubico.com/wp-content/uploads/2014/11/NEO-Manager-Quick-Start-Guide.pdf>`_
 * `Yubico Support: Using Your U2F YubiKey with Linux <https://support.yubico.com/support/solutions/articles/15000006449-using-your-u2f-yubikey-with-linux>`_
