.. image:: letsencrypt-logo.*
    :alt: Let's Encrypt Logo
    :align: right

Lets Encrypt
============

`Dehydrated <https://dehydrated.de>`_ is a Letsencrypt/ACME client implemented
as a shell-script.

`pdns_api.sh <https://github.com/silkeh/pdns_api.sh>`_, a simple DNS hook for
letting Dehydrated talk to the PowerDNS API.

.. contents::
  :local:


Installation
------------

Dehydrated
^^^^^^^^^^

::

	$ cd /usr/local/lib
	$ sudo git clone --no-checkout https://github.com/lukas2511/dehydrated.git
	$ sudo git tag
	v0.1.0
	v0.2.0
	v0.3.0
	v0.3.1
	$ sudo git checkout v0.3.1


PowerDNS API Hook Script
^^^^^^^^^^^^^^^^^^^^^^^^

::

	$ cd /usr/local/lib
	$ sudo git clone --no-checkout https://github.com/silkeh/pdns_api.sh.git
	$ cd pdns_api.sh
	v0.1.0
	v0.2.0
	$ sudo git checkout v0.2.0




Configuration
-------------

Dehydrated
^^^^^^^^^^

:file:`/etc/dehydrated/config`

.. literalinclude:: config-files/etc/dehydrated/config
    :language: bash


OpenSSL
^^^^^^^

::

	$ openssl version
	OpenSSL 1.0.2g  1 Mar 2016


::

	$ sudo wget --output-document=/etc/dehydrated/openssl.cnf
		https://raw.githubusercontent.com/openssl/openssl/OpenSSL_1_0_2g/apps/openssl.cnf


Domains
^^^^^^^

:file:`/etc/dehydrated/domains.txt`


.. code-block:: text

	example.net www.example.net cloud.example.net
	example.org www.example.org xmpp.example.org
	mail.exammple.net mail.example.org
	autoconfig.example.net autoconfig.example.org
	xmpp.example.net


Increase Serials on API-Requests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

	$ mysql -u root -p pdns

.. code-block:: mysql

	> INSERT INTO domainmetadata (domain_id, kind, content)
		VALUES (
		(SELECT domains.id FROM domains WHERE domains.name = 'example.net'),
		'SOA-EDIT-API',
		'INCEPTION-INCREMENT'
	);

	> INSERT INTO domainmetadata (domain_id, kind, content)
		VALUES (
		(SELECT domains.id FROM domains WHERE domains.name = 'example.org'),
		'SOA-EDIT-API',
		'INCEPTION-INCREMENT'
	);



Re-use Existing Keys
^^^^^^^^^^^^^^^^^^^^

::

	$ sudo mkdir -p /etc/dehydrated/certs/{example.org,example.net}
	$ sudo cp /etc/ssl/private/example.org.key.pem /etc/dehydrated/certs/example.org/privkey.pem
	$ sudo cp /etc/ssl/private/example.net.key.pem /etc/dehydrated/certs/example.net/privkey.pem



OCSP Stapling and Mail Servers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Postfix SMTP server and Dovecot IMAP server both don't do OCSP stapling, or
maybe just my mail client Thunderbird doesn't or other MX don't. I don't know exactly, but the fact remains: SMTP and IMAP Connections to the mail server fail with an OpenSSL error message "alert bad certificate: SSL alert number 42".

Since we configured Dehydrated to request certificates with the x.509 extension
"OCSP must staple", they will not work with connecting clients if the server
does not staple. We therefore make an exception in the Dehydrated configuration:

:file:`/etc/dehydrated/certs/mail.example.net/config`:

.. code-block:: ini

	;;
	;; Mail servers Postfix and Dovecot don't seem to support OCSP stapling (yet?).
	;;
	;; dovecot:
	;; 	imap-login: Error: SSL: Stacked error:
	;; 		error:14094412:SSL
	;; 			routines:ssl3_read_bytes:sslv3
	;; 				alert bad certificate: SSL alert number 42
	;;
	;; postfix/submission/smtpd:
	;; 	warning: TLS library problem: error:14094412:SSL
	;; 		routines:ssl3_read_bytes:sslv3
	;; 			alert bad certificate:s3_pkt.c:1472:SSL alert number 42:
	;;
	;; Option to add CSR-flag indicating OCSP stapling to be mandatory
	;; Default: no
	OCSP_MUST_STAPLE="no"


OCSP Response Stapling
----------------------

TBD ...

::

	cd /etc/dehydrated/certs
	openssl ocsp \
		-issuer example.net/chain.pem \
		-CAfile example.net/chain.pem \
		-VAfile example.net/chain.pem \
		-cert example.net/cert.pem \
		-url http://ocsp.int-x3.letsencrypt.org/ \
		-header "HOST" "ocsp.int-x3.letsencrypt.org" \
		-no_nonce


Keys and Certificates File Permissions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Private keys must be carefully protected, that's why in most cases the private
key files are owned by the root user and have strict file permissions, to not
allow access to anyone else. Most servers start with root privileges to open IP
ports lower then 1024 and read their certificate and private keys. They lower
their privileges after that and run under their own dedicated user and group.

Some servers (e.g. Prosody) have a different approach. Their user profile is
part of the ssl-cert group. The ssl-cert group is given read access to private keys and certificate files. That way such a server never needs to be started or run with root privileges to begin with.

Dehydrated does not currently allow read-access to the ssl-cert group.

::

	chgrp -R ssl-cert/etc/dehydrated/certs/*


Restarting Servers
^^^^^^^^^^^^^^^^^^

TBD ...

 * Nginx
 * Postfix
 * Dovecot
 * Prosody


Test-Run
--------

Make sure the line CA contains the Letsencrypt staging server:


.. code-block:: ini

	CA="https://acme-staging.api.letsencrypt.org/directory"


Run the script against the staging server::

	$ sudo /usr/local/lib/dehydrated/dehydrated --cron



Publish/Update TSLA Records
---------------------------

`Avoid “3 0 1” and “3 0 2” TLSA records with LetsEncrypt certificates <https://community.letsencrypt.org/t/please-avoid-3-0-1-and-3-0-2-dane-tlsa-records-with-le-certificates/7022>`_


TLSA Record Types
^^^^^^^^^^^^^^^^^

 1. The Certificate Usage Field

+-------+----------+--------------------------------+
| Value | Acronym  | Short Description              |
+-------+----------+--------------------------------+
|   0   | PKIX-TA  | CA constraint                  |
+-------+----------+--------------------------------+
|   1   | PKIX-EE  | Service certificate constraint |
+-------+----------+--------------------------------+
|   2   | DANE-TA  | Trust anchor assertion         |
+-------+----------+--------------------------------+
|   3   | DANE-EE  | Domain-issued certificate      |
+-------+----------+--------------------------------+

	0. A commonly trusted top-level CA certificate or public key.
	1. A commonly trusted server certificate or public key.
	2. Certificate or public key of the signing CA. No common trust
	   required.
	3. Domain certificate or public key. No common trust required.

 2. The Selector Field

+-------+---------+--------------------------+
| Value | Acronym | Short Description        |
+-------+---------+--------------------------+
|   0   | Cert    | Full certificate         |
+-------+---------+--------------------------+
|   1   | SPKI    | SubjectPublicKeyInfo     |
+-------+---------+--------------------------+

 	0. The full certificate.
 	1. The public key of the certificate.


 3. The Matching Type Field

+-------+-----------+--------------------------+
| Value | Acronym   | Short Description        |
+-------+-----------+--------------------------+
|   0   | Full      | No hash used             |
+-------+-----------+--------------------------+
|   1   | SHA2-256  | 256 bit hash by SHA2     |
+-------+-----------+--------------------------+
|   2   | SHA2-512  | 512 bit hash by SHA2     |
+-------+-----------+--------------------------+

 	0. The full certificate or public key.
 	1. SHA-256 hash of the certificate or public key
 	2. SHA-512 hash of the certificate or public key


Not Recommended:

	* 000 - Un-hashed full trusted CA certificate, too big might change
	* 001 - SHA2-256 hash of trusted CA certificate, might change
	* 002 - SHA2-512 hash of trusted CA certificate, might change
	* 010 - Un-hashed public key of trusted CA certificate, too big.
	* 100 - Un-hashed full trusted server certificate, too big, changes on
	  renewal.
	* 101 - SHA2-256 hashed trusted server certificate, changes on renewal.
	* 102 - SHA2-512 hashed trusted server certificate, changes on renewal.
	* 110 - Un-hashed server public key, too big.
	* 111 - SHA2-256 hashed server public key.
	* 112 - SHA2-512 hashed server public key.
	* 200 - Un-hashed full CA certificate, too big, might change.
	* 201 - SHA2-256 hashed CA certificate, might change.
	* 202 - SHA2-512 hashed CA certificate, might change.
	* 210 - Un-hashed CA public key, too big.
	* 300 - Un-hashed server certificate, too big, changes on renewal.
	* 301 - SHA2-256 hashed server certificate, changes on renewal.
	* 302 - SHA2-512 hashed server certificate, changes on renewal.
	* 310 - Un-hashed server public key, too big.


Possible, but still big:

 	* 012 - SHA-512 hashed public key of trusted CA
 	* 212 - SHA-512 hashed CA public key.
 	* 312 - SHA-512 hashed server public key.


Recommended:

 	* 011 - SHA-256 hashed public key of trusted CA
 	* 211 - SHA-256 hashed CA public key.
 	* 311 - SHA-256 hashed server public key.


Create TLSA Records
^^^^^^^^^^^^^^^^^^^

Download::

	$ sudo wget -O /usr/local/bin/chaingen https://go6lab.si/DANE/chaingen
	$ sudo chmod +x /usr/local/bin/chaingen

Run::

	$ sudo -s
	$ cd /etc/dehydrated/certs
	$ chaingen /etc/dehydrated/certs/example.net/fullchain.pem example.org:443



Upgrade
-------

Dehydrated
^^^^^^^^^^

::

	$ cd /usr/local/lib
	$ sudo git fetch --tags
	$ git checkout v0.3.1
