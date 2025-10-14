Yubikey
=======

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right

YubiKey is an authentication device capable of generating One Time Passwords
(OTP). The YubiKey connects to a USB port and identifies itself as a standard
USB HID keyboard, which allows it to be used in most computer environments using
the system’s native drivers.

Its available for around € 45.00 from the
`Yubico online store <https://www.yubico.com/store/>`_


Software Packages
-----------------

Yubico provides a software package repository on Launchpad::

    $ sudo add-apt-repository ppa:yubico/stable
    $ sudo apt update


Yubico Authenticator Desktop
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A graphical desktop tool for generating Open
AuTHentication (OATH) event-based HOTP and time-based TOTP one-time password
codes, that are often used as a 2nd-factor for two-factor authentication::

    $ cd ~/Downloads
    $ wget https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz
    $ tar xvf yubico-authenticator-latest-linux.tar.gz
    $ mv yubico-authenticator-* ~/.local/bin/Yubico-Authenticator
    $ ~/.local/bin/Yubico-Authenticator/desktop_integration.sh --install


Yubikey personalization Tool
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is a graphical tool to customize the token with your own cryptographic key
and options::

    $ sudo apt install yubikey-personalization-gui


Yubikey Manager
^^^^^^^^^^^^^^^

Python library and command line tool for configuring a YubiKey YubiKey Manager
(:file:`ykman`) is a command line tool for configuring a YubiKey over all
transports. It is capable of reading out device information as well as
configuring several aspects of a YubiKey, including enabling or disabling
connection transports an programming various types of credentials::

    $ sudo apt install yubikey-manager


Where to go from here ...

.. toctree::
   :maxdepth: 1

   yubikey_luks
   yubikey_pam
   yubikey_gpg
   yubikey_ssh
   yubikey_piv
   yubikey_backup
