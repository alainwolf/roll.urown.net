Creating the CA
===============


Directories and Files
---------------------

The certificate authority uses a specific directory structure to safe keys,
signed certificates, singing requests and revocation lists. The directory
structure is defind within the OpenSSL configuration file.

::

    $ cd /media/$USER/safe_storage
    $ mkdir example_ca
    $ cd example_ca
    $ mkdir ./certs ./crl ./newcerts ./private


The directory used to store private keys should not be accessible to others:

::

    $ chmod 700 ./private


Two small data files are needed to keep track of issued certificates, their
serial numbers and revocations.

::

    $ touch index
    $ echo '000000' > serial


CA OpenSSL configuration
------------------------

The OpenSSL configuration for the **root certificate authority** is in the file
:download:`root-ca.cnf <config-files/root-ca.cnf>`.

The configuration for the **intermediate certificate authority** is in the file
:download:`intermediate-ca.cnf <config-files/intermediate-ca.cnf>`.

The details of these configuration files are discussed :doc:`here <ca_conf>`.


Creating the Root CA
--------------------

Make sure we are in the right directory and that the OpenSSL configuration file
for the **root CA** is active::

    $ cd /media/$USER/CA_safe_storage/example_ca
    $ export OPENSSL_CONF=./root-ca.cnf


Generate Root CSR and Key
^^^^^^^^^^^^^^^^^^^^^^^^^

The following command creates a new key, and a self-signed certificate for the
root::

    $ openssl req -new -out ./ExampleNet_RootCA.csr
    Generating a 4096 bit RSA private key
    .......................................................................++
    .......................................................................++
    .......................................................................++
    .......................................................................++
    writing new private key to 'private/ExampleNet_RootCA.key'
    Enter PEM pass phrase: ********
    Verifying - Enter PEM pass phrase: ********
    -----

You should find the key in :file:`private/ExampleNet_RootCA.key` and the CSR in
:file:`root.csr`.

Protect the private key::

    $ chmod 400 private/ExampleNet_RootCA.key

You can peek in to the CSR::

    $ openssl req -verify -in ./ExampleNet_RootCA.csr \
        -noout -text \
        -reqopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


Self-Signing Root Certificate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If everything looks ok, self-sign your own request::

    $ openssl ca -selfsign \
        -in ./ExampleNet_RootCA.csr \
        -out ./ExampleNet_RootCA.crt \
        -extensions root_ext \
        -startdate `date +%y%m%d000000Z -u -d -1day` \
        -enddate `date +%y%m%d000000Z -u -d +10years+1day`


View it with the following command::

    $ openssl x509 -in ./ExampleNet_RootCA.crt\
        -noout -text \
        -certopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


Creating the Intermediate Signing CA
------------------------------------

Switch the OpenSSL configuration to the Intermediate CA::

    $ export OPENSSL_CONF=./intermediate-ca.cnf


Generate Intermediate CSR and Key
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The RSA private key of the intermediate signing certificate needs to be 3072
bits strong. As this is considered safe for the next 8 years (up to 2023). It
also should be made write-protected and private and have a strong password.

Make a new Certificate Signing Request (CSR) for the intermediate signing
authority::

    $ openssl req -new -out ./ExampleNet_IntermediateCA.csr
    Generating a 3072 bit RSA private key
    .......................................................................++
    .......................................................................++
    .......................................................................++
    writing new private key to 'private/ExampleNet_IntermediateCA.key'
    Enter PEM pass phrase: ********
    Verifying - Enter PEM pass phrase: ********
    -----

You should find the key in :file:`private/ExampleNet_IntermediateCA.key` and the
CSR in :file:`ExampleNet_IntermediateCA.csr`.

Protect the private key::

    $ chmod 400 private/ExampleNet_IntermediateCA.key

You can peek in to the CSR::

    $ openssl req  -verify -in ./ExampleNet_IntermediateCA.csr \ 
        -noout -text\
        -reqopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


Sign the Intermediate with the Root CA
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Switch the OpenSSL configuration back to the root CA::

    $ export OPENSSL_CONF=./root-ca.cnf


Sign the intermediate CSR with the root key for the next 5 years using the
intermediate extensions::

    $ openssl ca \
        -in ExampleNet_IntermediateCA.csr \
        -out ExampleNet_IntermediateCA.crt \
        -extensions inter_ext \
        -startdate `date +%y%m%d000000Z -u -d -1day` \
        -enddate `date +%y%m%d000000Z -u -d +10years+1day`


References
----------

    * `MDN: A Web PKI x509 certificate primer <https://developer.mozilla.org/en-US/docs/Mozilla/Security/x509_Certificates>`_
    * Mozilla Wiki: `CA:Recommendations for Roots <https://wiki.mozilla.org/CA:Recommendations_for_Roots>`_