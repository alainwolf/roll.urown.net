OpenPGP Applications and Tools
==============================

Gnome OpenPGP Applet
--------------------

Every now and then, you will come across a block of text similar to the
following:

.. code-block:: text

    -----BEGIN PGP MESSAGE-----
    hQEMA/CNm90TCGETAQgAub1J8bUA4GOFfFYzipEMIlFORuyqYQaDOwVHJGImwrnw
    jCzFQYs3yBgVocHoNRPu1T+UZANyfOs+iX1iOCdFy8vhKBvm2lkLGDH1gdtxB/AY
    F8DknG9cenolBbdvtffm3u2b20uOvRZOjRjQybzUNiSBFQ4/xsKfH6Da9IEDUe0D
    Qgo8dkG9ysolSNWdr/ryHL4jQJ2rVaQaqBWaeL4rStljhUftS5uVy9PsehmyNLwb
    R5Daz+fCcofXwQ0aCIlJsM4iOtDLugHMOQcunPngESxp2xWcl7oxnOlvtFtQG8CO
    gHmjjsTUp+eq/49cz2o1GiGuuOdA83xy9umgtMlmAskqlQUEGZwuq01uHm+YnPEZ
    CvzT/Vyl7EjK6QusrNtw+jLDlinPsMnVS5jx
    =aCps
    -----END PGP MESSAGE-----

Somehow people think, pasting encrypted messages or public keys on websites is a
good idea. Its not, as any potential reader will have to copy the whole text to
a file, save that file, decrypt it, and only then will be able to decide if the
content was really worth all the trouble.

The OpenPGP Applet takes at least some pain out of this, by allowing you to work
directly with your clipboard, without the need of creating a file.

The applet was introduced and available exclusively on the Tails Live Linux
distribution, but has since made available to other Gnome Desktop environments.

With the OpenPGP Applet you can:

    * Encrypt any text in your clipboard with a passphrase;
    * Encrypt and sign any text in your clipboard to an OpenPGP public key;
    * Decrypt and verify any text in your clipboard.

The
`OpenPGP Applet page <https://tails.boum.org/doc/encryption_and_privacy/gpgapplet/index.en.html>`_
in the Tails Wiki has all the details.

Install **openpgp-applet** from the Ubuntu Software Center ...

.. image:: /scbutton-free-200px.*
    :alt: Install openpgp-applet
    :target: apt:openpgp-applet
    :align: left


... or with the command-line::

    $ sudo apt install openpgp-applet


Seahorse Nautilus Extension
---------------------------

**Seahorse**, sometimes also called "Secretes and Keys" is the name of the Gnome
Desktop application that provides a graphical user interface for the user to
manage his secrets inside the Gnome-Keyring.

The "Nautilus extension for Seahorse integration" allows encryption and
decryption of OpenPGP files using GnuPG right from the Nautilus file-manager.

.. image:: seahorse-nautilus.*
    :alt: The Seahorse Nautilus extensions in action.


Install **seahorse-nautilus** from the Ubuntu Software Center ...

.. image:: /scbutton-free-200px.*
    :alt: Install seahorse-nautilus
    :target: apt:seahorse-nautilus
    :align: left


... or with the command-line::

    $ sudo apt install seahorse-nautilus


Signing GIT Operations
----------------------

In :doc:`/desktop/toolbox/git-scm` you find a description to set up git for
signing and verifying various operations.
