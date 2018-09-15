Creating the Intermediate CA
============================

.. contents::
  :local:


Directories and Files
---------------------

The certificate authority uses a specific directory structure to safe keys,
signed certificates, singing requests and revocation lists. The directory
structure is defined within the OpenSSL configuration file:

::

    intermed-ca/
        |
        |----certreqs/
        |
        |----certs/
        |
        |----crl/
        |
        |----newcerts/
        |
        |----private/


::

    $ cd /media/$USER/safe_storage
    $ mkdir -p example.net.ca/intermed-ca/{certreqs,certs,crl,newcerts,private}
    $ cd example.net.ca/intermed-ca


The directory used to store private keys should not be accessible to others:

::

    $ chmod 700 private


Some data files are needed to keep track of issued certificates, their
serial numbers and revocations.

::

    $ touch intermed-ca.index
    $ echo 00 > intermed-ca.crlnum


Create the serial file, to store next incremental serial number.

Using random instead of incremental serial numbers is a recommended security
practice::

    $ openssl rand -hex 16 > intermed-ca.serial


OpenSSL configuration
---------------------

The configuration for the **intermediate certificate authority** is in the file
:file:`intermed-ca/intermed-ca.cnf`.

The complete configuration is available for download as
:download:`intermed-ca.cnf <config-files/intermed-ca.cnf>`.

.. literalinclude:: config-files/intermed-ca.cnf
    :language: ini
    :linenos:

Switch the OpenSSL configuration to the Intermediate CA::

    $ export OPENSSL_CONF=./intermed-ca.cnf


Generate CSR and new Key
------------------------

The RSA private key of the intermediate signing certificate needs to be 3072
bits strong. As this is considered safe for the next 8 years (up to 2023). It
also should be made write-protected and private and have a strong password.

Make a new Certificate Signing Request (CSR) for the intermediate signing
authority::

    $ openssl req -new -out intermed-ca.req.pem
    Generating a 3072 bit RSA private key
    .......................................................................++
    .......................................................................++
    .......................................................................++
    writing new private key to 'private/intermed-ca.key.pem'
    Enter PEM pass phrase: ********
    Verifying - Enter PEM pass phrase: ********
    -----

You should find the key in :file:`private/intermed-ca.key.pem` and the
CSR in :file:`intermed-ca.req.pem`.

Protect the private key::

    $ chmod 400 private/intermed-ca.key.pem


Generate CSR from existing Key
------------------------------

If you need to update existing CA certificates you can use the already
existing key to create a new CSR.

The following command creates a certificate signing request for
the intermediate using an already existing key::

    $ openssl req -new \
        -key private/intermed-ca.key.pem \
        -out intermed-ca.req.pem
    Enter pass phrase for private/intermed-ca.key.pem: ********

You can peek in to the CSR::

    $ openssl req  -verify -in intermed-ca.req.pem \
        -noout -text \
        -reqopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline

If everything looks alright, copy the CSR to the Root CA for later signing::

    $ cp intermed-ca.req.pem  \
        /media/$USER/safe_storage/example.net.ca/root-ca/certreqs/


Sign the Intermediate with the Root CA
--------------------------------------

Change your working directory to the where the Root CA stores its files::

    $ cd /media/$USER/safe_storage/example.net.ca/root-ca

Switch the OpenSSL configuration back to the root CA::

    $ export OPENSSL_CONF=./root-ca.cnf

Sign the intermediate CSR with the root key for the next 5 years using the
intermediate extensions::


    $ openssl rand -hex 16 > root-ca.serial
    $ openssl ca \
        -in certreqs/intermed-ca.req.pem \
        -out certs/intermed-ca.cert.pem \
        -extensions intermed-ca_ext \
        -startdate `date +%y%m%d000000Z -u -d -1day` \
        -enddate `date +%y%m%d000000Z -u -d +5years+1day`


You can peek in to the signed certificate::

    $ openssl x509 -in certs/intermed-ca.cert.pem \
        -noout -text \
        -certopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


You can verify if it will be recognized as valid::

    $ openssl verify -verbose -CAfile root-ca.cert.pem \
        certs/intermed-ca.cert.pem
    certs/intermed-ca.cert.pem: OK


If the certificate looks as expected, copy it to the Intermediate CA directory::

    $ cp certs/intermed-ca.cert.pem \
        /media/$USER/safe_storage/example.net.ca/intermed-ca/


Revocation List (CRL)
---------------------

The Intermediate CA publishes Certificate Revocation Lists at regular intervals
or when a certificate has been revoked.

The Intermediate CA is expected to publish revocations of any server or client
certificate that has been issued by it.

There have not been any revocations yet, but still clients and servers verifying
any of our certificates will request an up-to-date CRL from the web-address
published in the certificates.

We therefore need to create initial, albeit empty CRLs of the Intermediate CA.

Change your working directory to the where the Intermediate CA stores its
files::

    $ cd /media/$USER/safe_storage/example.net.ca/intermed-ca

Switch the OpenSSL configuration back to the Intermediate CA::

    $ export OPENSSL_CONF=./intermed-ca.cnf

Create the Intermediate CA certificate revocation list (CRL)::

    $ openssl ca -gencrl -out crl/intermed-ca.crl


Install and use the Intermediate CA
-----------------------------------

Copy the Intermediate CA files to your working environment::

    cp /media/$USER/safe_storage/example.net.ca/intermed-ca ~/


Unmount and lock the safe storage and lock the storage medium away.
