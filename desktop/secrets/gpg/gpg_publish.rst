Distributing OpenPGP Keys
=========================

As can be seen with the :file:`--auto-key-locate` configuration parameter of
there are various ways to find and import a key.


Key-Servers
-----------

.. note::

    In recent years, various problems with with key-servers and their
    federation model have been discovered. In terms of reliability,
    abuse-resistance, privacy, and usability, the use of key servers can no
    longer be recommended.

Notable keys servers include:

 * `keys.openpgp.org <https://keys.openpgp.org>`_

While public key servers are still the mostly widely used way to find OpenPGP
keys, but other methods come with significant benefits over the old key servers.


DNS CERT
--------

Publishing a key as OpenPGP packet using DNS CERT type 3 (PGP), as specified in
:RFC:`4398`.


PKA
---

Publishing a key as DNS CERT record type 6 (IPGP), as specified in :RFC:`4398`.
The record contains the fingerprint and/or the URL of an OpenPGP packet.

The :file:`gpg` command provides a way to output the required DNS records for a
key with the **export-pka** export option::

        $ gpg --export-options export-pka \
            --export-filter keep-uid="uid=~@example.net" \
            --export $GPGKEY

This outputs records in generic format as TYPE37 containing the fingerprint
without any URL.

Testing::

    $ env GNUPGHOME=$(mktemp -d) gpg --verbose --auto-key-locate clear,pka --locate-keys john.doe@example.net


DANE
----

The :RFC:`7929` titled "DNS-Based Authentication of Named Entities (DANE)
Bindings for OpenPGP" describes a mechanism to associate a user's OpenPGP
public key with their email address, using the OPENPGPKEY DNS RRtype.
These records are published in the DNS zone of the user's email
address.  If the user loses their private key, the OPENPGPKEY DNS
record can simply be updated or removed from the zone.

As with other DANE records like TLSA, the OPENPGPKEY data is supposed to be
secured by DNSSEC.

The :file:`gpg` command provides a way to output the required DNS records for a
key with the **export-dane** export option.

Since this will be published as DNS record, we want to export the smallest
possible key. We therefore also add the **export-minimal** export-option.

Additionally, most users have multiple user-ids (email addresses) in their key.
Probably not all of those domains provide write-access to their DNS records
(i.e. gmail.com). With the **keep-uid** export-filter, only the records for the
domain we actually are allowed to publish will be shown::

    $ gpg --export-options \
                export-minimal,export-dane \
        --export-filter keep-uid="uid=~@example.net" \
        --export $GPGKEY

This outputs records in generic format as TYPE61.

If you want standard OPENPGPKEY format records::

    $ export MY_USER=john MY_DOMAIN=example.net
    $ echo -e "$( echo -n "$MY_USER" | sha256sum | head --bytes=56 )._openpgpkey.${MY_DOMAIN}. IN OPENPGPKEY (\n $( gpg --export-options export-minimal --export-filter keep-uid="uid=~@${MAIL_DOMAIN}" --export $GPGKEY | hexdump -e '"\t" /1 "%.2x"' -e '/32 "\n"' )\n )"


There is also the online
`DNS OPENPGPKEY Record Generator <https://www.huque.com/bin/openpgpkey>`_ who
generates standard OPENPGPKEY records.

Testing::

    $ env GNUPGHOME=$(mktemp -d) gpg --verbose --auto-key-locate clear,dane --locate-keys john.doe@example.net


Web Key Directory (WKD)
-----------------------

`OpenPGP Web Key Directory <https://datatracker.ietf.org/doc/draft-koch-openpgp-webkey-service/>`_
or WKD is an Internet draft standard that allows discovering OpenPGP keys from
email addresses.

Whenever a modern OpenPGP application needs a public key which isn't found in
its keyring yet, it will automatically try to fetch it from well-known locations
on web-servers in the domain of the users mail address.

Let's say, you start to write an encrypted mail to :code:`John.Doe@example.net`
and don't have his public key, as you never wrote to him before. Your mail
client will try to download it from web-servers in the :code:`example.net`
domain.

It will first try:

    https://openpgpkey.example.net/.well-known/openpgpkey/example.org/hu/iy9q119eutrkn8s1mk4r39qejnbu3n5q?l=John.Doe

If that fails, it will try:

    https://example.net/.well-known/openpgpkey/hu/iy9q119eutrkn8s1mk4r39qejnbu3n5q?l=John.Doe

While :code:`iy9q119eutrkn8s1mk4r39qejnbu3n5q` is a hash of :code:`john.doe`.
It's hashed to protect John's mail address from mail address harvesters and
spammers.

Here is how you can create the necessary directories and files for your
website::

    $ MY_DOMAIN=example.net
    $ mkdir -p "/tmp/openpgpkey"
    $ gpg --list-options show-only-fpr-mbox --list-keys "$GPGKEY" \
        | grep "$MY_DOMAIN" \
        | /usr/lib/gnupg/gpg-wks-client -C "/tmp/openpgpkey" --install-key

The :file:`/tmp/openpgpkey` directory now contains a subdirectory named
:file:`example.net`. Inside it you find a :file:`policy` file and the :file:`hu`
subdirectory. The :file:`hu` directory contains your OpenPGP public key in a
file named after the hash of your mail-address::

    /tmp/openpgpkey/
    └── example.net
        ├── hu
        │   └── iy9q119eutrkn8s1mk4r39qejnbu3n5q
        └── policy



Upload the contents of :file:`/tmp/openpgpkey/example.net/` to your web-server,
so that it will be reachable as
:file:`https://example.net/.well-known/openpgpkey/`

For example::

    # Create necessary directories on the server, if they don't exist yet
    ssh $WEB_SERVER mkdir -p /var/www/${MY_DOMAIN}/public_html/.well-known/openpgpkey/hu

    # Copy subdirectory and files
    scp -r "${_temp_dir}/${MY_DOMAIN}/*" \
        ${WEB_SERVER}:/var/www/${MY_DOMAIN}/public_html/.well-known/openpgpkey/

    # Set ownership to make it available to website visitors
    ssh $WEB_SERVER chown -R www-data:www-data \
        /var/www/${MY_DOMAIN}/public_html/.well-known


The exact commands and locations need to be adapted to your web-hosting environment.

Testing::

    $ env GNUPGHOME=$(mktemp -d) gpg --verbose --auto-key-locate clear,wkd --locate-keys john.doe@example.net


There is also an online test page:

    https://metacode.biz/openpgp/web-key-directory


Keybase.io
----------

TBD.


QR-Code
-------

:file:`openpgp4fpr:` is a
`IANA registered URI scheme <https://www.iana.org/assignments/uri-schemes/prov/openpgp4fpr>`_
used to identify OpenPGP version 4 public keys.

Supporting client applications who encounter an :file:`openpgp4fpr:` URI, can
process the contained information as OpenPGP fingerprint.

By creating and distributing a QR code who's content starts with the text
:code:`OPENPGP4FPR:` followed by your fingerprint, you can tell other people
which OpenPGP key you are using. Make sure all letters are in uppercase.

Print the QR-code on business-cards and letterheads, or add it online to your
website and social network profiles.

Other people can then scan the QR-code with their smartphone or webcam, without
the need of exchanging, verifying and typing-in long rows of numbers and
letters.

This is especially useful, when printed on business-cards, which you hand out
personally to people, without any third-parties or online-devices involved.
Maybe in combination with other proof of identity like ID-card, drivers-licence
or passport.

To create such a QR-code on the command-line::

    $ qrencode -o "${HOME}/Pictures/${GPGKEY}.png" -i \
        "OPENPGP4FPR:$( gpg --with-colons --fingerprint "$GPGKEY" \
            | grep -m 1 "^fpr" \
            | egrep -o "[0-9A-F]{40}" \
        )"
    $ xdg-open "${HOME}/Pictures/${GPGKEY}.png"


You can create QR-codes online with the
`QR Code Generator from the ZXing Project <https://zxing.appspot.com/generator/>`_
and many others.


Publish on Websites
-------------------

:RFC:`3156` describes how ASCII-armored OpenPGP keys, alongside encrypted data
and signatures are to presented to clients.


ASCI Armored
^^^^^^^^^^^^

To publish an ASCII armored PGP public key on a website, first we export the key
to a file named with a :file:`aexpk` (PGP Armored EXtracted Public Key)
file-extension::

    $ gpg --armor --export "$GPGKEY" >"${GPGKEY}.aexpk"


Upload it to your website and create a link with the MIME-type
:file:`application/pgp-keys` on the page from where visitors can download it as
follows:

.. code-block:: html

    <html>
    ...
        Download my (ASCII armored) PGP public key:
        <a href="0x0123456789ABCDEF.aexpk"
            title="Jon Doe's PGP Public Key"
            type="application/pgp-keys">
            0x0123456789ABCDEF
        </a>
    ...
    </html>


Binary
^^^^^^

To publish a binary public key file, export it without the :file:`--armor`
option and name it with a :file:`bexpk` (PGP Binary EXtracted Public Key)
file-extension::

    $ gpg --export "$GPGKEY" >"${GPGKEY}.bexpk"


Links to binary files should have the :file:`application/octet-stream`
MIME-type:

.. code-block:: html

    <html>
    ...
        Download my (binary) PGP public key:
        <a href="0x0123456789ABCDEF.bexpk"
            title="Jon Doe's PGP Public Key"
            type="application/octet-stream">
            0x0123456789ABCDEF
        </a>
    ...
    </html>


You may need to add these MIME types to your web-server. For Nginx insert the
following lines in to the file :file:`/etc/nginx/mime.types`:

.. code-block:: ini

    # OpenPGP MIME types (RFC-3156)
    application/octet-stream              bex bexpk;
    application/octet-stream              pgp;
    application/pgp-keys                  aex aexpk;
    application/pgp-signature             asc sig;


Testing
^^^^^^^

::

    $ env GNUPGHOME=$(mktemp -d) gpg --verbose --fetch-key https://example.net/0x0123456789ABCDEF.bexpk
