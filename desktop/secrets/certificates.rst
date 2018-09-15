Certificates
============

Certificates are essentially :doc:`keys <keys>`, which have been certified by
another party, that those keys indeed belong to a person or device.

Certificates signed by commercial certificate authorities are usually created
directly on their website using built-in functions of web-browsers which require
minimal interaction from the user.

Here we will manually create a CSR to be signed by a :doc:`certification
authority </ca/index>`.

.. contents::


Preparations
------------

Create a personal directory to store configuration, keys, CSR and certificates::

    $ mkdir -p ~/.ssl/{certs,private}
    $ chmod 700 ~/.ssl/private


Set some environment variables::

    $ export CN=$HOSTNAME.example.net
    $ export emailAddress=john.doe@example.net


Personal User Certificate Request
---------------------------------

Personal certificates may be used to login on websites and to sign and encrypt
email. They include information about a person.


OpenSSL Configuration
^^^^^^^^^^^^^^^^^^^^^

Create a new OpenSSL configuration file
:download:`~/.ssl/openssl-user.cnf </desktop/config-files/.ssl/openssl-user.cnf>`:

.. literalinclude:: /desktop/config-files/.ssl/openssl-user.cnf
    :language: ini
    :linenos:
    :emphasize-lines: 38-43,46,47

Change the highlighted lines to your needs.

Make the configuration the default to use by OpenSSL::

    $ export OPENSSL_CONF=~/.ssl/openssl-user.cnf


Certificate Signing Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create the personal certificate request and key::

    $ openssl req -new -out ~/.ssl/$emailAddress.req.pem
    Generating a 2048 bit RSA private key
    .......................................+++
    ...............................+++
    writing new private key to '/home/john/.ssl/john.doe@example.net.key.pem'
    Enter PEM pass phrase:
    Verifying - Enter PEM pass phrase:


Protect the private key::

    $ chmod 400 ~/.ssl/private/$emailAddress.key.pem


Take a peek in the request::

    $ openssl req -verify -in ~/.ssl/$emailAddress.req.pem \
        -noout -text -nameopt multiline \
        -reqopt no_version,no_pubkey,no_sigdump


Send the file :file:`~/.ssl/john.doe@example.net.req.pem` to the CA for
:doc:`signing </ca/ca_cert>`.


Client Device Certificate
-------------------------

Client host certificates may be used to identify a particular device. I.e. to
establish a connection to a VPN service. They might also include information
about its owner.

In todays connected world, mobile devices are lost and stolen every day. By
using certificates for devices instead of its owners, a single lost or stolen
device can be locked out, without affecting other devices of the same person.


OpenSSL Configuration
^^^^^^^^^^^^^^^^^^^^^

Create a new OpenSSL configuration file
:download:`~/.ssl/openssl-client.cnf </desktop/config-files/.ssl/openssl-client.cnf>`:

.. literalinclude:: /desktop/config-files/.ssl/openssl-client.cnf
    :language: ini
    :linenos:
    :emphasize-lines: 39-44,47-49

Change the highlighted lines to your needs.

Make the configuration the default to use by OpenSSL::

    $ export OPENSSL_CONF=~/.ssl/openssl-client.cnf


Certificate Signing Request
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create the client device request::

    $ openssl req -new -out ~/.ssl/$CN.req.pem
    Generating a 2048 bit RSA private key
    .......................................+++
    ...............................+++
    writing new private key to '/home/john/.ssl/host.example.net.key.pem'
    Enter PEM pass phrase:
    Verifying - Enter PEM pass phrase:


Protect the private key::

    $ chmod 400 ~/.ssl/private/$CN.key.pem


Take a peek in the request::

    $ openssl req  -verify -in ~/.ssl/$CN.req.pem \
        -noout -text \
        -reqopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


Send the file :file:`~/.ssl/host.example.net.req.pem` to the CA for
:doc:`signing </ca/ca_cert>`.


Using the Certificate
^^^^^^^^^^^^^^^^^^^^^

After the CA has verified and signed the certificate singing request you get a
the certificate in a file like :file:`host.example.net.cert.pem`.

To view the certificate::

    $ openssl x509 -in $CN.cert.pem \
        -noout -text \
        -certopt no_version,no_pubkey,no_sigdump \
        -nameopt multiline


To verify the certificate::

    $ openssl verify -issuer_checks -policy_print -verbose \
        -untrusted intermed-ca.cert.pem \
        -CAfile root-ca.cert.pem \
        certs/$CN.cert.pem

