.. index:: Cipher Suite; Selection of

.. _cipher-suite:

Cipher Suite Selection
======================

.. warning::

   Following are recommendations valid in August 2018, using OpenSSL 1.1.0g under
   Ubuntu 18.04 LTS 'Bionic Beaver'.


..  note::

    :term:`TL;DR`: This is our official :term:`cipher suite` list string, which
    we will use in most of our services:

    .. parsed-literal::

        **kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA+AESGCM:kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM:kEECDH+aECDSA+AES:kEECDH+aRSA+AES:kEDH+aRSA+AES:-AESCCM:-AES256:+SHA1**


.. contents::
  :local:

The quest for the perfect :term:`Cipher Suite` list is an endless one, simply
because there is no perfect solution.

For our private servers for mostly personal use and presumably limited public
interest or commercial goals, we have the luxury to enforce a more secure, but
less compatible set of cipher suites.

.. note::

    Windows XP clients using Internet Explorer will not be able to connect to
    any of your servers.

Following is the composition of our Cipher suite list using the the OpenSSL
:manpage:`ciphers (1SSL)` command. The command displays as a list of all cipher
suites available with the current selection parameters.

::

    $ openssl ciphers -v '<Selection Parameters>' | column -t

.. index:: Perfect Forward Secrecy


Key Exchange
------------

Perfect Forward Secrecy
^^^^^^^^^^^^^^^^^^^^^^^

All our encrypted communications is to be established using :term:`Perfect
Forward Secrecy`.

In todays OpenSSL the available ciphers suites who are able to provide forward
secrecy are the ones who use :term:`Diffie-Hellman key exchange`.

Also we place the EC variant first, as it uses smaller keys and is faster.

Priorities:

 #. **ECDH key-exchange over DH key-exchange**



To list those, you can use ...

.. parsed-literal::

    \ **kEECDH**
    \ **kEDH**


.. parsed-literal::

    \ **kEECDH**:\ **kEDH**

as selection parameter with the OpenSSL :command:`ciphers` command and you will
get a list of 65 available cipher suites on my [#f1]_ system::

    $ openssl -v 'kEECDH:kEDH'  | column -t


.. index:: Key Authentication


Key Authentication
------------------

The private keys to our certificates can either be :term:`RSA` or :term:`ECDSA`
keys or both.

One can select all ciphers suites who use ECDSA or RSA key authentication with
the "\ **aECDSA**" and "\ **aRSA**" selection parameter. Since ECDSA is faster,
has smaller keys, but with equal or better security it is put first thus given a
higher selection priority.

This will list 43 available cipher suites.


ECDSA Key Authentication
^^^^^^^^^^^^^^^^^^^^^^^^

ECDSA keys can only by exchanged over ECDH. So we can skip the non-working
combination of DH key exchange with ECDSA keys.

.. parsed-literal::

    kEECDH\ **+aECDSA**
    kEDH


.. parsed-literal::

    kEECDH\ **+aECDSA**:kEDH


The list shrinks to 52 ciphers suites.


RSA Key Authentication
^^^^^^^^^^^^^^^^^^^^^^

RSA keys on the other hand can be exchanged over ECDH and DH.

Priorities:

 #. ECDH key-exchange over DH key-exchange
 #. **ECDSA keys over RSA keys**


.. parsed-literal::

    kEECDH+aECDSA
    kEECDH\ **+aRSA**
    kEDH\ **+aRSA**


.. parsed-literal::

    kEECDH+aECDSA:kEECDH\ **+aRSA**:kEDH\ **+aRSA**


The list shrinks to 40 ciphers suites.


Encryption
----------

Looking at the current selection, there are many encryption schemes who we
clearly don't want to use. Like :term:`RC4`, :term:`3DES`, :term:`DES` or some
with weak export-grade or no encryption at all.

We therefore confine this further by using Chacha20 and AES exclusively.

ChaCha20 Encryption with Poly1305
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. parsed-literal::

    kEECDH+aECDSA\ **+CHACHA20**
    kEECDH+aRSA\ **+CHACHA20**
    kEDH+aRSA\ **+CHACHA20**


.. parsed-literal::

    kEECDH+aECDSA\ **+CHACHA20**:kEECDH+aRSA\ **+CHACHA20**:kEDH+aRSA\ **+CHACHA20**

Only 3 ciphers suites match, but more will be added.


AES Encryption
^^^^^^^^^^^^^^

AES is the most widely trusted encryption standard, supported on all platforms
and client software, and as big plus, modern CPUs include hardware acceleration
for AES with the :term:`Advanced Encryption Standard Instruction Set`.

.. note::

  To check if your CPU has built-in hardware acceleration for AES encryption use
  the following command: :code:`grep aes /proc/cpuinfo`

Priorities:

 #. **ChaCha20 over AES encryption**
 #. ECDH key exchange over DH key exchange.
 #. ECDSA keys over RSA keys.


.. parsed-literal::

    kEECDH+aECDSA+CHACHA20
    kEECDH+aRSA+CHACHA20
    kEDH+aRSA+CHACHA20
    kEECDH+aECDSA\ **+AES**
    kEECDH+aRSA\ **+AES**
    kEDH+aRSA\ **+AES**


.. parsed-literal::

    kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA\ **+AES**:kEECDH+aRSA\ **+AES**:kEDH+aRSA\ **+AES**


OpenSSL lists 29 cipher suites when used with the "AES" parameter. Combined with
our earlier selections.


AES and Message Authentication (MAC)
------------------------------------

AES-GCM vs. AES-CBC vs. AES-CCM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Priorities:

 #. ChaCha20 over AES encryption
 #. **GCM over CBC message authentication**
 #. ECDH key exchange over DH key exchange.
 #. ECDSA keys over RSA keys.
 #. **No CCM message authentication**

.. parsed-literal::

    kEECDH+aECDSA+CHACHA20
    kEECDH+aRSA+CHACHA20
    kEDH+aRSA+CHACHA20
    kEECDH+aECDSA+\ **AESGCM**
    kEECDH+aRSA+\ **AESGCM**
    kEDH+aRSA+\ **AESGCM**
    kEECDH+aECDSA+AES
    kEECDH+aRSA+AES
    kEDH+aRSA+AES
    \ **-AESCCM**


.. parsed-literal::

    kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA+\ **AESGCM**:kEECDH+aRSA+\ **AESGCM**:kEDH+aRSA+\ **AESGCM**:kEECDH+aECDSA+AES:kEECDH+aRSA+AES:kEDH+aRSA+AES:\ **-AESCCM**


The list now contains the 21 cipher suites, with CCM MACs removed.


AES Encryption Strength
-----------------------

As already mentioned the selected AES cipher suites use either 128-bit or
256-bit encryption. Thats OK for most, some would even be tempted to use only
256-bit (only to discover that not even the newest Firefox browser would work
anymore).

If we trust 128-bit encryption, and recent findings predict 128-bit encryption
to be strong enough for another 30 years or so, then why use 256-bit then?

Symmetric Encryption Key Size

============ ==========
RSA Key Size Safe until
============ ==========
20 bits      Year 1928
40 bits      Year 1958
56 bits      Year 1982
112 bits     Year 2020
128 bits     Year 2030
256 bits     Year 2030+
============ ==========

Bigger is not always better. The time for a handshake between server and client
increases dramatically with 256-bit encryption compared to 128-bit. And lets
not forget the mobile devices, who may not have a CPU with :term:`AES-NI`
besides being weaker and smaller on the hardware-side.

So to only select the 29 different 128-bit variants out of the 58 suites with
AES encryption, one can add "\ **-AES256** " add the end to remove all the 256-bit AES variants:


Priorities:

 #. ChaCha20 over AES encryption
 #. GCM over CBC message authentication
 #. ECDH key exchange over DH key exchange.
 #. ECDSA keys over RSA keys.
 #. No CCM message authentication
 #. **No 256-bit AES encryption**

.. parsed-literal::

    kEECDH+aECDSA+CHACHA20
    kEECDH+aRSA+CHACHA20
    kEDH+aRSA+CHACHA20
    kEECDH+aECDSA+AESGCM
    kEECDH+aRSA+AESGCM
    kEDH+aRSA+AESGCM
    kEECDH+aECDSA+AES
    kEECDH+aRSA+AES
    kEDH+aRSA+AES
    -AESCCM
    \ **-AES256**

.. parsed-literal::

    kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA+AESGCM:kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM:kEECDH+aECDSA+AES:kEECDH+aRSA+AES:kEDH+aRSA+AES:-AESCCM:\ **-AES256**


Number of matching cipher suites: 12.
And they are all suitable.
With this list we already get top
scores on test-sites like `SSLlabs <https://www.ssllabs.com/>`_.


AES Priorities
--------------

However there is still some small room for improvement. Some cipher suites in
our selection use :term:`SHA-1` for message authentication (:term:`HMAC`).

While SHA-1 is not considered broken or harmful for this specific use, its use
is no longer recommended. However if we exclude it, we loose compatibility with
a lot of client platforms and software. This would include:

 * Android devices less then version 4.4 (before December 2013)
 * Bing search engine
 * Firefox browsers less then version 25 (before December 2013)
 * Google search engine
 * Internet Explorer less then version 11
 * Java less then version 8
 * OpenSSL 0.9.8 (only version 1.0.1)
 * OS X less then version 10.9.
 * Safari Browsers up to version 6
 * Windows less then version 8 and Windows Mobile less then version 10
 * Yahoo search engine

So unless you are sure that any of the above list will not be connecting to any
of your servers, we need to support it.

But we can push it to the end of our list, so that it will only be used, when
all other options failed already.

Priorities:

 #. ChaCha20 over AES encryption
 #. GCM over CBC message authentication
 #. ECDH key exchange over DH key exchange
 #. ECDSA keys over RSA keys.
 #. No CCM message authentication
 #. No 256-bit AES encryption
 #. **SHA1 message authentication only as a last resort**


.. parsed-literal::

    kEECDH+aECDSA+CHACHA20
    kEECDH+aRSA+CHACHA20
    kEDH+aRSA+CHACHA20
    kEECDH+aECDSA+AESGCM
    kEECDH+aRSA+AESGCM
    kEDH+aRSA+AESGCM
    kEECDH+aECDSA+AES
    kEECDH+aRSA+AES
    kEDH+aRSA+AES
    -AESCCM
    -AES256
    \ **+SHA1**

.. parsed-literal::

    kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA+AESGCM:kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM:kEECDH+aECDSA+AES:kEECDH+aRSA+AES:kEDH+aRSA+AES:-AESCCM:-AES256:\ **+SHA1**


This give the same list of 12 cipher suites, but the ones using SHA-1 moved to
the bottom.


.. code-block:: bash

    $ openssl ciphers -v 'kEECDH+aECDSA+CHACHA20:kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aECDSA+AESGCM:kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM:kEECDH+aECDSA+AES:kEECDH+aRSA+AES:kEDH+aRSA+AES:-AESCCM:-AES256:+SHA1' | column -t


.. code-block:: text

    ECDHE-ECDSA-CHACHA20-POLY1305  TLSv1.2  Kx=ECDH  Au=ECDSA  Enc=CHACHA20/POLY1305(256)  Mac=AEAD
    ECDHE-RSA-CHACHA20-POLY1305    TLSv1.2  Kx=ECDH  Au=RSA    Enc=CHACHA20/POLY1305(256)  Mac=AEAD
    DHE-RSA-CHACHA20-POLY1305      TLSv1.2  Kx=DH    Au=RSA    Enc=CHACHA20/POLY1305(256)  Mac=AEAD
    ECDHE-ECDSA-AES128-GCM-SHA256  TLSv1.2  Kx=ECDH  Au=ECDSA  Enc=AESGCM(128)             Mac=AEAD
    ECDHE-RSA-AES128-GCM-SHA256    TLSv1.2  Kx=ECDH  Au=RSA    Enc=AESGCM(128)             Mac=AEAD
    DHE-RSA-AES128-GCM-SHA256      TLSv1.2  Kx=DH    Au=RSA    Enc=AESGCM(128)             Mac=AEAD
    ECDHE-ECDSA-AES128-SHA256      TLSv1.2  Kx=ECDH  Au=ECDSA  Enc=AES(128)                Mac=SHA256
    ECDHE-RSA-AES128-SHA256        TLSv1.2  Kx=ECDH  Au=RSA    Enc=AES(128)                Mac=SHA256
    DHE-RSA-AES128-SHA256          TLSv1.2  Kx=DH    Au=RSA    Enc=AES(128)                Mac=SHA256
    ECDHE-ECDSA-AES128-SHA         TLSv1    Kx=ECDH  Au=ECDSA  Enc=AES(128)                Mac=SHA1
    ECDHE-RSA-AES128-SHA           TLSv1    Kx=ECDH  Au=RSA    Enc=AES(128)                Mac=SHA1
    DHE-RSA-AES128-SHA             SSLv3    Kx=DH    Au=RSA    Enc=AES(128)                Mac=SHA1


I admit, this is a very long string (189 characters to select 12 cipher suites
out of 125). If you are sure that you will only use either one of RSA or ECDSA
type keys, we can narrow it down a bit.


RSA Keys Only
-------------

Priorities:

 #. **RSA keys only**
 #. ChaCha20 over AES encryption
 #. GCM over CBC message authentication
 #. ECDH key exchange over DH key exchange
 #. No CCM message authentication
 #. No 256-bit AES encryption
 #. SHA1 message authentication as a last resort


.. parsed-literal::

    kEECDH+aRSA+CHACHA20
    kEDH+aRSA+CHACHA20
    kEECDH+aRSA+AESGCM
    kEDH+aRSA+AESGCM
    kEECDH+aRSA+AES
    kEDH+aRSA+AES
    -AESCCM
    -AES256
    \ **+SHA1**

.. parsed-literal::

    kEECDH+aRSA+CHACHA20:kEDH+aRSA+CHACHA20:kEECDH+aRSA+AESGCM:kEDH+aRSA+AESGCM:kEECDH+aRSA+AES:kEDH+aRSA+AES:-AESCCM:-AES256:+SHA1


This 127 character string should list 8 cipher suites.


ECDSA Keys Only
---------------

Priorities:

 #. **ECDSA keys only**
 #. ChaCha20 over AES encryption
 #. GCM over CBC message authentication
 #. ECDH key exchange over DH key exchange
 #. No CCM message authentication
 #. No 256-bit AES encryption
 #. SHA1 message authentication only as a last resort


.. parsed-literal::

    kEECDH+aECDSA+CHACHA20
    kEECDH+aECDSA+AESGCM
    kEECDH+aECDSA+AES
    -AESCCM
    -AES256
    \ **+SHA1**

.. parsed-literal::

    kEECDH+aECDSA+CHACHA20:kEECDH+aECDSA+AESGCM:kEECDH+aECDSA+AES:-AESCCM:-AES256:+SHA1


This 83 character string should list 4 cipher suites.


.. rubric:: Footnotes

.. [#f1] The number of suites supporting particular features varies between
         versions of OpenSSL.
