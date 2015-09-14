Public vs. Private CA 
=====================

When to use Public CAs?
-----------------------

When we provide services for the general public, we use certificates
signed by a "trusted" third-party. People who don't know us (we don't know them
either) can rely on the signature of the public CA (which we both know), to
initiate a secure and "trusted" communication-channel.

This assures them, that they indeed talk with our server and that nobody can
listen to or read along of any communication.

The information and services we provide on this servers are still open to the
general public and not secret at all.


When to use a Private CAs?
--------------------------

The situation changes completely when private services are provided, which are
not for the general public.

As soon as we deal with a closed user group public CAs are out of the question.
Simply because they are public. Public CAs will issue a certificates for
anybody, while our private service must insure only a select group of people (or
devices) have access.

Therefore access to our private services need to be secured with certificates
issued by our own private Certificate Authority.

Examples of private services, which cannot rely on a third-party certificate
authority might bee:

 * Virtual private networks
 * Data and or file replication between servers
 * Remote backup
 * Access to mail or other personal accounts
 * Remote administration
 * Other closed user groups services (file-sharing, cloud services)


What's in a CA?
===============

A certificate authority is a combination of the following things:

 * A private key;
 * A self-signed certificate to that private key;
 * A list of all certificates who have been issued;
 * A list of all certificates who have been revoked (CRL);
 * A policy for issuing certificates;
 * Services for publishing the CRL validate certificates (OCSP).

Only the private key needs to be highly protected.

All other things on the list above can be handled like any other service data we
provide.


CA Protection
=============

Here are some of the methods to maintain a high security level on your CA.

Root and Intermediate CA
------------------------

As mentioned, the CAs private key needs a high level of security. More security
usually means less comfort. The private key must be stored in a secure place,
but is used to sign certificates on the other hand.

To make things safer and easier, the private key, which must be highly
protected, is never used directly to sign the certificates of end-users and
servers.

Instead an intermediate CA is created, one level below of the root CA. The root
CAs private key is only used once to sign the intermediate CAs certificate and
then stored away in its safe place.

After that, certificates for persons and devices can be signed by the
intermediate CA with its own private key. 

In case the intermediates private key gets stolen or lost or otherwise
compromised, you can just discard it and create a new intermediate CA, without
loosing everything, as it would be the case if this happened with the root CA
key.

Its still advisable to protect the intermediates private key with a password and
not leave it on a unprotected server all the time.


Secure Work Environment
-----------------------

A secure working environment is important for the creation of the certificate
authority private key and while the certificate for the intermediate CA is
issued.

A secure work environment means:

 * Not your daily working environment;
 * A fresh clean install a of hardened and trusted Linux distribution;
 * No connection to the Internet or other networks;
 * Disabled networking adapters (Ethernet, WiFi, Bluetooth, Mobile-Network, etc);

The :doc:`Tails Linux </desktop/tails>` system, booted from a DVD or other read-
only device without any network connections will provide you with all of this.


Secure Storage
--------------

The :doc:`Tails </desktop/tails>` Linux distribution has an easy to use step-by-
step method to create an encrypted storage partition on a USB stick, directly
usable from within the TAILS environment.

Alternatively a separate USB stick can be encrypted using :doc:`/desktop/luks`.

Another possibility is to use a :term:`Smartcard`.



Root Signing Key
^^^^^^^^^^^^^^^^

The private key of the certificate authority root certificate must be protected
and stored safely. Save it on a encrypted USB Storage key or Smartcard and store
that USB key in a safe location. Depending on your safety requirements, a bank-
safe or other trusted third-party is recommended. In the best of all cases, you
won't need to access the root key again for the next five years. Access to this
key is only needed if you loose control over the intermediate signing key or if
you need to make substantial changes to your Certificate Authority.


Intermediate Signing Key
^^^^^^^^^^^^^^^^^^^^^^^^

The private key of the intermediate signing authority should also be stored on a
encrypted storage device or Smartcard, but might remain easy accessible for
everyday use. In case this key is stolen or lost, it can be revoked using the
root signing key.
