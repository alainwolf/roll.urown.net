GnuPG Web Key Service
=====================

Web Key Directory (WKD) and Web Key Service (WKS) provide easier ways to
discover OpenPGP public keys through HTTPS. They improve the user experience
for exchanging secure emails and files.

In contrast to the public keyservers a WKD or WKS do not publish mail
addresses. And they are authoritative public key sources for its domain.

In this document we set up a Web Key Service (WKS).


Prerequisites
-------------

 #. GnuPG version 2.1.15 or later (Ubuntu 18.04 LTS bionic comes with GnuPG
    2.2.4).

 #. Working :doc:`mail/index` installation.

 #. Working :doc:`nginx/index` installation.


System Service User
-------------------

Create a system user who will own the directories and files and run the Web
Key Service programs::

    $ sudo adduser --system --group --home /var/lib/webkey webkey


Directories and Domains
-----------------------

The Web Key Service requires a working directory to store keys pending for
publication. As root create a working directory::

    $ mkdir -p /var/lib/gnupg/wks
    $ chown webkey:webkey /var/lib/gnupg/wks
    $ chmod 2750 /var/lib/gnupg/wks


Then under your webkey account create directories for all your domains. Here we
do it for “example.net”, "example.org" and "example.com"::

    $ mkdir -p /var/lib/gnupg/wks/{example.net example.org example.com}


.. note::

    Apparently the location of the service working directory is hard-coded and
    can't be changed.


The WKS command :file:`--list-domains` can then take care of creating required
subdirectories and setting appropriate permissions::

    $ gpg-wks-server --list-domains


Submission Mail Address
-----------------------

The WKS clients (users mail clients), interact with the service by email. If a
new key has to be submitted, the client looks up the mail address of the
submission service at a well-known URL under the users domain domain.

The submission address is expected to be a downloadable text file with only one
line containing the mail address where new keys can be submitted.

To create these downloadable files::

    $ cd /var/lib/gnupg/wks/
    $ echo 'key-submission@example.net' > example.net/submission-address
    $ echo 'key-submission@example.org' > example.org/submission-address
    $ echo 'key-submission@example.com' > example.com/submission-address


The mail server need to forward all incoming mails on these addresses, to the
**webkey** mail account.

This is done in the :doc:`mail/postfix-mta` configuration trough alias
addresses.

.. literalinclude:: /server/config-files/etc/aliases
    :language: bash


The contents of the file are cached in the database
:file:`/etc/postfix/aliases.db`. Because of that the database must be refreshed
after each and every change made in :file:`/etc/postfix/aliases.map`::

    $ cd /etc/postfix
    $ sudo make


Submission Keys
---------------

Mails sent to the service should be encrypted. The Submission mail addresses
therefore need OpenPGP keys.

These keys are not passphrase-protected, as the will be used by an automated
service.

They should be created as the **webkey** user::

    $ sudo -H -u webkey \
        gpg --batch --passphrase '' --quick-gen-key key-submission@example.net
    $ sudo -H -u webkey \
        gpg --batch --passphrase '' --quick-gen-key key-submission@example.org
    $ sudo -H -u webkey \
        gpg --batch --passphrase '' --quick-gen-key key-submission@example.com


These keys will be the first to be published by our WKS. In WKS keys are
identified by a hash, so no mail addresses or key IDs are transferred
between WKS client and servers.

To create these hashes from a key uid, :file:`gpg` provides the
:file:`--with-wkd-hash` parameter::

    $ sudo -H -u webkey \
        gpg --with-wkd-hash -K key-submission@example.net
    sec   rsa2048 2020-06-28 [SC]
          C0FCF8642D830C53246211400346653590B3795B
    uid           [ultimate] key-submission@example.net
                  54f6ry7x1qqtpor16txw5gdmdbbh6a73@example.net
    ssb   rsa2048 2020-06-28 [E]


Take the hash of the string “key-submission”, which is
:file:`54f6ry7x1qqtpor16txw5gdmdbbh6a73` and manually publish that key::

    $ sudo -H -u webkey \
        gpg -o /var/lib/gnupg/wks/example.net/hu/54f6ry7x1qqtpor16txw5gdmdbbh6a73 \
            --export-options export-minimal --export key-submission@example.net
    $ sudo chmod +r /var/lib/gnupg/wks/example.net/u/54f6ry7x1qqtpor16txw5gdmdbbh6a73

Make sure that the created file is world readable.


References
----------

 * `Web Key Service at GnuPG <https://wiki.gnupg.org/WKS>`_


.. -*- mode: rst; tab-width: 4; indent-tabs-mode: nil -*-
