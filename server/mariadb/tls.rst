Secure Connections
==================

.. contents::
  :local:

Encrypted client-server connections use the TLS protocol. For replicated data to
be encrypted, both the master and slave servers require secure connections to be
enabled.

.. warning::

    While the above procedure enables a sever to use TLS encrypted connections
    with clients. Be aware that this **DOES NOT ENFORCE** the use of encryption
    in any way!

    To make sure connections with specific clients (users @ hosts) are indeed
    encrypted, the database user profile must be edited with TLS specific
    `GRANT <https://mariadb.com/kb/en/mariadb/grant/#per-account-ssl-options>`_
    options.

See also:
`Secure Connections Overview <https://mariadb.com/kb/en/library/secure-connections-overview/>`_
in the MariaDB Knowledge Base.


Compatibility
-------------

.. note::

    Support for TLS encrypted connections varies greatly across different
    versions of MariaDB and MySQL servers. This guide assumes **MariaDB version
    10.2.x** dynamically linked with the TLS library from **OpenSSL** which
    supports at least **TLSv1.2**.


To check your database server for availability of TLS encrypted connections:

.. code-block:: sql

    SHOW VARIABLES LIKE 'have_ssl';


+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| have_ssl      | YES   |
+---------------+-------+


.. code-block:: sql

    SHOW VARIABLES LIKE 'have_openssl';


+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| have_openssl  | YES   |
+---------------+-------+


Create a Certificate Authority
------------------------------

The certificates used between the database servers and clients, should not be
issued by a public or commercial certificate authority, since this is not about
securing public services.

The purpose here is to protect private data flowing between our own private
servers and clients. Therefore all entities must authenticate themselves on both
side of the connections with valid certificates issued by our own private
certificate authority.

.. note::

    Although this guide has a chapter to create a general purpose
    :doc:`/ca/index`, and another one on how to create
    :doc:`/server/server-tls` on a server, unfortunately these are not
    compatible with how MariaDB servers currently verify certificates.


Use a secure storage device (aka encrypted USB stick) for the CA::

    $ cd /media/$USER/safe_storage


Directories and Files
^^^^^^^^^^^^^^^^^^^^^

Make a directory named :file:`database-ca` on your secure storage device::

    $ mkdir -p database-ca/{certreqs,certs,crl,newcerts,private}
    $ cd /database-ca


The directory used to store private keys should not be accessible to others::

    $ chmod 700 private


Some data files are needed to keep track of issued certificates, their serial
numbers and revocations::

    $ touch database-ca.index
    $ echo 00 > database-ca.crlnum
    $ echo 00 > database-ca.serial


OpenSSL Configuration
^^^^^^^^^^^^^^^^^^^^^

Create a OpenSSL configuration file for the new CA
:download:`database_ca.cnf </server/config-files/database-ca.cnf>`
with the following contents:

.. literalinclude:: /server/config-files/database-ca.cnf
    :language: bash


Set the OpenSSL configuration file for the database CA::

    $ export OPENSSL_CONF=./database-ca.cnf


Generate CSR and new Key
^^^^^^^^^^^^^^^^^^^^^^^^

The following command creates a new key and a certificate signing request for
the root::

    $ openssl req -new -out database-ca.req.pem


.. code-block:: text

    Generating a 4096 bit RSA private key
    .......................................................................++
    .......................................................................++
    .......................................................................++
    .......................................................................++
    writing new private key to 'private/database-ca.key.pem'
    Enter PEM pass phrase: ********
    Verifying - Enter PEM pass phrase: ********
    -----


Self-Sign the Certificate
^^^^^^^^^^^^^^^^^^^^^^^^^

::

    $ openssl ca -selfsign \
        -in database-ca.req.pem \
        -out database-ca.cert.pem \
        -extensions ca_ext \
        -startdate `date +%y%m%d000000Z -u -d -1day` \
        -enddate `date +%y%m%d000000Z -u -d +5years+1day`


The signature will be valid for the next five years.


Revocation List (CRL)
^^^^^^^^^^^^^^^^^^^^^

We create the initial empty CRLs of the database CA::

    $ openssl ca -gencrl -out crl/database-ca.crl


Copy to Target Systems
^^^^^^^^^^^^^^^^^^^^^^

The CA is now ready to sign certificate requests.

Copy the following files to any system (database servers and clients) who
initialize or accept connections using certificates from this CA:

 * The CA certificate
 * The CRL file

 ::

    $ scp database-ca.cert.pem crl/database-ca.crl aiken.example.net:/etc/mysql/ssl/
    $ scp database-ca.cert.pem crl/database-ca.crl margaret.example.net:/etc/mysql/ssl/
    $ scp database-ca.cert.pem crl/database-ca.crl gannibal.example.net:/etc/mysql/ssl/


Also your own workstation may use them::

    $ mkdir -p ${HOME}/.mysql/ssl
    $ cp database-ca.cert.pem crl/database-ca.crl ${HOME}/.mysql/ssl



Certificate Signing Requests
----------------------------

Create certificate signing requests on any server and client connecting to any
other.

Prepare the environment::

    $ sudo mkdir -p /etc/mysql/ssl/private


Create a OpenSSL configuration file
:download:`/etc/mysql/ssl/openssl.cnf </server/config-files/etc/mysql/ssl/openssl.cnf>`
with the following contents:

.. literalinclude:: /server/config-files/etc/mysql/ssl/openssl.cnf
    :language: bash


Create a new certificate signing request as follows::

    $ cd /etc/mysql/ssl
    $ sudo -s
    $ export OPENSSL_CONF=/etc/mysql/ssl/openssl.cnf
    $ export CN=aiken.example.net
    $ openssl req -new -out ${CN}.req.pem


.. code-block:: text

    Generating a 3072 bit RSA private key
    ..........................................................................
    ........................................................................++
    ................................................................++
    writing new private key to './private/aiken.example.net.key.pem



Sign Certificates
-----------------

Go back to the certificate authority environment stored on a secure device::

    $ cd /media/$USER/safe_storage/database-ca


Copy the certificate signing request from the database server::

    $ scp aiken.example.net:/etc/mysql/ssl/aiken.example.net.req.pem certreqs/


Sign the CSR::

    $ export OPENSSL_CONF=./database-ca.cnf
    $ openssl ca \
        -in ./certreqs/aiken.example.net.req.pem \
        -out ./certs/aiken.example.net.cert.pem \
        -extensions cert_ext --policy cert_policy
    Using configuration from ./database-ca.cnf
    Enter pass phrase for ./private/database-ca.key: ********




References
----------

 * `Secure Connections <https://mariadb.com/kb/en/library/secure-connections/>`_
