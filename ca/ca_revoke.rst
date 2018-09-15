Revoke Certificates
===================

If for any reason a certificate should or can no longer be used, the CA has to
revoke it. This is done with the `openssl ca` command by using the `-revoke`
option.

Change directory and configuration for OpenSSL to the Intermediate CA::

    $ cd ~/Projects/example.net.ca/intermed-ca
    $ export OPENSSL_CONF=./intermed-ca.cnf

Let's say we have to revoke the server certificate of the `www.example.net`
host. Find out the serial number of the certficate to revoke::

    $ grep www.example.net intermed-ca.index
    V   180302161635Z       A02B03A88F573AF4F24BA27246135142    unknown /CN=www.example.net

The serial number is the long string in the third column. To revoke this
particular certificate we use the serial number as filename from the
:file:`newcerts/` directory::

    $ openssl ca \
        -revoke ./certs/www.example.net.crt
        -crl_reason superseded
        Using configuration from ./intermed-ca.cnf
        Enter pass phrase for ./private/intermed-ca.key: ********
        Revoking Certificate A02B03A88F573AF4F24BA27246135142.
        Data Base Updated

While `crl_reason` can be any of the following:

 * `unspecified`
 * `keyCompromise`
 * `CACompromise`
 * `affiliationChanged`
 * `superseded`
 * `cessationOfOperation`
 * `certificateHold`
 * `removeFromCRL`

Now if we look at the issued certificates datafile again::

    $ grep www.example.net intermed-ca.index
    R   180302164304Z   160302164926Z,certificateHold   A02B03A88F573AF4F24BA27246135142    unknown /CN=www.example.net


Refresh the Certificate Revocation List (CRL) every time after revoking a certificate::

    $ openssl ca -gencrl -out crl/intermed-ca.crl
    Enter pass phrase for ./private/intermed-ca.key: ********


Publish the fresh CRL to the CA website::

    $ scp crl/intermed-ca.crl ssh://ca.example.net/var/www/public_html/crl/

