TLS - Transport Layer Security
==============================

Nowadays there should be no more websites running on plain HTTP without any
encryption.

The following sections assume you have prepared two keys and a certificate as
described in :doc:`/server/server-tls`.


Common TLS Settings
-------------------

We create a default configuration file, to be included in every website:
Amongst others this will ensure:

 * Enforce our preferred :ref:`cipher-suite` on all our websites;
 * Use Strict Transport Security;
 * Use Diffie-Hellman key exchange with the same security as our keys;
 * Longer TLS sessions, resulting in less handshakes and key exchanges

:download:`/etc/nginx/tls.conf <config-files/tls.conf>`:

.. literalinclude:: config-files/tls.conf
    :language: nginx
    :linenos:


OCSP Response Stapling
----------------------

OCSP stapling makes connections to our servers faster and provide additional
privacy to connecting clients.

OCSP stapling is only possible if a certificate is signed by a CA that provides
an OCSP service. We might have servers which don't fall into this category,
therefore we put the OCSP related settings in a separate file and not in the
common TLS settings.

:download:`/etc/nginx/ocsp-stapling.conf <config-files/ocsp-stapling.conf>`:

.. literalinclude:: config-files/ocsp-stapling.conf
    :language: nginx
    :linenos:

