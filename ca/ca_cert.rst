Signing Certificates
====================

::
    
    $ export OPENSSL_CONF=./openssl.cnf
    $ openssl ca \
        -config ./openssl.cnf \
        -extensions certExt_user \
        -policy policy_user \
        -out ./john.doe@k18.ch.cert.pem \
        -infiles ./certreqs/john.doe@k18.ch.req.pem

