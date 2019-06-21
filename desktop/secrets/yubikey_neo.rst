Yubikey NEO
===========

.. image:: YubiKey-Neo.*
    :alt: YubiKey NEO
    :align: right


YubiKey is an authentication device capable of generating One Time Passwords
(OTPs). The YubiKey connects to a USB port and identifies itself as a standard
USB HID keyboard, which allows it to be used in most computer environments using
the system’s native drivers.

Its available for around € 50.00 from
`Yubico's website <https://www.yubico.com/products/yubikey-hardware/yubikey-neo/>`_

It provides the following services or apps:

 * Two configuration slots activated either by a short or long button-press,
   each can be programmed to be used in the following modes of operation:

     * Yubico OTP
     * OATH-HOTP
     * Static Password
     * Challenge-Response, using

         * Yubico OTP (on-line with Yubico auth servers)
         * HMAC-SHA1 (off-line, standalone)

 * U2F
 * OpenPGP
 * SmartCard (or PIV, Personal Identity Information) with four slots to use,
   each holding a RSA or ECC private key, a certificate and are secured by a PIN:

     * Authentication of card and card-holder before on-line services
     * Digital Signature of documents, files or executables
     * Email and file encryption
     * Authentication before door locks or other physical devices (without PIN)

 * AES Mode?


We will use the device with the following services:

 * Full disk encryption on Ubuntu Linux Desktop (:doc:`yubikey_luks`)
 * Ubuntu Linux Desktop login (via U2F PAM module) (:doc:`yubikey_pam`)
 * SSH server authentication other servers (OpenPGP SSH-Agent) :doc:`yubikey-ssh`
 * OpenPGP for signing and encryption of files and messages (as OpenPGP card 
   with Enigmail) :doc:`yubikey-gpg`

Other possible uses:

 * Password Management (KeePassX using static password)
 * SSH server authentication on our servers (via U2F PAM module)
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


YubiKey Software
^^^^^^^^^^^^^^^^

We don't need YubiKey NEO Manager, since November 2015 YubiKeys are shipped with
all modes of operations already already enabled by default.

::

    $ sudo apt-get install yubikey-personalization-gui


YubiKey Applications
--------------------

 * :doc:`yubikey_pam`
 * :doc:`yubikey_gpg`


References
----------

 * `NEO-Manager QuickStart Guide <https://www.yubico.com/wp-content/uploads/2014/11/NEO-Manager-Quick-Start-Guide.pdf>`_

