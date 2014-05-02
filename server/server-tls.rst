TLS - Transport Layer Security
==============================
We use OpenSSL to generate TLS (Transport Layer Security) certificates and keys
(public and private keys).

.. warning::
   Following are recommendations valid in April 2014, using OpenSSL 1.0.1f under
   Ubuntu 14.04 LTS 'Trusty Thar'.


Prerequisites
---------------

Enough entropy for key generation and encryption. See :ref:`_increase-entropy`.

CAcert.org
----------
`CAcert <http://www.cacert.org>`_ has been dropped from the Ubuntu built-in 
list of trusted certificate authorities (CA) in February 2014. 
Also the Debian project no longer includes CAcert root certificates, since it 
started to use Mozilla's list of trusted CA's in March 2014.

Steps to re-include the CAcert root certificate in Ubuntu as trusted CA::

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

On a typical server OpenSSL is mostly used for CSR and key generation. However 
there is a lot of other (useless) stuff in the default configuration and some 
things have weak or even deprecated settings.

We want OpenSSL to behave as follows:

 * Generate RSA private keys with **4096** bits (default is 2048 bits).

 * Generate digital signatures using **SHA-256** as digest (default is SHA-1).

 * Don't encrypt private keys, as servers start and run without any user 
   interaction to answer password prompts.

 * Most servers are reachable as **www.exmaple.com** and as **example.com**.
   If multiple services are provided they most likely use additional
   subdomains like **mail.example.com**. A wildcard certificate is the easiest 
   way to secure everything with one certificate.

 * CAcert only uses the CN (common name) and if available the SubjectAltNames.
   All other information in the CSR is discarded.

 * StartSSL strips everything from the CSR and will ask for domain-names on 
   its website, when the request is submitted. You need Class 2 verification for
   wildcard domain certificates.

.. warning::
    Everything from here on is done as user **root** and from the
    :file:`/etc/ssl` directory.

::

    $ cd /etc/ssl
    $ sudo -s


Move the default :file:`/etc/ssl/opensssl.conf` file out of the way::

    $ mv openssl.cnf openssl.cnf-original

Create a new :file:`/etc/ssl/opensssl.conf` file in your editor::

    #
    # OpenSSL configuration for generation of certificate requests.
    #

    # This definition chokes if CN isn't defined.
    CN              = $ENV::CN
    HOME            = .
    RANDFILE        = $ENV::HOME/.rnd

    ####################################################################
    [ req ]
    default_bits            = 4096
    default_keyfile         = ${HOME}/private/${CN}.key.pem
    encrypt_key             = no
    string_mask             = utf8only
    default_md              = sha256
    distinguished_name      = req_distinguished_name
    req_extensions = v3_req 

    [ req_distinguished_name ]
    countryName                     = Country Name (2 letter code)
    countryName_default             = CH
    countryName_min                 = 2
    countryName_max                 = 2

    stateOrProvinceName             = State or Province Name (full name)
    stateOrProvinceName_default     = Zurich

    localityName                    = Locality Name (eg, city)
    localityName_default            = Zurich

    organizationName                = Organization Name (eg, company)
    organizationName_default        = ${CN}

    commonName                      = Common Name (FQDN Server Name)
    commonName_max                  = 64
    commonName_default              = ${CN}

    emailAddress                    = Email Address
    emailAddress_max                = 64
    emailAddress_default            = hostmaster@${CN}

    [ v3_req ]
    subjectAltName = @alt_names

    [ alt_names ]
    DNS.0 = ${CN}
    DNS.1 = *.${CN}


Generation of Keys and CSRs 
---------------------------

Create a new key and CSR::

    $ export CN=example.com
    $ openssl req -new -out ${CN}.req.pem
    Generating a 4096 bit RSA private key
    ..........................................................................
    ........................................................................++
    ................................................................++
    writing new private key to './private/example.com.key.pem'
    -----
    You are about to be asked to enter information that will be incorporated
    into your certificate request.
    What you are about to enter is what is called a Distinguished Name or a DN.
    There are quite a few fields but you can leave some blank
    For some fields there will be a default value,
    If you enter '.', the field will be left blank.
    -----
    Country Name (2 letter code) [CH]:
    State or Province Name (full name) [Zurich]:
    Locality Name (eg, city) [Zurich]:
    Organization Name (eg, company) [example.com]:
    Common Name (FQDN Server Name) [example.com]:
    Email Address [hostmaster@example.com]:

    $ chmod 600 private/${CN}.key.pem

An alternative command which supplies subject fields on the command-line::

    $ export CN=example.com
    $ openssl req -new -out alainwolf_ch.csr \
        -subj "/C=CH/ST=Zurich/L=Zurich/O=My Company Name/CN=${CN}/emailAddress=webmaster@example.com"
    $ chmod 600 private/${CN}.key.pem


.. _csr-multiple-domains:

CSR for Multiple Domain-Names
-----------------------------

If services for other domains are hosted, certificates should contains them too.

.. warning::
   You CA will only allow certificates containing *commonNames* and 
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

    $ export CN=example.com
    $ openssl req -config ${CN}.cnf -out ${CN}.req.pem -new
    $ sudo chmod 600 private/${CN}.key.pem


Submit Certificate Request
--------------------------
Copy the CSR to clipboard and paste it into the appropriate form on the website 
of the certificate authority::

    $ export CN=example.com
    $ cd /etc/ssl
    $ cat ${CN}.req.pem
    -----BEGIN CERTIFICATE REQUEST-----
    ...
    -----END CERTIFICATE REQUEST-----

After signing, the certificate authority will either offer you a file-download 
of the certificate or display its contents in PEM format. 
Install the signed certificate::

    $ export CN=example.com
    $ cd /etc/ssl
    cat << EOF > certs/${CN}.cert.pem
    -----BEGIN CERTIFICATE-----
    ...
    -----END CERTIFICATE-----
    EOF


Server Certificate Chains
-------------------------
Certificates signed by `StartSSL <https://startssl.com/>`_ are signed by its 
intermediary class 1 or class 2 server or client CA.

CAcert certificates may be signed be its intermediary "CAcert Class 3 Root"

Connecting TLS clients expect the server to send the certificates of any 
intermediary CA along with its own server certificate during the handshake.
::

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
       ..........................



On some servers (e.g. Nginx) this is achieved by providing a 
certificate-chain-file instead of a certificate file.

The chain file has the following form::


    -----BEGIN CERTIFICATE-----

    ..........................
    :   Server Certificate   :
    ..........................

    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----

    ............................
    : Intermediate Certificate :
    ............................

    -----END CERTIFICATE-----

Here are the steps to generate such certificate-chain-files.

Download the intermediate CA certificates::

    $ cd /etc/ssl/
    $ wget -O certs/StartCom_Class_1_Server_CA.pem \
        https://www.startssl.com/certs/class1/sha2/pem/sub.class1.server.sha2.ca.pem
    $ wget -O certs/StartCom_Class_2_Server_CA.pem \
        https://www.startssl.com/certs/class2/sha2/pem/sub.class2.server.sha2.ca.pem
    $ wget -O certs/CAcert_Class_3_Root.pem \
        http://www.cacert.org/certs/class3.crt

Assuming the certificate is for the domain "example.com" and our signed 
certificate is present as `/etc/ssl/certs/example.com.crt`. Use one of the 
commands below, depending on the intermediate signing autority of your 
certificate.

For StartCom Class 1 Primary Intermediate Server CA::

    $ export CN=example.com
    $ cat certs/${CN}.crt \
          certs/StartCom_Class_1_Server_CA.pem \
        > certs/${CN}.chained.crt

For StartCom Class 2 Primary Intermediate Server CA::

    $ export CN=example.com
    $ cat certs/${CN}.crt \
          certs/StartCom_Class_2_Server_CA.pem \
        > certs/${CN}.chained.crt

For CAcert Class 3 Root::

    $ export CN=example.com
    $ cat certs/${CN}.crt \
          certs/CAcert_Class_3_Root.pem \
        > certs/${CN}.chained.crt


OCSP Stapling Certificate Chains
--------------------------------
Something similar but the other way around is needed when a server is providing
OCSP responses on behalf of the client and sends them along its certificate 
during handshake.

The server knows about his own certificate, but in order to properly get and 
verify OCSP reponses, he needs to know about any intermediate CA up to and 
including the top-level signing CA.

The OCSP stapling chain file has the following form::

    -----BEGIN CERTIFICATE-----

    ..........................
    :   Root CA Certificate  :
    ..........................

    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----

    ...............................
    : Intermediate CA Certificate :
    ...............................

    -----END CERTIFICATE-----


To create OCSP stapling chain files, do the following:

For StartCom Class 1 Primary Intermediate Server CA::

    $ cat certs/StartCom_Certification_Authority.pem \
          certs/StartCom_Class_1_Server_CA.pem \
        > certs/StartCom_Class_1_Server.OCSP-chain.pem

StartCom Class 2 Primary Intermediate Server CA::

    $ cat certs/StartCom_Certification_Authority.pem \
          certs/StartCom_Class_2_Server_CA.pem \
        > certs/StartCom_Class_2_Server.OCSP-chain.pem

CAcert Class 3 Root::

    $ cat certs/root.pem \
          certs/CAcert_Class_3_Root.pem \
        > certs/CAcert_Class_3_Root.OCSP-chain.pem


Diffie-Hellman (DH) Key Exchanges Parameters
--------------------------------------------
To use perfect forward secrecy, Diffie-Hellman parameters must be set up on the 
server side, otherwise the relevant cipher suites will be silently ignored::

    mkdir -p dhparams
    openssl dhparam -out dhparams/dh_1024.pem 1024
    openssl dhparam -out dhparams/dh_1536.pem 1536

`bettercrypto.org <https://bettercrypto.org>`_ and other sources advise against 
generating these and instead using proven and properly checked ones and make 
references to :rfc:`3526`.

Unfortunately neither source nor the RFC tells how to get them.

The bettercrypto.org 
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

Now that we are done here, exit your root session::

    $ exit
    $ cd

