Certificates and Keys
=====================
We use `OpenSSL <http://openssl.org>`_ to generate :abbr:`TLS (Transport Layer 
Security)` certificates and keys (public and private keys).

.. warning::
   Following are recommendations valid in April 2014, using OpenSSL 1.0.1f under
   Ubuntu 14.04 LTS 'Trusty Thar'.

.. contents:: \ 


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

    $ sudo mkdir -p /usr/share/ca-certificates/cacert.org
    $ cd /usr/share/ca-certificates/cacert.org
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

 * Create **2048 bit** RSA private keys (default is 1024 bit).

 * All digital signatures use **SHA-256** as digest (default is SHA-1).

 * Never encrypt the servers private keys, as servers start and run without any 
   user interaction to answer password prompts (default would encrypt keys).

 * All certificates can be used by both, servers AND clients 
   (i.e. SMTP server receiving mail and SMTP client sending mail out).

 * The certficates include all the expected and needed extensions and 
   fields to be ready for use in encrypted HTTPS, SMTP, XMPP and VPN (OpenVPN)
   sessions.

 * Certificate siging requests contain the domain-name (**example.com**) and a
   wildcard (**\*.example.com**). Web servers are usually answering as 
   **exmaple.com** and **www.example.com**. Also usually every provided service 
   uses its own hostname or subdomain like **mail.example.com**. A wildcard 
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

Enforce to create 2048 bit keys, set the location and name of private key files, 
disable password protection of server private keys, use the SHA-256 algoritm to 
sign our keys.

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: SRVName
    :end-before: [ req_extensions ]


A certificates has information included what kind of things and services can be
certified with it. Following is the minimum needed to authenticate and encrypt 
communications as a client or as server.

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
multiple keys, certificates and submmission to CAs for every name or domain.

.. literalinclude:: config-files/openssl-server.cnf
    :language: ini
    :start-after: = ${CN}


The complete configuration file described here is available for 
:download:`download <config-files/openssl-server.cnf>` also.


Getting Certificates
--------------------

.. note::
    Everything from here on is done as user **root** and from the
    :file:`/etc/ssl` directory. Also the evironment variables **OPENSSL_CONF**
    (pointing to our configuration file) and **CN** (containing your our domain
    name) must be set until all work described in this chapter is done.

::

    $ cd /etc/ssl
    $ sudo -s
    $ export OPENSSL_CONF=/etc/ssl/openssl-server.cnf
    $ export CN=example.com


Generation of Keys and CSRs 
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Create a new key and CSR::

    $ openssl req -new -out ${CN}.req.pem
    Generating a 4096 bit RSA private key
    ..........................................................................
    ........................................................................++
    ................................................................++
    writing new private key to './private/example.com.key.pem'
    $ chmod 600 private/${CN}.key.pem

The key and CSR are saved in files using the :abbr:`PEM (Privacy-enhanced 
Electronic Mail - Base64 encoded binary data, enclosed between "-----BEGIN 
CERTIFICATE-----" and "-----END CERTIFICATE-----" strings.)` format.

.. _csr-multiple-domains:

CSR for Multiple Domain-Names
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If services for other domains are hosted, certificates should contains them too.

.. warning::
   Your CA will only allow certificates containing *commonNames* and 
   *subjectAltNames* for domains you previously have validated with them.

Edit the :file:`/etc/ssl/openssl.cnf` file. Add all the required domain-names 
for the server in the section called 
**[ alt_names ]** as follows::

    [ alt_names ]
    DNS.0 = commonName:copy
    DNS.1 = www.example.com
    DNS.2 = example.net
    DNS.3 = www.example.net
    DNS.4 = other-example.com
    DNS.5 = www.other-example.com


Save and close the file and create the CSR as before::

    $ openssl req -config ${CN}.cnf -out ${CN}.req.pem -new
    $ sudo chmod 600 private/${CN}.key.pem


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
       : Trusted CA Certificate :   <--- Present in Client/Browser Certificate Storge
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

Use one of the commands below, depending on the intermediate signing autority of
your certificate.


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
verify OCSP reponses, he needs to know about any intermediate CA up to and 
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


Diffie-Hellman (DH) Key Exchanges Parameters
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

To use perfect forward secrecy, Diffie-Hellman parameters must be set up on the 
server side, otherwise the relevant cipher suites will be silently ignored.

`bettercrypto.org <https://bettercrypto.org>`_ and other sources advise against 
generating these and instead using proven and properly checked ones and make 
references to :rfc:`3526`.

Other sources adivse you to build your own instead of using the predefined ones, 
as it is unclear where they come from and why they should be better. Some even 
suggest to create new ones every day or every hour, to further incerease security.

Use the following OpenSSL command to create your own set of DH paramteer files::

    mkdir -p dhparams
    openssl dhparam -out dhparams/dh_1024.pem 1024
    openssl dhparam -out dhparams/dh_1536.pem 1536


The predefined ones are hard to find. But the bettercrypto.org 
`Git-Repository <https://github.com/BetterCrypto/Applied-Crypto-Hardening>`_ 
contains a directory with some files and a readme in the 
`/tools/dhparams <https://github.com/BetterCrypto/Applied-Crypto-Hardening/tree/master/tools/dhparams>`_
directory.

To get those pre-made dhparam files::

    wget -O dhparams/dh_2048.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group14.pem
    wget -O dhparams/dh_3072.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group15.pem
    wget -O dhparams/dh_4096.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group16.pem
    wget -O dhparams/dh_6144.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group17.pem
    wget -O dhparams/dh_8192.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group18.pem


Exit Session
------------

Now that we are done here, exit the root session (the environment variables will
be discarded)::

    $ exit
    $ cd


.. index:: Cipher Suite; Selection of

.. _cipher-suite:

Cipher Suite Selection
------------------------------

..  note::

    :term:`TL;DR`: this is our official :term:`cipher suite` list string, which 
    we will use in all our services:
    **kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3**

The quest for the perfect :term:`Cipher Suite` list is an endless one, simply
because there is no perfect solution.

For our private servers for mostly personal use and presumably limited public
interest or commecrial goals, we have the luxury to enforce a more secure, but
less compatible set of cipher suites.

.. note::     
    Windows XP clients using Internet Explorer will not be able to connect to
    any of your servers.

Following is the composition of our Cipher suite list using the the OpenSSL
:manpage:`ciphers (1SSL)` command. The command displays as a list of all cipher
suites available with the current selection parameters.

::

    $ openssl ciphers -v '<Selection Parameters>' | column -t

.. index:: Perfect Forward Secrecy

Perfect Forward Secrecy
^^^^^^^^^^^^^^^^^^^^^^^

All our encrypted communications is to be establsihed using :term:`Perfect
Forward Secrecy`.

In todays OpenSSL the available ciphers suites who are able to provide forward
secrecy are the ones who use :term:`Diffie-Hellman key exchange`.

To list those, you can use ...

.. parsed-literal::
    
    \ **kEDH**\ :\ **kEECDH**

as selection parameter with the OpenSSL :command:`ciphers` command and you will
get a list of 61 available cipher suites on my [#f1]_ system.

.. index:: Key Authentication


RSA Key Authentication
^^^^^^^^^^^^^^^^^^^^^^

The private keys to our certificates are :term:`RSA` keys. Any other type of key
authentication would simply not work.

One can select all ciphers suites who use RSA key authentiation with the
"\ **aRSA**" selection parameter. This will list 43 available cipher suites.

Combined with the earlier "kEDH:kEECDH" parameter like this: 

.. parsed-literal::

    kEDH\ **+aRSA**:kEECDH\ **+aRSA**

The list shrinks to 21 ciphers suites.


AES Encryption
^^^^^^^^^^^^^^

Looking at the current selection, there are many who clearly we don't want to
use. Like :term:`RC4`, :term:`3DES`, :term:`DES` or some with weak export-grade
or no encryption at all.

To make things easier we just decide to select AES. Its the most widely trusted
encryption standard, supported on all plattforms and client software, and as big
plus, modern CPUs include hardware acceleration for AES with the :term:`Advanced
Encryption Standard Instruction Set`. OpenSSL lists 58 cipher suites when used
with the "AES" parameter. Combined with our earlier selections:

.. parsed-literal::

    kEDH+aRSA+\ **AES**\ :kEECDH+aRSA+\ **AES**

Number of matching cipher suites: 12. And they are all suitable, as they provide
either 128-bit or 256-bit encryption. With this list we already get top
scores on test-sites like `SSLlabs <https://www.ssllabs.com/>`_.


Preferences
^^^^^^^^^^^

Hower there is still some small room for improvement. Some cipher suites in our
selection use :term:`SHA-1` for message authentication (:term:`HMAC`).

While SHA-1 is not considered broken or harmful for this specific use, its use
is no longer recommendet. However if we exclude it, we loose compatibility with
a lot of client platforms and software. This would include:

 * Android devices less then version 4.4 (before December 2013)
 * Bing search engine
 * Firefox browsers less then version 25 (before December 2013)
 * Google search engine
 * Internet Explorer less then version 11
 * Java less then version 8
 * OpenSSL 0.9.8 (only version 1.0.1)
 * OS X less then version 10.9.
 * Safari Browsers up to version 6 
 * Windows less then version 8 and Windows Mobile less then version 10
 * Yahoo search engine

So unless you are sure that any of the above list will not be connecting to any
of your servers, we need to support it.

But we can push it to the end of our list, so that it will only be used, when
all other options failed already.

.. parsed-literal::
    
    kEDH+aRSA+AES:kEECDH+aRSA+AES:\ **+SSLv3**

This give the same list of 12 cipher suites, but the ones using SHA-1 moved to
the bottom.

Encryption Strenght
^^^^^^^^^^^^^^^^^^^

And yet still I have one more point to make.

As already mentioned all our selected cipher suites use either 128-bit or
256-bit encryption. Thats OK for most, some would even be tempted to use only
256-bit (only to discover that not even the newest Firefox browser would work
anymore).

If we trust 128-bit encryption, and recent findings predict 128-bit encryption
to be strong enough for another 30 years or so, then why use 256-bit then?

Bigger is not always better. The time for a handshake between server and client
increeases dramatically with 256-bit encryption compared to 128-bit. And lets
not forget the mobile devices, who may not have a CPU with :term:`AES-NI`
besides being weaker nd smaller on the hardware-side.

So to only select the 29 different 128-bit variants out of the 58 suites with
AES encryption, one can use "AES\ **128**\ " instead of just "AES" as selection
parameter:

.. parsed-literal::
    
    kEDH+aRSA+AES\ **128**\ :kEECDH+aRSA+AES\ **128**\ :+SSLv3

That gives a list of 6 remaining cipher suites, as shown below:

.. code-block:: bash

    $ openssl ciphers -v 'kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3' | column -t

.. code-block:: text

    1. DHE-RSA-AES128-GCM-SHA256   TLSv1.2 Kx=DH   Au=RSA Enc=AESGCM(128) Mac=AEAD
    2. DHE-RSA-AES128-SHA256       TLSv1.2 Kx=DH   Au=RSA Enc=AES(128)    Mac=SHA256
    3. ECDHE-RSA-AES128-GCM-SHA256 TLSv1.2 Kx=ECDH Au=RSA Enc=AESGCM(128) Mac=AEAD
    4. ECDHE-RSA-AES128-SHA256     TLSv1.2 Kx=ECDH Au=RSA Enc=AES(128)    Mac=SHA256
    5. DHE-RSA-AES128-SHA          SSLv3   Kx=DH   Au=RSA Enc=AES(128)    Mac=SHA1
    6. ECDHE-RSA-AES128-SHA        SSLv3   Kx=ECDH Au=RSA Enc=AES(128)    Mac=SHA1

The same ciphers list in RFC Strings Format as shown on the `Qualys SSL test
website <https://www.ssllabs.com/ssltest/>`_:

.. code-block:: text

    1. TLS_DHE_RSA_WITH_AES_128_GCM_SHA256 (0x9e)       DH 1024 bits (p: 128, g: 1, Ys: 128)    FS  128
    2. TLS_DHE_RSA_WITH_AES_128_CBC_SHA256 (0x67)       DH 1024 bits (p: 128, g: 1, Ys: 128)    FS  128
    3. TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256 (0xc02f)   ECDH 256 bits (eq. 3072 bits RSA)       FS  128
    4. TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256 (0xc027)   ECDH 256 bits (eq. 3072 bits RSA)       FS  128
    5. TLS_DHE_RSA_WITH_AES_128_CBC_SHA (0x33)          DH 1024 bits (p: 128, g: 1, Ys: 128)    FS  128
    6. TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA (0xc013)      ECDH 256 bits (eq. 3072 bits RSA)       FS  128









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

Usage instructions are provided when called with the `-h` commandline parameter::

    $ ssl-cert-check -h
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
      -s commmon name   : Server to connect to (interactive mode)
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

    $ ssl-cert-check -i -q -c /etc/ssl/certs/example.com.cert.pem
    Host                                            Status       Expires      Days
    ----------------------------------------------- ------------ ------------ ----
    FILE:/etc/ssl/certs/example.com.cert.pem        Valid        May 2 2016   699     


Automatic daily check
^^^^^^^^^^^^^^^^^^^^^

To have the server check his certificates every day and notify you by mail in 
case of the expiration date in less then 30 days, we add a cronjob as follows::

    $ sudo -s
    $ echo "ssl-cert-check -a -c /etc/ssl/certs/example.com.cert.pem"
        >> /etc/cron.daily/ssl-cert-check
    chmod +x /etc/cron.daily/ssl-cert-check
    $ exit

In case there are more certificates-files to check, just repeat the second line
above for each file with its path and filename.

.. rubric:: Footnotes

.. [#f1] The number of suites supporting particular features varies between
         versions of OpenSSL.
