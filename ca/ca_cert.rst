Signing Certificates
====================

Change to the intermediate CA working directory and activate its OpenSSL
configuration::

    $ cd ~/Projects/example.net.ca/intermed-ca
    $ export OPENSSL_CONF=./intermed-ca.cnf

Store the received certificate signing request (CSR) in the appropriate
directory::

    $ mv ~/Downloads/www.example.net.req.pem ./certreqs/


Sign a Server Certificate Request
---------------------------------

Sign the server CSR with the intermediate key for the next 2 years using the
server extensions::

    $ openssl rand -hex 16 > intermed-ca.serial
    $ openssl ca \
        -in ./certreqs/www.example.net.req.pem \
        -out ./certs/www.example.net.cert.pem \
        -extensions server_ext
    Using configuration from ./intermed-ca.cnf
    Enter pass phrase for ./private/intermed-ca.key: ********


The details are shown::

    Check that the request matches the signature
    Signature ok
    Certificate Details:
            Serial Number:
            a0:2b:03:a8:8f:57:3a:f4:f2:4b:a2:72:46:13:51:42
            Validity
                Not Before: Mar  2 17:31:03 2016 GMT
                Not After : Mar  2 17:31:03 2018 GMT
            Subject:
                commonName                = www.example.net
            X509v3 extensions:
                X509v3 Basic Constraints:
                    CA:FALSE
                X509v3 Key Usage: critical
                    Digital Signature, Key Encipherment
                X509v3 Extended Key Usage: critical
                    TLS Web Server Authentication, TLS Web Client Authentication
                X509v3 Subject Key Identifier:
                    9F:2E:CE:B0:E0:EB:E7:54:94:93:AC:4C:5D:70:5A:C6:A4:A3:FB:69
                X509v3 Authority Key Identifier:
                    keyid:C5:B7:03:F2:2F:F1:66:A5:07:C3:B2:3D:B6:A8:B5:B0:B4:71:B1:E4

                X509v3 Issuer Alternative Name:
                    URI:http://ca.example.net/, email:certmaster@example.net
                Authority Information Access:
                    CA Issuers - URI:http://ca.example.net/certs/intermed-ca.cert.pem

                X509v3 CRL Distribution Points:

                    Full Name:
                      URI:http://ca.example.net/crl/intermed-ca.crl

                X509v3 Subject Alternative Name:
                    email:webmaster@example.net, DNS:www.example.net,*.example.net
    Certificate is to be certified until Mar  2 17:31:03 2018 GMT (730 days)
    Sign the certificate? [y/n]:


Sign a Client Device Certificate Request
----------------------------------------

Sign the server CSR with the intermediate key for the next 2 years using the
client extensions::

    $ openssl rand -hex 16 > intermed-ca.serial
    $ openssl ca \
        -in ./certreqs/phone.example.net.req.pem \
        -out ./certs/phone.example.net.cert.pem \
        -extensions client_ext


Sign a Personal Certificate Request
-----------------------------------

Sign the server CSR with the intermediate key for the next 2 years using the
personal extensions::

    $ openssl rand -hex 16 > intermed-ca.serial
    $ openssl ca \
        -in ./certreqs/john.doe@example.net.req.pem \
        -out ./certs/john.doe@example.net.cert.pem \
        -extensions user_ext
