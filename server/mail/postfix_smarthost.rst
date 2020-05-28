Mail Domains and TLS
====================

Policy Options
--------------

none - No TLS
^^^^^^^^^^^^^

Mail delivery over unencrypted connections.


may - Opportunistic TLS
^^^^^^^^^^^^^^^^^^^^^^^

The SMTP transaction is encrypted if the STARTTLS ESMTP feature is supported by
the server. Otherwise, messages are sent in the clear. Certificates are not
checked.


encrypt - Mandatory TLS encryption
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The SMTP transaction is aborted unless the STARTTLS ESMTP feature is supported
by the remote SMTP server. If no suitable servers are found, the message will be
deferred. Certificates are not checked.

At this security level and higher, the :file:`smtp_tls_mandatory_protocols` and
:file:`smtp_tls_mandatory_ciphers` configuration parameters determine the list
of sufficiently secure SSL protocol versions and the minimum cipher strength.


dane - Opportunistic DANE TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If a remote SMTP server has "usable" DANE TLSA records, the server connection
will be authenticated. When DANE authentication fails, there is no fallback to
unauthenticated or plaintext delivery.

If the remote server has "unusable" DANE TLSA records, the Postfix SMTP client
will fallback to mandatory unauthenticated TLS (encrypt).


dane-only - Mandatory DANE TLS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

If "usable" TLSA records are present these are used to authenticate the remote
SMTP server. Otherwise, or when server certificate verification fails, delivery
via the server in question fails and will be retried later.


fingerprint - Certificate fingerprint verification
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

At the fingerprint security level, no trusted Certification Authorities are used
or required. The certificate trust chain, expiration date, etc., are not
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

DNS forgery resistant server certificate verification. Not sure, but they way I
understand it, the certificates SubjectAltName or CN must match with the server
name, as configured in a local :file:`transport_map` or :file:`tls_policy_map`.
In this case there is no need for a (potentially insecure) DNS query to obtain
server names by MX records.


TLS Policies Map
----------------


======================= =============== ===============
Domain                  Provider        Policy
======================= =============== ===============
_default                _               dane
digitalocean.com        Google          verify
gmail.com               Google          verify
gmx.at                  1&1             dane-only
gmx.ch                  1&1             dane-only
gmx.de                  1&1             dane-only
hotmail.ch              Microsoft       encrypt
hotmail.com             Microsoft       encrypt
lede-project.org        lede-project    verify
lists.torproject.org    torproject.org  dane-only
nongnu.org              Gnu             verify
nzz.ch                  Microsoft       verify
torproject.org          torproject.org  dane-only
web.de                  1&1             dane-only
======================= =============== ===============


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
