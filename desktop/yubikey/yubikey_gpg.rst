GnuPG with Yubikey NEO
======================

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right


Prerequisites
-------------

 * Yubico installed and setup as described in :doc:`index`.
 * GnuPG installed and configured as in :doc:`../gpg`.


Additional Software
-------------------

 * pcsd - A daemon to access smart cards using the SCard API (PC/SC) in Linux.
 * scdaemon - Smart card support for GNU privacy guard

Install these as follows::

	$ sudo apt install pcscd scdaemon


GnuPG should now be able to access the Yubikey Neo as a smart card::

	> gpg --card-status
	Reader ...........: 1050:0116:X:0
	Application ID ...: D2760001240102000000012345670000
	Version ..........: 2.0
	Manufacturer .....: Yubico
	Serial number ....: 01234567
	Name of cardholder:[not set]
	Language prefs ...:[not set]
	Sex ..............:unspecified
	URL of public key :[not set]
	Login data .......:[not set]
	Signature PIN ....:[not set]
	Key attributes ...: rsa2048 rsa2048 rsa2048
	Max. PIN lengths .: 127 127 127
	PIN retry counter : 3 3 3
	Signature counter : 0
	Signature key ....:[not set]
	Encryption key....:[not set]
	Authentication key:[not set]
	General key info..:[none]


Setup the Yubikey NEO
---------------------

Use GnuPG's `card-edit` command to configure the card::

	$ gpg card-edit


Setting PIN codes
^^^^^^^^^^^^^^^^^

The Smartcard has two PIN codes:

	#. Regular PIN to unlock the private key stored on the card, so it can be
	   used for decryption or authentication.
	#. Administration PIN to reset the regular PIN or reset the private key
	   storage.
	#. A reset PIN to reset the counter of remaining PIN entry attempts


.. warning::

	Entering a wrong Administration PIN three times in a row **destroys the
	card!** There is no way to unblock the card when a wrong Administration PIN
	has been entered three times.


Yubikey NEO is shipped with ...

	... a default regular PIN code of `123456`.

	... a default Administration PIN code of `12345678`

::

	gpg/card> admin
	Admin commands are allowed

	gpg/card> passwd
	gpg: OpenPGP card no. D2760001240102000000012345670000 detected

	1 - change PIN
	2 - unblock PIN
	3 - change Admin PIN
	4 - set the Reset Code
	Q - quit

	Your selection? 1

Select `1` to change the regular PIN.

You will be asked for the current regular PIN, which is `123456` on a new Yubikey.

You will be asked twice for the new regular PIN.

::

	1 - change PIN
	2 - unblock PIN
	3 - change Admin PIN
	4 - set the Reset Code
	Q - quit

	Your selection? 3

Select `3` to change the Administration PIN.

You will be asked for the current Administration PIN, which is `12345678` on a new Yubikey.

You will be asked twice for the new regular PIN.

::

	1 - change PIN
	2 - unblock PIN
	3 - change Admin PIN
	4 - set the Reset Code
	Q - quit

	Your selection? 4

You will be asked twice for the new reset PIN.

::

	1 - change PIN
	2 - unblock PIN
	3 - change Admin PIN
	4 - set the Reset Code
	Q - quit

	Your selection? q

	gpg/card> quit


The Yubikey is now ready for use with GnuPG.


Store Your Key on the Yubikey
-----------------------------

.. note::
	This will **move** your private key to the card. It will no longer be
	available on your desktop computer without the Yubikey.


Start by opening your key with GnuPG for editing::

	> gpg --edit-key 0x0123456789ABCDEF

	Secret key is available.

	sec  rsa2048/0x0123456789ABCDEF
	     created: 2014-01-15  expires: 2019-01-14  usage: SCA
	     trust: ultimate      validity: ultimate
	ssb  rsa2048/0x0123456789AAAAAA
	     created: 2014-01-15  expires: 2019-01-14  usage: E
	ssb  rsa2048/0x6E0D7F94789BBBBB
	     created: 2016-07-02  expires: 2019-01-14  usage: A
	[  ultimate] (1). John Doe <john@example.net>
	[  ultimate] (2)  John Doe <john@example.org>
	[  ultimate] (3)  [jpeg image of size 23712]


At the `gpg>` prompt enter `keytocard` to start the operation::

	gpg> keytocard


On other Systems
----------------

Thanks to the Yubikey, our private keys are no longer stored on and tied to a
particular computer. The Yubikey can be plugged in at any computer system and
our private keys are ready for use ... Right?

Unfortunately thats not the case. For the following two reasons:

#. As shown on the beginning of this guide, additional software, usually not 
   pre-installed, is used to access the Yubikey or GnuPG Smartcard.

#. Second, the local GnuPG keyring doesn't know anything about the private key
   on the Yubikey and does not know anything of its corresponding public key.

So to use your PGP keys stored on a Yubikey or GnuPG Smartcard the following
steps need to be taken:

#. Install required software to enable GnuPG to access the Yubikey::

	> sudo apt install pcscd scdaemon

#. Download the corresponding public keys of your private keys and add them to
   the local keyring::

 	> gpg --card-edit
 	gpg/card> fetch
 	gpg/card> exit

#. Edit key::

	$> gpg --edit-key 0x0123456789ABCDEF
	Secret key is available.


#. Set trust::

	gpg> trust

	Please decide how far you trust this user to correctly verify other users 
	keys (by looking at passports, checking fingerprints from different sources, 
	etc.)

	  1 = I don't know or won't say
	  2 = I do NOT trust
	  3 = I trust marginally
	  4 = I trust fully
	  5 = I trust ultimately
	  m = back to the main menu

	Your decision? 5
	Do you really want to set this key to ultimate trust? (y/N) y

The local GnuPG installation has now the means to access your private key stored
in the Yubikey or GnuPG Smartcard and it knows about your public keys.


References
----------

 * `GnuPG Howto's: The GnuPG Smartcard How-To <https://gnupg.org/howtos/card-howto/en/smartcard-howto.html>`_
 
 * `Yubico Support: Using Your YubiKey with OpenPGP <https://support.yubico.com/support/solutions/articles/15000006420-using-your-yubikey-with-openpgp>`_
