Certificates
============

Certificates are essentially :doc:`keys`, which have been certified by another
party, that those keys indeed belong to a person or device.

Certificates signed by commercial certificate authorities are usually created
directly on their website using built-in functions of web-browsers which require
minimal interaction from the user.

Here we will manually create a CSR to be signed by a private certification
authority.


OpenSSL Configuration
---------------------

Create a personal directory to store configuration, keys, CSR and certificates::

	$ mkdir -m 700  -p ~/.ssl


Create a new empty OpenSSL configuration file 
:download:`~/.ssl/openssl.cnf </desktop/config-files/.ssl/openssl.cnf>`:

.. literalinclude:: /desktop/config-files/.ssl/openssl.cnf
    :language: ini


Certfication Signing Request (CSR)
----------------------------------

Prepare environment::

	$ export OPENSSL_CONF=~/.ssl/openssl.cnf
	$ export emailAddress=john.doe@example.com


Create the request::

	$ req -new -out ~/.ssl/$emailAddress.csr
	Generating a 2048 bit RSA private key
	.......................................+++
	...............................+++
	writing new private key to '/home/wolf/.ssl/john.doe@example.com.key'
	Enter PEM pass phrase:
	Verifying - Enter PEM pass phrase:


Take a peek in the request::

	$ openssl req -text -verify -noout -in ~/.ssl/$emailAddress.csr 


Protect the private key::

	$ chmod 600 ~/.ssl/john.doe@example.com.csr


Send the file :file:`~/.ssl/john.doe@example.com.csr` to CA for signing