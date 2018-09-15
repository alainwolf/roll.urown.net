
OCSP Responder
==============

Online Certificate Status Protocol Responder.


Directories and Files
---------------------

::

    ocsp/
        |
        |----certs/
        |
        |----private/


OpenSSL configuration
---------------------

OpenSSL configuration file used to create the private key and certificate
signing request (CSR) of the OCSP responder.


Generate CSR and Key
--------------------


Sign the CSR with the Intermediate CA
-------------------------------------


Install Certificates Index
--------------------------


OCSP Service
------------

::

	$ openssl ocsp -index ./index.txt \
		-CA certs/intermed-ca.cert.pem \
		-rsinger certs/intermed-ocsp.pem \
		-rother certs/root-ca.pem \
		-resp_key_id \
		-rkey private/intermed-ocps.key \
		-port 6960 \
		-nmin minutes, -ndays days
        -text -out log.txt



HTTP Proxy
----------




References
----------

 * `Online Certificate Status Protocol <https://jamielinux.com/docs/openssl-certificate-authority/online-certificate-status-protocol.html>`_
 * `OpenSSL 1.1 OCSP man page <https://www.openssl.org/docs/man1.1.0/apps/ocsp.html>`_
 * :rfc:`6960`, :rfc:`2560`
