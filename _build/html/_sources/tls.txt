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


OpenSSL Configuration
----------------------

.. note::
    Alternatively generation and management of keys, certificate signing 
    requests and certificates can also be handled on a desktop system using 
    `xca <http://xca.sourceforge.net>`_.

Default system wide OpenSSL configuration is in the file 
:file:`/etc/ssl/openssl.cnf`. On a typical server it is mostly used for key 
generation.

Documentation is available in the :manpage:`config(5)` man page. 

OpenSSL on a server should behave as follows:

 * Generate RSA private keys with **4096** bits (default is 2048 bits).

 * Generate digital signatures using **SHA-2** as digest (default is SHA-1 
   digest).

 * Don't encrypt private keys, as servers start and run without any users present
   to answer password prompts.

 * 3rd-party CAs like CAcert or StartSSL only use the CN (common name) and maybe
   the SubjectAltNames of the submitted CSR. All other information is typically 
   discarded.

Open :file:`/etc/ssl/opensssl.conf` in your editor

Change the "[ req ]" section as follows::

    ####################################################################
    [ req ]
    default_bits            = 4096
    default_keyfile         = $ENV::HOME/$ENV::CN.key.pem
    distinguished_name      = req_distinguished_name
    #attributes             = req_attributes
    x509_extensions = v3_ca # The extentions to add to the self signed cert
    # Passwords for private keys if not present they will be prompted for
    input_password =
    output_password =


Change the "[ req_distinguished_name ]" section as follows::

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
    organizationName_default        = alainwolf.net

    organizationalUnitName          = Organizational Unit Name (eg, section)
    organizationalUnitName_default  = Internet Services

    commonName                      = Common Name (e.g. server FQDN or YOUR name)
    commonName_max                  = 64
    commonName_default              = $ENV::CN

    emailAddress                    = Email Address
    emailAddress_max                = 64
    emailAddress_default            = hostmaster@$ENV::CN


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


Generation of Keys and CSRs 
---------------------------

Create a private key::

    $ export CN=example.com
    $ cd /etc/ssl
    $ sudo openssl genrsa -nodes -out private/${CN}.key.pem 4096
    $ sudo chmod 600 private/${CN}.key.pem
    
Create a certificate signing request (CSR)::

    $ export CN=example.com
    $ cd /etc/ssl
    $ openssl req -out ${CN}.req.pem -new -key private/${CN}.key.pem -sha2

Create key and CSR::

    $ export CN=example.com
    $ cd /etc/ssl
    $ openssl req -newkey rsa:4096 -nodes -sha2 \
        -out ${CN}.req.pem
        -keyout private/${CN}.key.pem
    $ sudo chmod 600 private/${CN}.key.pem

An alternative command which supplies subject fields on the command-line::

    $ export CN=example.com
    $ cd /etc/ssl
    $ openssl req -new -newkey rsa:4096 -nodes -sha2 \
        -out alainwolf_ch.csr \
        -keyout alainwolf_ch.key \
        -subj "/C=CH/ST=Zurich/L=Zurich/O=My Company Name/CN=${CN}/emailAddress=webmaster@example.com"
    $ sudo chmod 600 private/${CN}.key.pem


.. _csr-multiple-domains:

CSR for Multiple Domain-Names
-----------------------------

Most websites are reachable with and without "www" before the domain name.

.. warning::
   You CA will only allow certificates containing *commonNames* and 
   *subjectAltNames* for domains you previously have validated with them.

Here is how to create certficate signing request for a server with multiple 
domain names and/or virtual hosts::

    $ export CN=example.com
    $ cd /etc/ssl
    $ cp openssl.cnf ${CN}.conf
    $ edit ${CN}.conf

Look for the section called "[ req ]" and add or uncomment the following line::

    req_extensions = v3_req
    
Look for the section called "[ v3_req ]" and add the following line::

    subjectAltName = @alt_names

Add all the required domain-names for the server as follows::

    [alt_names]
    DNS.0 = commonName:copy
    DNS.1 = www.example.com
    DNS.2 = example.net
    DNS.3 = www.example.net
    DNS.4 = other-example.com
    DNS.5 = www.other-example.com


Save and close the file and create the CSR as follows::

    $ openssl req -config ${CN}.conf -out ${CN}.req.pem -newkey rsa:4096 \
        -keyout private/${CN}.key.pem -nodes -sha2
    $ sudo chmod 600 private/${CN}.key.pem


CSR with Wild-Card Domain Names
-------------------------------

Follow the procedure for :ref:`csr-multiple-domains` above, but add wild-cards as
follows in the "[alt_names]" section::

    [alt_names]
    DNS.0 = commonName:copy
    DNS.1 = *.example.com


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
    $ sudo wget -O certs/StartCom_Class_1_Server_CA.pem \
        https://www.startssl.com/certs/class1/sha2/pem/sub.class1.server.sha2.ca.pem
    $ sudo wget -O certs/StartCom_Class_2_Server_CA.pem \
        https://www.startssl.com/certs/class2/sha2/pem/sub.class2.server.sha2.ca.pem
    $ sudo wget -O certs/CAcert_Class_3_Root.pem \
        http://www.cacert.org/certs/class3.crt

Assuming the certificate is for the domain "example.com" and our signed 
certificate is present as `/etc/ssl/certs/example.com.crt`.

StartCom Class 1 Primary Intermediate Server CA::

    $ export CN=example.com
    $ cd /etc/ssl/
    $ sudo cat certs/${CN}.crt \
             certs/StartCom_Class_1_Server_CA.pem \
        > ${CN}.chained.crt

StartCom Class 2 Primary Intermediate Server CA::

    $ export CN=example.com
    $ cd /etc/ssl/
    $ sudo cat certs/${CN}.crt \
             certs/StartCom_Class_2_Server_CA.pem \
        > ${CN}.chained.crt

CAcert Class 3 Root::

    $ export CN=example.com
    $ cd /etc/ssl/
    $ sudo cat certs/${CN}.crt \
             certs/CAcert_Class_3_Root.pem \
        > ${CN}.chained.crt


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

StartCom Class 1 Primary Intermediate Server CA::

    $ cd /etc/ssl/
    $ cat certs/StartCom_Certification_Authority.pem \
          certs/certs/StartCom_Class_1_Server_CA.pem \
        > StartCom_Class_1_Server.OCSP-chain.pem

StartCom Class 2 Primary Intermediate Server CA::

    $ cd /etc/ssl/

CAcert Class 3 Root::

    $ cd /etc/ssl/


Diffie-Hellman (DH) Key Exchanges Parameters
--------------------------------------------
To use perfect forward secrecy, Diffie-Hellman parameters must be set up on the 
server side, otherwise the relevant cipher suites will be silently ignored::

    cd /etc/ssl
    sudo mkdir dhparams
    sudo openssl dhparam -out dhparams/dh_1024.pem 1024
    sudo openssl dhparam -out dhparams/dh_1536.pem 1536

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

    cd /etc/ssl
    sudo mkdir -p dhparams
    sudo wget -O dhparams/dh_2048.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group14.pem
    sudo wget -O dhparams/dh_3072.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group15.pem
    sudo wget -O dhparams/dh_4096.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group16.pem
    sudo wget -O dhparams/dh_6144.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group17.pem
    sudo wget -O dhparams/dh_8192.pem \
        https://git.bettercrypto.org/ach-master.git/blob_plain/HEAD:/tools/dhparams/group18.pem


