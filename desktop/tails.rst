Safe System
===========

.. image:: Tails-logo.*
    :alt: Tails Logo
    :align: right

We use Ubuntu Desktop Linux for everyday personal computing. But for some more
sensitive tasks a separate "Safe System" is needed.

 * Creating a :doc:`luks` to save highly sensitive data (i.e. password and 
   encryption keys);
 * Use the Internet anonymously and circumvent censorship;
 * Leave no trace of the thins you are doing on the computer you are using;

The "Safe System" is not suitable for everyday work, as it lacks features and
comfort, but provides more security.

For this kind of tasks we use `Tails <https://tails.boum.org/>`_, the amnesic
incognito live  system.

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

You can read more on 
`trusting tails <https://tails.boum.org/doc/about/trust/index.en.html>`_ on 
their own website.

The ISO image is cryptographically signed by the Tails developers. The key used
to sign the image, is signed by several Linux Debian developers. Debian
is the Linux system, which Ubuntu is based on. 

By using Ubuntu we already put a lot of trust in the Debian developers.

Install debian developer keys in to our system:

.. raw:: html

        <p>
            <a class="reference external" href="apt:debian-keyring" 
            title="Install Debian Keyring">
            <img alt="software-center" src="../_images/scbutton-free-200px.png" />
            </a>
        </p>

The keys are saved in a GnuPG keyring file 
:file:`/usr/share/keyrings/debian-keyring.gpg`.


Install them on our personal keyring.



::

	$ gpg --verify-files tails-i386-1.3.iso.sig 

Download and import the `signing key 
<https://tails.boum.org/tails-signing.key>`_ to your personal keyring: 

::

	wget -O - https://tails.boum.org/tails-signing.key | gpg --import

Verify the ISO image:

::

	$ cd Downloads
	$ gpg --verify-files tails-i386-1.3.iso.sig 


Burn to DVD
-----------


Install on USB Flash-Drive
--------------------------