Certificates and Keys
=====================
We use `OpenSSL <http://openssl.org>`_ to generate :abbr:`TLS (Transport Layer
Security)` certificates and keys (public and private keys).

.. warning::
   Following are recommendations valid in April 2014, using OpenSSL 1.0.1f under
   Ubuntu 14.04 LTS 'Trusty Thar'.

.. contents::
  :local:


Prerequisites
-------------

Enough entropy for key generation and encryption. See :doc:`entropy`.


CAcert.org
----------
`CAcert <http://www.cacert.org>`_ has been dropped from the Ubuntu built-in
list of trusted certificate authorities in `February 2014
<https://bugs.launchpad.net/ubuntu/+source/ca-certificates/+bug/1258286>`_.
Also the Debian project no longer includes CAcert root certificates, since it
started to use Mozilla's list of trusted certificate authorities in `March 2014
<https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=718434>`_.

Steps to re-include the CAcert root certificate in Ubuntu as trusted
:abbr:`CA (Certificate Authority)`::

    $ sudo mkdir -p /usr/local/share/ca-certificates/cacert.org
    $ cd /usr/local/share/ca-certificates/cacert.org
    $ sudo wget http://www.cacert.org/certs/root.crt
    $ sudo dpkg-reconfigure ca-certificates


OpenSSL Configuration
----------------------

.. note::
    Alternatively generation and management of keys, certificate signing
    requests and certificates can also be handled on a desktop system using
    `xca <http://xca.sourceforge.net>`_.

Default system wide OpenSSL configuration is in the file
:file:`/etc/ssl/openssl.cnf`.

On a typical server OpenSSL is mostly used for :abbr:`CSR (Certificate Signing
Request)` and key generation. However there is a lot of other (useless) stuff in
the default configuration and some things have weak or even deprecated settings.

We want OpenSSL to behave as follows:

 * Create **3072 bit** RSA private keys (default is 1024 or 2048 bit).

 * All digital signatures use **SHA-256** as digest (default is SHA-1).

 * Never encrypt the servers private keys, as servers start and run without any
   user interaction to answer password prompts (default would encrypt keys).

 * All certificates can be used by both, servers AND clients
   (i.e. SMTP server receiving mail and SMTP client sending mail out).

 * The certificates include all the expected and needed extensions and
   fields to be ready for use in encrypted HTTPS, SMTP, XMPP and VPN (OpenVPN)
   sessions.

 * Certificate signing requests contain the domain-name (**example.net**) and a
   wildcard (**\*.example.net**). Web servers are usually answering as
   **example.net** and **www.example.net**. Also usually every provided service
   uses its own hostname or sub-domain like **mail.example.net**. A wildcard
   certificate is the easiest way to secure everything with only one certificate.

 * The created certificate siging requests don't include anything we don't need.
   CAcert only uses the CN (common name) and if available the
   **SubjectAltNames**. All other information in the CSR is discarded.
   `StartSSL <https://www.startssl.com>`_ strips everything from the CSR
   and will ask for domain-names on its website, when the request is submitted.

.. note::
    StartSSL requires you to complete a `Class-2 verification
    <https://www.startssl.com/?app=34>`_ (carries a US$ 59.90 fee) of your
    identity before they will issue wildcard domain certificates for you.


Create a new :file:`/etc/ssl/openssl-server.cnf` file with the following
contents.

The header of the file:

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :end-before: [ new_oids ]

The following is to make our certficates valid for use with XMPP:

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: oid_section
    :end-before: [ req ]

Enforce to create 3072 bit keys, set the location and name of private key files,
disable password protection of server private keys, use the SHA-256 algorithm to
sign our keys.

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: id-on-dnsSRV
    :end-before: [ req_extensions ]


A certificates has information included what kind of things and services can be
certified with it. Following is the minimum needed to authenticate and encrypt
communications as a client or as server.

 * Since our certificates are based on RSA keys, **keyEncipherment** is
   needed for as **Key Usage**.

 * Since our servers support Diffie-Hellmann key exchanges, the **Key Usage**
   extension includes **digitalSignature**

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: distinguished_name
    :end-before: [ req_distinguished_name ]


The identity information included in certificats, cut to the minimum
actually used is one line only.

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: subjectAltName
    :end-before: [ subj_alt_names ]


Finally the alternative names are defined, which enables the server to present
himself under different names and identities. So multiple virtual names and
domains can be hosted by the same physical server. Without the needing for
multiple keys, certificates and submission to CAs for every name or domain.

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: = ${CN}


The complete configuration file described here is available for
:download:`download <config-files/openssl-server.cnf>` also.


Getting Certificates
--------------------

.. note::
    Everything from here on is done as user **root** and from the
    :file:`/etc/ssl` directory. Also the environment variables **OPENSSL_CONF**
    (pointing to our configuration file) and **CN** (containing your our domain
    name) must be set until all work described in this chapter is done.

::

    $ cd /etc/ssl
    $ sudo -s
    $ export OPENSSL_CONF=/etc/ssl/openssl-server.cnf
    $ export CN=example.net


Generation of Keys and CSRs
^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

    For :term:`HTTP Public Key Pinning` (:term:`HPKP`) Web-servers need
    **two separate private keys**. One will be active with the certificate from
    the CA, while a second one is pre-made backup key. Both keys are advertised
    by the web- server in its HTTP headers as Public-Key-Pins.

.. note::

    As of October 2017 :term:`HTTP Public Key Pinning` (:term:`HPKP`) is in the
    process of being deprecated. But having a backup key ready remains a good
    recommendation for use with :term:`DANE` and :term:`TLSA`.


Create the first key and the CSR::

    $ openssl req -new -out ${CN}.req.pem
    Generating a 3072 bit RSA private key
    ..........................................................................
    ........................................................................++
    ................................................................++
    writing new private key to './private/example.net.key.pem'


Create the backup key::

    $ openssl genrsa -out private/${CN}.backup.key.pem 3072
    Generating a 3072 bit RSA private key
    ..........................................................................
    ........................................................................++
    ................................................................++
    writing new private key to './private/example.net.backup.key.pem'
    $ chmod 600 private/${CN}*.key.pem


The keys and the CSR are saved in files using the :abbr:`PEM (Privacy-enhanced
Electronic Mail - Base64 encoded binary data, enclosed between "-----BEGIN
CERTIFICATE-----" and "-----END CERTIFICATE-----" strings.)` format.


CSR Generation for existing Keys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

You may need to create a new CSR where the key already exists (i.e. a previously
generated backup key) or one can use the same private key with different
certificates::

  $ openssl req -new -out ${CN}.req.pem -key private/${CN}.key.pem



.. _csr-multiple-domains:


CSR for Multiple Domain-Names
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If services for other domains are hosted, you have to add them as additional
DNS entries to the `[ alt_names ]` section.

.. warning::
   Your CA will only allow certificates containing *commonNames* and
   *subjectAltNames* for domains you previously have validated with them.

Assume you want to add **example.net** and **example.org** to your
**example.net** certificate:

Make a copy of :file:`/etc/ssl/openssl-server.cnf`

 ::

  $ cp openssl-server.cnf openssl-${CN}.cnf


Add all the required domain-names in the section called  **[ alt_names ]** as
follows:

.. code-block:: ini

    [ alt_names ]
    DNS.0                       = ${CN}
    DNS.1                       = *.${CN}
    otherName.0                 = xmppAddr;FORMAT:UTF8,UTF8:${CN}
    otherName.1                 = SRVName;IA5STRING:_xmpp-client.${CN}
    otherName.2                 = SRVName;IA5STRING:_xmpp-server.${CN}
    DNS.2 = example.net
    DNS.3 = *.example.net
    DNS.4 = example.org
    DNS.5 = *.example.org


Save and close the file and create keys and CSR as shown before, but point to
the newly created configuration file::

    $ openssl req -config openssl-${CN}.cnf -out ${CN}.req.pem -new
    $ openssl genrsa -out private/${CN}.backup.key.pem 3072
    $ sudo chmod 600 private/${CN}*.key.pem


Submit Certificate Request
^^^^^^^^^^^^^^^^^^^^^^^^^^

Copy the CSR to clipboard and paste it into the appropriate form on the website
of the certificate authority::

    $ cat ${CN}.req.pem
    -----BEGIN CERTIFICATE REQUEST-----
    ...
    -----END CERTIFICATE REQUEST-----

After signing, the certificate authority will either offer you a file-download
of the certificate or display its contents in PEM format.
Install the signed certificate::

    cat << EOF > certs/${CN}.cert.pem
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
    EOF


Server Certificate Chains
^^^^^^^^^^^^^^^^^^^^^^^^^

Certificates signed by StartSSL are signed by its intermediary class 1 or class
2 server or client CA.

CAcert certificates may be signed be its intermediary "CAcert Class 3 Root"

Connecting TLS clients expect the server to send the certificates of any
intermediary CA along with its own server certificate during the handshake.

.. code-block:: text

         ......................
         : Server Certificate :   <--- Sent by Server
         ......................
                   |
      ............................
      : Intermediate Certificate :   <--- Sent by Server
      ............................
                   |
       ..........................
       : Trusted CA Certificate :   <--- Present in Client/Browser Certificate Storage
       ..........................        (Don't send)



On some servers (e.g. Nginx) this is achieved by providing a
certificate-chain-file instead of a certificate file.

The chain file has the following form:

.. code-block:: text

  ................................
  :                              :
  :  ..........................  :
  :  :   PEM encoded Server   :  :
  :  :       Certificate      :  :
  :  ..........................  :
  :                              :
  :  ..........................  :
  :  :   PEM encoded inter-   :  :
  :  :   mediate Certificate  :  :
  :  ..........................  :
  :                              :
  :..............................:


Here are the steps to generate such certificate-chain-files.

Use one of the commands below, depending on the intermediate signing authority
of your certificate.


For **StartCom Class 1** Primary Intermediate Server CA::

    $ wget -O certs/StartCom_Class_1_Server_CA.pem \
        https://www.startssl.com/certs/class1/sha2/pem/sub.class1.server.sha2.ca.pem
    $ cat certs/${CN}.cert.pem \
          certs/StartCom_Class_1_Server_CA.pem \
        > certs/${CN}.chained.cert.pem

For **StartCom Class 2** Primary Intermediate Server CA::

    $ wget -O certs/StartCom_Class_2_Server_CA.pem \
        https://www.startssl.com/certs/class2/sha2/pem/sub.class2.server.sha2.ca.pem
    $ cat certs/${CN}.cert.pem \
          certs/StartCom_Class_2_Server_CA.pem \
        > certs/${CN}.chained.cert.pem

For **CAcert Class 3** Root::

    $ wget -O certs/CAcert_Class_3_Root.pem \
        http://www.cacert.org/certs/class3.crt
    $ cat certs/${CN}.cert.pem \
          certs/CAcert_Class_3_Root.pem \
        > certs/${CN}.chained.cert.pem


OCSP Stapling Certificate Chains
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Something similar but the other way around is needed when a server is providing
OCSP responses on behalf of the client and sends them along its certificate
during handshake.

The server knows about his own certificate, but in order to properly get and
verify OCSP responses, he needs to know about any intermediate CA up to and
including the top-level signing CA.

The OCSP stapling chain file has the following form:

.. code-block:: text

  ................................
  :                              :
  :  ..........................  :
  :  :   PEM encoded Root CA  :  :
  :  :      Certificate       :  :
  :  ..........................  :
  :                              :
  :  ..........................  :
  :  :   PEM encoded inter-   :  :
  :  :   mediate Certificate  :  :
  :  ..........................  :
  :                              :
  :..............................:


To create OCSP stapling chain files, do the following:

For **StartCom Class 1** Primary Intermediate Server CA::

    $ cat certs/StartCom_Certification_Authority.pem \
          certs/StartCom_Class_1_Server_CA.pem \
        > certs/StartCom_Class_1_Server.OCSP-chain.pem

StartCom **Class 2 Primary** Intermediate Server CA::

    $ cat certs/StartCom_Certification_Authority.pem \
          certs/StartCom_Class_2_Server_CA.pem \
        > certs/StartCom_Class_2_Server.OCSP-chain.pem

**CAcert Class 3** Root::

    $ cat certs/root.pem \
          certs/CAcert_Class_3_Root.pem \
        > certs/CAcert_Class_3_Root.OCSP-chain.pem



Exit Session
^^^^^^^^^^^^

Now that we are done here, exit the root session (the environment variables will
be discarded)::

    $ exit
    $ cd


Other Settings
--------------

SSL and TLS Versions
^^^^^^^^^^^^^^^^^^^^

 * Use TLS version 1.2 whenever possible its the preferred most secure,
   extensible, and modern version
 * Support TLS versions 1.1 and 1.0 for older clients
 * Don't use SSL versions 3 and 2


Diffie-Hellman (DH) Key Exchange
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To use perfect forward secrecy, Diffie-Hellman parameters must be set up on the
server side, otherwise the relevant cipher suites will be silently ignored.

.. note::

    The bit-size of your DH parameters should be equal or greater than the size
    of your RSA private key. I.e. if you have a 3072-bit RSA key as suggested
    above, create and use at least a 3072-bit DH-parameter file.


You should build your own parameter files and re-create them periodically.

The following shell script :download:`dhparam_create.sh <scripts/dhparam_create.sh>` will do just that:

.. literalinclude:: scripts/dhparam_create.sh


Let a cron job run this script periodically, to refresh your set::

    #
    # Re-create Diffie-Hellmann Key Exchange Parameters
    #min    hour    mday    month   wday    user    cmd
    33      4       */21    *       *       root    /root/bin/dhparam_create.sh


Elliptic Curve Diffie-Hellmann (ECDH)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The choice of which elliptic curve (EC) algorithm is used during Diffie Hellmann
key exchange (DH) is a separate setting in most software configurations.

The used elliptic curve should match the RSA key size, while taking into
consideration that you get the same strength with smaller bit sizes.

There would be no point in having a strong RSA key but the use a weaker key-
exchange.

============= ============== ==========
EC DH         RSA DH         Safe until
============= ============== ==========
160 bits      1,024 bits     Year 2010
224 bits      2,048 bits     Year 2030
256 bits      3,072 bits     Year 2030+
384 bits      7,680 bits     Year 2030+
512 bits      15'360 bits    Year 2030+
============= ============== ==========

256 bit elliptic curve encryption equals 3072 bit RSA encryption. Therefore a
curve like **secp256r1** (NIST/SECG curve over a 256 bit prime field) should be
used.


Monitoring
----------

All digital certificates contain an expiration date which most client and server
applications will check before using the certificates contents.

When a web browser encounters an expired certificate, the browser will normally
present the user with a warning message indicating that the certificate has
expired.

An expired certificate frustrates users and limits the servers ability to
seamlessly deliver content to clients.

`SSL Certificate Checker <http://prefetch.net/articles/checkcertificate.html>`_
(ssl-cert-check), can extract the certificate expiration date from a live server
or from a PEM encoded X.509 certificate file.  If :file:`ssl-cert-check` finds a
certificate that will expire within a user defined threshold (e.g., the next
60-days), an e-mail notification is sent to warn the adminstrator.


Installation
^^^^^^^^^^^^

::

    $ sudo apt-get ssl-cert-check


Usage
^^^^^

Usage instructions are provided when called with the `-h` command-line parameter::

    $ ssl-cert-check -h


.. code-block:: text

    Usage: /usr/bin/ssl-cert-check [ -e email address ] [ -x days ] [-q] [-a] [-b] [-h] [-i] [-n] [-v]
           { [ -s common_name ] && [ -p port] } || { [ -f cert_file ] } || { [ -c certificate file ] }

      -a                : Send a warning message through E-mail
      -b                : Will not print header
      -c cert file      : Print the expiration date for the PEM or PKCS12 formatted certificate in cert file
      -e E-mail address : E-mail address to send expiration notices
      -f cert file      : File with a list of FQDNs and ports
      -h                : Print this screen
      -i                : Print the issuer of the certificate
      -k password       : PKCS12 file password
      -n                : Run as a Nagios plugin
      -p port           : Port to connect to (interactive mode)
      -s common name    : Server to connect to (interactive mode)
      -t type           : Specify the certificate type
      -q                : Don't print anything on the console
      -v                : Specify a specific protocol version to use (tls, ssl2, ssl3)
      -V                : Only print validation data
      -x days           : Certificate expiration interval (eg. if cert_date < days)


.. note ::

    ssl-cert-check uses the OpenSSL :manpage:`s_client` built-in command. As of
    today this command lacks support for IPv6 and SNI. Therefore we can't check
    our servers by connecting to them, but have to check our certificate files
    on disk.

To check a certificate file::

    $ ssl-cert-check -i -q -c /etc/ssl/certs/example.net.cert.pem
    Host                                            Status       Expires      Days
    ----------------------------------------------- ------------ ------------ ----
    FILE:/etc/ssl/certs/example.net.cert.pem        Valid        May 2 2016   699


Automatic daily check
^^^^^^^^^^^^^^^^^^^^^

To have the server check his certificates every day and notify you by mail in
case of the expiration date in less then 30 days, we add a cron-job as follows::

    $ sudo -s
    $ echo "ssl-cert-check -a -c /etc/ssl/certs/example.net.cert.pem"
        >> /etc/cron.daily/ssl-cert-check
    chmod +x /etc/cron.daily/ssl-cert-check
    $ exit

In case there are more certificates-files to check, just repeat the second line
above for each file with its path and filename.
