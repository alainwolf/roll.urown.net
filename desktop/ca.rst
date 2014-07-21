Certificate Authority
=====================

We use certificates and keys signed by "trusted" third-party certificate
authorities to allow other people use our public services in a secure way.

For securing our own communication, between our servers or while accessing
private services and networks, the use of a third-party (trusted or not) is out
of the question and also not practicable. Access to our private services need to
be secured with certificates issued by our own private certificate authority.

Examples of private services, which cannot rely on a third-party certificate
authority migh bee:

 * Virtual Private Networks, which allows a client from the Internet full access 
   to the local network (LAN).
 * Backend services exchanging data, like database replication between MySQL 
   servers.

This document describes how to build our own certificat authority and how to
issue certifcates for devices and services acting as clients and servers.

A certificate authority is a combination of the following things:

 * A private key
 * A self-signed certificate to that private key.
 * A database (or list) of all issued certificates.
 * A certificate revocation list (CRL).
 * A set of policies for issuing certificates to users, clients and servers.
 * Means of publishing the CRL and confirm validity of signed certificates (OCSP).

 Of all these things only the private key needs to be highly protected. In 
 contrary to our server keys, it remains password protected and is stored 
 offline in secure location.

Most of the other things are achieved using apropriate OpenSSL configuration
options and a web-site capable of distributing the CRL and answering OCSP
requests.

Secure Storage
--------------

We will use an encrypted USB Storage key. 
All operations are done in a secured environment without internet access.
The :doc:`tails` system is needed for both these prerequisites.




OpenSSL CA configuration
------------------------



