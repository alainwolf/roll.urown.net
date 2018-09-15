Creating the Root CA
====================

.. contents::
  :local:


Directories and Files
---------------------

The certificate authority uses a specific directory structure to safe keys,
signed certificates, singing requests and revocation lists. The directory
structure is defind within the OpenSSL configuration file.

::

    root-ca/
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
    $ mkdir -p example.net.ca/root-ca/{certreqs,certs,crl,newcerts,private}
    $ cd example.net.ca/root-ca


The directory used to store private keys should not be accessible to others:

::

    $ chmod 700 private


Some data files are needed to keep track of issued certificates, their
serial numbers and revocations.

::

    $ touch root-ca.index
    $ echo 00 > root-ca.crlnum


Create the serial file, to store next incremental serial number.

Using random instead of incremental serial numbers is a recommended security practice.

::

    $ openssl rand -hex 16 > root-ca.serial


OpenSSL configuration
---------------------

The OpenSSL configuration for the **root certificate authority** is in the file
:file:`root-ca/root-ca.cnf`.

The complete configuration is available for download as
:download:`root-ca.cnf <config-files/root-ca.cnf>`.

.. literalinclude:: config-files/root-ca.cnf
    :language: ini
    :linenos:

Make sure that the OpenSSL configuration file for the **root CA** is active::

    $ export OPENSSL_CONF=./root-ca.cnf


Generate CSR and new Key
------------------------

The following command creates a new key and a certificate signing request for
the root::

    $ openssl req -new -out root-ca.req.pem
    Generating a 4096 bit RSA private key
    .......................................................................++
    .......................................................................++
    .......................................................................++
    .......................................................................++
    writing new private key to 'private/root-ca.key.pem'
    Enter PEM pass phrase: ********
    Verifying - Enter PEM pass phrase: ********
    -----

You will find the key in :file:`private/root-ca.key` and the CSR in :file:`root-
ca.csr`.

Protect the private key::

    $ chmod 400 private/root-ca.key.pem


Generate CSR from existing Key
------------------------------

If you need to update existing CA certificates you can use the already
existing key to create a new CSR.

The following command creates a certificate signing request for
the root using an already existing key::

    $ openssl req -new \
        -key private/root-ca.key.pem \
        -out root-ca.req.pem
    Enter pass phrase for private/root-ca.key.pem: ********



Show the CSR
------------

You can peek in to the CSR::

    $ openssl req -verify -in root-ca.req.pem \
        -noout -text \
        -reqopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


Self-Signing the Root Certificate
---------------------------------

If everything looks ok, self-sign your own request::

    $ openssl rand -hex 16 > root-ca.serial
    $ openssl ca -selfsign \
        -in root-ca.req.pem \
        -out root-ca.cert.pem \
        -extensions root-ca_ext \
        -startdate `date +%y%m%d000000Z -u -d -1day` \
        -enddate `date +%y%m%d000000Z -u -d +10years+1day`


The signature will be valid for the next ten years.

View it with the following command::

    $ openssl x509 -in ./root-ca.cert.pem \
        -noout -text \
        -certopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


You can verify if it will be recognized as valid::

    $ openssl verify -verbose -CAfile root-ca.cert.pem \
        root-ca.cert.pem
    root-ca.cert.pem: OK


Revocation List (CRL)
---------------------

The Root CA publishes Certificate Revocation Lists at regular intervals or
when a certificate has been revoked.

The Root CA is expected to only issue revocations of its own self-signed
certificate or the Intermediate CA certificate.

There have not been any revocations yet, but still clients and servers
verifying any of our certificates will  request an up-to-date CRL from the
web-address published in the certificates.

We therefore need to create initial, albeit empty CRLs of the Root CA::

    $ openssl ca -gencrl -out crl/root-ca.crl


Install As Trusted CA
---------------------

To be recognized by your systems, devices and software, the Root Certificate
needs to be installed as a trusted CA on all Systems.


Install on Ubuntu Linux Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Steps to re-include the root certificate in Ubuntu as trusted
:abbr:`CA (Certificate Authority)`::

    $ sudo mkdir -p /usr/local/share/ca-certificates/example.net
    $ cd /usr/local/share/ca-certificates/example.net/
    $ sudo cp ./root-ca.crt \
        example.net_Root_Certification_Authority.cert.pem
    $ sudo dpkg-reconfigure ca-certificates


Install on Android Systems
^^^^^^^^^^^^^^^^^^^^^^^^^^




References
----------

    * `MDN: A Web PKI x509 certificate primer <https://developer.mozilla.org/en-US/docs/Mozilla/Security/x509_Certificates>`_
    * Mozilla Wiki: `CA:Recommendations for Roots <https://wiki.mozilla.org/CA:Recommendations_for_Roots>`_
