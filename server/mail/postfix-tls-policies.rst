Encrypted Mail Transport
========================

.. contents:: \

In a ideal world, all mail messages would be encrypted end-to-end and only the
intended receiver is able to read it.

In the real world this is almost never the case. Altough email encryption
standards like OpenPGP and S/MIME exist since decades, they are almost never
used. We have no other choice then to accept the fact, that they will be
stored unecnrpyted on the personal devices of senders and recipients, but also
on the mail-servers where they have their accounts, and possibly, all servers
they have been sent trough.

The least we can do is trying hard to encrypt the connections, while mail is
sent from one system to another. Nowadays most, if not all, mail-providers
require proper authentication over encrypted connections from their users.
While the reason for this mostly came out of the need to protect against spam,
we can safely assume, that mails between users and their severs are always
transported over encrypted connections.

TLS encryption is not mandatory between SMTP servers, since it based on old
standards, which cannot be changed, without mail delivery to fail on a
catastrophic global scale.

Most SMTP servers today support TLS encryption trough the STARTTLS command
which allows to upgrade an unencrypted connection to an encrypted one, even
after the connection is already made.

But the global mail-server landscape still contains servers without any
encryption at all, many use outdated insecure encryption stadards, a lot uses
self-signed certificates. As mail service provider, you have no choice, but to
support these as well, or else you and your users won't be able to exchange
mail with any of them.

With the orginal SMTP standards you can't predict what security and encryption
policies other domains have implemented.

With TLS policies a mail system administrator can define security and
encryption settings, at least with domains and servers who's policies are
somwhow known.

There are different ways to know about the encryption policies or capabilites
of domains you exchange mail with:

* DNS-based Authentication of Named Entities (:term:`DANE`)
* MTA Strict Transport Security (:term:`MTA-STS`)
* By analyzing mail-server logs
* Personal knowledge and expirience

This information can then be translated into Postfix own TLS policy. A Postfix
TLS policy can have the following options, which define how to connect and
communicate with another mail server.

Policy Options
--------------

Postfix SMTP Client TLS Security Levels
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Outgoing Mail is sent by the Postfix SMTP client. Following are the TLS policy
options the SMTP client understands:

.. list-table::
   :header-rows: 0
   :widths: 1 2
   :stub-columns: 1

   * - none
     - No TLS encryption
   * - may
     - Opportunistic TLS.
   * - encrypt
     - Mandatory TLS
   * - dane
     - Opportunistic DANE TLS
   * - dane-only
     - Mandatory DANE TLS
   * - fingerprint
     - Certificate fingerprint verification
   * - verify
     - Mandatory server certificate verification
   * - secure
     - Secure-channel TLS.


none - No TLS
^^^^^^^^^^^^^

Mails are always sent over unencrypted connections.


may - Opportunistic TLS
^^^^^^^^^^^^^^^^^^^^^^^

Mails are sent over encrypted connections, if the remote SMTP server announces
its capability to do so, with the :term:`STARTTLS` :term:`ESMTP` feature.

Otherwise, messages are sent in the clear.

Certificates are NOT checked.

The allowed TLS protocol versions, cipher suites and the minimum cipher
strengths are set by the :file:`smtp_tls_protocols` and
:file:`smtp_tls_ciphers` configuration parameters. .


encrypt - Mandatory TLS encryption
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SMTP transaction is aborted unless the STARTTLS ESMTP feature is supported
by the remote SMTP server. If no suitable servers are found, the message will
be deferred (tried again later).

Certificates are NOT checked.

At this security level and higher, the :file:`smtp_tls_mandatory_protocols`
and :file:`smtp_tls_mandatory_ciphers` configuration parameters determine the
TLS protocol versions, cipher suites and the minimum cipher strengths allowed.


dane - Opportunistic DANE TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If a remote SMTP server has published "usable" DANE TLSA records, the remote
SMTP server connection will be encrypted and its certficates are checked
against the servers published TLSA records.

DANE TLSA records must have been published in a DNSSEC secured domain, they
will be ignored otherwise.

If the remote server has published DANE TLSA records, but Postfix fails to
understand or use them, it will fall back to `encrypt` level. Thus it will
still insist on an encrypted TLS connection with the remote server, but will
not check the remote servers certificate.

If the remote server has not published any DANE TLSA records, it will fallback
to security level `may`. An secure connection will be attempted, without
certificate validation. If no secure connection is possible, mails are sent
unecnrpyted.


dane-only - Mandatory DANE TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If "usable" DANE TLSA records have been found in a DNSSEC secured domain these
are used to authenticate the remote SMTP servers certficates and mails are
subsequently sent over the encrypted and verfied connection.

When server certificate verification fails or no encrpyted connection is
possible, the delivery via that server fails and might be retried later.


fingerprint - Certificate fingerprint verification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At the fingerprint security level, no trusted Certification Authorities are
used or required. The certificate trust chain, expiration date, etc., are not
checked. Instead, the smtp_tls_fingerprint_cert_match parameter or the "match"
attribute in the policy table lists the remote SMTP server certificate
fingerprint or public key fingerprint.


verify - Mandatory server certificate verification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Server certificate is valid (not expired or revoked, and signed by a trusted
Certification Authority) and the server certificate name (CN or SubjectAltName)
matches the servers hostname as obtained by DNS MX records or other means (e.g.
:file:`transport_map`).


secure - Secure-channel TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Also described as "DNS forgery resistant server certificate verification".

The certificates SubjectAltName or CN must match with the server name, as
configured in a postfix :file:`transport_map` or :file:`tls_policy_map`.

If mail is to be delivered to a domain, which is not secured by DNSSEC, any
upstream DNS reoslver could serve you fake MX records of mail-servers for that
domain. Postfix would contact that server, the server would advertise its
encryption capability and present a certificate, which indeed would
successfully verify against a known and trusted certificate authority. But the
mails would still be delivered to a bad server, because, despite the fact that
it has a valid certificate, there is no proof that it is indeed the right
server to receive mails for that domain.

This is because you can't really trust DNS records, unless the domain is
secured with DNSSEC.

In this case there is no need for a (potentially insecure) DNS query to obtain
server names by MX records.

The `secure` Postfix TLS security level can protect a sending postix server to
be fooled like that, by defining specific SubjectAltName or CN ntries to be
matched against the remote servers certificate, regardless what server
hostname the MX DNS lookup did return.


Default TLS Policies and Maps
-----------------------------

So how all the above options should be implemented on our sending mail servers?

The default policy used against all receiving remote servers is set by the
`smtp_tls_security_level` configuration setting in the
:file:`/etc/postfix/main.cfg` configuration file.


MTA Server Default SMTP Client TLS Policy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For our MTA server, which sends all outgoing mail to our own trusted MX
servers:

::

    # What TLS encryption and verifications are required for outgoing SMTP connections?
    # Possible values:
    # 'none', 'may', 'encrypt', 'dane', 'dane-only', 'fingerprint', 'verify' or 'secure'.
    smtp_tls_security_level = dane-only

Since we publish DANE TLSA records ourselfs for all our mail servers, we can
rely on those for our internal servers mail transport too. `dane-only` will
give us DNSSEC secured DNS reocrds, manadatory encryption and verfied
certficates on all server-to-server communicatations.


MX Server Default SMTP Client TLS Policy
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

For our MX servers, which performs DNS MX record lookups to send out mails to
any domains on possibly unknown servers:

::

    # What TLS encryption and verifications are required for outgoing SMTP connections?
    # Possible values:
    # 'none', 'may', 'encrypt', 'dane', 'dane-only', 'fingerprint', 'verify' or 'secure'.
    smtp_tls_security_level = dane


TLS Policy Maps
^^^^^^^^^^^^^^^

With TLS policy maps, we can further secure mail transmission, with other
domains, not publishing DANE records.

If they have published information about their encrpytion capabilites
themselfes using :term:`MTA-STS` we can use the **postfix-mta-sts-resolver**
described in :doc:`mta-sts`. It gathers this information from domains we send
mail to, transforms and caches it as Postifx TLS policy rules, caches them and
feeds them to our Postfix servers.

The mayority of domains support TLS encryption, but don't publish anything
about it. We can still ensure a huge part of our mail traffic gets mandatory
encrpytion, if we manually add domains to a custom TLS policy map.

We use our MariaDB SQL database for this, so as with our hosted mail domains
and mailboxes, its available on all mail servers trough database replication:

::

    mysql vimbadmin

    CREATE TABLE `tlspolicies` (
    `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
    `domain` varchar(255) NOT NULL,
    `policy` enum('none','may','encrypt','dane','dane-only','fingerprint','verify','secure')
        NOT NULL,
    `params` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `domain` (`domain`)
    ) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1

Once the table has been created we can start adding records.

But what information do we need (in order of preference):

* Does the domain have valid DANE records? No manual policy needed, but you
  could restrict it further by setting a policy to **dane-only**.
* Does the domain have valid MTA-STS records? No manual policy needed, our
  *postfix-mta-sts-resolver* will handle it.
* If the domain neither publishes DANE nor MTA-STS records, you have to look
  at their MX records:

  * Is mail for the domain hosted/provided by Google? You can define a
    **secure** TLS policy with the parameter **match=mx.google.com**.
  * Is mail for the domain hosted/provided by Microsoft? You can define a
    **secure** TLS policy with the parameter
    **match=mail.protection.outlook.com**.
  * There might be other larger mail providers, wich sinilar common MX server
    certificates.
  * If the domain is providing their mail service on their own, you can inspect
    their MX servers certificate.

There are several online tools which can help gather this information:

* https://internet.nl/mail/
* https://ssl-tools.net/mailservers
* https://ssl-tools.net/providers
* https://www.checktls.com/TestReceiver

.. list-table::
   :header-rows: 1

   * - Domain
     - Provider
     - Published
     - TLS Policy
     - Parameter
   * - *_default*
     - *any/unknown*
     - *unknown*
     - dane
     - *none*
   * - github.com
     - Google
     - *none*
     - secure
     - match=mx.google.com
   * - mgb.ch
     - Microsoft
     - *none*
     - secure
     - match=mail.protection.outlook.com
   * - torproject.org
     - *self*
     - DANE
     - dane-only
     - *none*
   * - openwrt.org
     - *self*
     - MTA-STS
     - *none*
     - *none*




==================== ============== =============== ===========
Domain               Provider       Policy          Parameters
==================== ============== =============== ===========
_default             _              dane
digitalocean.com     Google         verify          match=mx.google.com
gmail.com            Google         none/automatic
gmx.at               1&1            dane-only
gmx.ch               1&1            dane-only
gmx.de               1&1            dane-only
hotmail.ch           Microsoft      encrypt
hotmail.com          Microsoft      encrypt
lede-project.org     lede-project   verify
lists.torproject.org torproject.org dane-only
nongnu.org           Gnu            verify
nzz.ch               Microsoft      verify
torproject.org       torproject.org dane-only
web.de               1&1            dane-only
==================== ============== =============== ===========



Provider Templates
------------------

"secure" policies for often used providers may be defined to be used as kind of
templates.

This can be achieved by combining the two postfix lookup tables "transport maps"
(see `tranport(5) <http://www.postfix.org/transport.5.html>`_) with `TLS policy
maps <http://www.postfix.org/postconf.5.html#smtp_tls_policy_maps>`_.

Google
^^^^^^

In file :file:`/etc/postfix/main.cf`::

    transport_maps = hash:/etc/postfix/transport
    smtp_tls_policy_maps = hash:/etc/postfix/tls_policy


In file :file:`/etc/postfix/transport`::

    gmail.com       smtp:[64.233.166.26]
    gmail.com       smtp:[173.194.221.26]
    gmail.com       smtp:[74.125.68.26]
    gmail.com       smtp:[64.233.188.27]
    gmail.com       smtp:[74.125.28.27]

    veloplus.ch     smtp:[66.102.1.27]

    example.co.uk   smtp:[tls.example.com]
    example.co.jp   smtp:[tls.example.com]


In file :file:`/etc/postfix/tls_policy`::

    gmail.com   secure match=mx.google.com
    veloplus.ch secure match=mx.google.com


    # gmail-smtp-in.l.google.com.
    [64.233.166.26]     secure match=mx.google.com

    # alt1.gmail-smtp-in.l.google.com.
    [173.194.221.26]    secure match=mx.google.com

    # alt2.gmail-smtp-in.l.google.com.
    [74.125.68.26]      secure match=mx.google.com

    # alt3.gmail-smtp-in.l.google.com
    [64.233.188.27]     secure match=mx.google.com

    # alt4.gmail-smtp-in.l.google.com.
    [74.125.28.27]      secure match=mx.google.com

    # aspmx.l.google.com
    [66.102.1.27]       secure match=mx.google.com

    # alt1.aspmx.l.google.com.
    [173.194.221.26]    secure match=mx.google.com

    # alt2.aspmx.l.google.com.
    [74.125.68.27]      secure match=mx.google.com

    # aspmx2.googlemail.com.
    [173.194.221.27]    secure match=mx.google.com

    # aspmx3.googlemail.com.
    [74.125.68.27]      secure match=mx.google.com


Microsoft


Hostpoint
^^^^^^^^^

In file :file:`/etc/postfix/tls_policy`::

    # mx1.mail.hostpoint.ch.
    [217.26.49.138]     secure match=*.mail.hostpoint.ch

    # mx2.mail.hostpoint.ch.
    [217.26.49.139]     secure match=*.mail.hostpoint.ch

    # mx.hostpoint.ch.
    [217.26.48.124]

    # antargus.adm.hostpoint.ch.
    [54.229.223.246]
