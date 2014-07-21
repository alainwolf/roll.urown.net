Safe System
===========

.. image:: Tails-logo.*
    :alt: Tails Logo
    :align: right


We use `Tails <https://tails.boum.org/>`_, the amnesic incognito live system.

It is a complete Linux desktop system, bootable from a DVD or USB-Stick that
aims to preserve your privacy and anonymity. It helps you to use the Internet
anonymously and circumvent censorship almost anywhere you go and on any computer
but leaving no trace unless you ask it to explicitly.


Download the ISO Image
----------------------

Download the ISO image and the signature file from the `download page 
<https://tails.boum.org/download/index.en.html>`_ of the project website.


Verify the ISO Image
--------------------

The ISO image is cryptographically signed by the Tails developers. The key used
by them to sign the image, is signed by several Linux Debian developers. Debian
is the Linux system, which Ubuntu is based on. By using Ubuntu we already put a
lot of trust in the Debian developers.

First we install debian developer keys in to our system:

::

	$ sudo apt-get install debian-keyring

Install them on our personal keyring.



::

	$ gpg --verify-files tails-i386-1.0.1.iso.sig 

Download and import the `signing key 
<https://tails.boum.org/tails-signing.key>`_ to your personal keyring: 

::

	wget -O - https://tails.boum.org/tails-signing.key | gpg --import

Verify the ISO image:

::

	$ cd Downloads
	$ gpg --verify-files tails-i386-1.0.1.iso.sig 


Burn to DVD
-----------


Install on USB Flash-Drive
--------------------------