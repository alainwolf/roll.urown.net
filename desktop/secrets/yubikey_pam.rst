Linux Login with Yubikey NEO
============================

.. image:: YubiKey-Neo.*
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

    $ sudo -i
    $ apt install libpam-u2f


Configuration
-------------

Create a a new PAM service file :file:`/etc/pam.d/u2f`::

  $ echo "auth sufficient pam_u2f.so authfile=/etc/u2f_mappings debug" > /etc/pam.d/u2f


This tells the PAM module that it can look up information about each users U2F
keys in the :file:`/etc/u2f_mappings` file.

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



Registration
------------

The mappings file needs to be created and filled with the users registered U2F
keys. There is a command-line tool to help with registration process::

  $ pamu2fcfg -uUSERNAME >> /etc/u2f_mappings

Nothing will happen in your console, but your Yubikey should start to blink as
it wants to be touched now.






References
----------

 * `Yubico developers site: pam-u2f <https://developers.yubico.com/pam-u2f/>`_
 * :file:`/usr/share/doc/libpam-yubico/README.Debian`
 * :file:`/usr/share/doc/libpam-yubico/README.gz`

