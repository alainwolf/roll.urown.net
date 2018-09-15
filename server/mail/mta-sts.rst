MTA-STS
=======

SMTP Mail Transfer Agent Strict Transport Security (:term:`MTA-STS`) is a
mechanism enabling mail service providers to declare their ability to receive
Transport Layer Security (:term:`TLS`) secure :term:`SMTP` connections, and to
specify whether sending SMTP servers should refuse to deliver to :term:`MX`
hosts that do not offer TLS with a trusted server certificate.

MTA-STS does not require the use of :term:`DNSSEC` to authenticate
:term:`DANE` :term:`TLSA` records but relies on the certificate authority (CA)
system and a trust-on-first-use (:term:`TOFU`) approach to avoid
interceptions.

The TOFU model allows a degree of security similar to that of :term:`HPKP`,
reducing the complexity but without the guarantees on first use offered by
DNSSEC.

In addition, MTA-STS introduces a mechanism for failure reporting and a
report-only mode, enabling progressive roll-out and auditing for compliance.


As of |today| it is still a draft.


DNS Entries
-----------

TLSRPT DNS TXT
^^^^^^^^^^^^^^

A number of protocols exist for establishing encrypted channels between
:term:`SMTP` Mail Transfer Agents, including :term:`STARTTLS`, :term:`DANE`
:term:`TLSA` and :term:`MTA-STS`.

These protocols can fail due to misconfiguration or active attack, leading to
undelivered messages or delivery over unencrypted or unauthenticated channels.

This DNS TXT entry informs any sending system to where it can send reports
with statistics and specific information about potential failures with the
recipient domain.

The recipient domain can then use this information to both detect potential
attacks and diagnose unintentional misconfigurations.

::

	_smtp._tls.example.net IN TXT v=TLSRPTv1; rua=mailto:postmaster@example.net.


Also add CNAME records for all other domains which use your mail servers as MX.

::

	_smtp._tls.example.org IN CNAME _smtp._tls.example.net.
	_smtp._tls.example.com IN CNAME _smtp._tls.example.net.


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

	pdnsutil add-record example.net _smtp._tls TXT "v=TLSRPTv1; rua=mailto:postmaster@example.net."
	pdnsutil add-record example.org _smtp._tls CNAME _smtp._tls.example.net
	pdnsutil add-record example.com _smtp._tls CNAME _smtp._tls.example.net


MTA-STS DNS TXT
^^^^^^^^^^^^^^^

The MTA-STS DNS TXT is used to declare that a policy is available to any mail
server who is asking.

::

	_mta-sts.example.net IN TXT v=STSv1; id=20160831085700Z


The "id" field serves as a reference for policy updates. 

Also add CNAME records for all other domains which use your mail servers as MX.

::

	_mta-sts.example.org IN CNAME _mta-sts.example.net.
	_mta-sts.example.com IN CNAME _mta-sts.example.net.


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

	pdnsutil add-record example.net _mta-sts TXT "v=STSv1; id=$(date --utc +%Y%m%d%H%M%SZ)"
	pdnsutil add-record example.org _smtp._tls CNAME _mta-sts.example.net
	pdnsutil add-record example.com _smtp._tls CNAME _mta-sts.example.net


MTA-STS Subdomain
^^^^^^^^^^^^^^^^^

The MTA-STS subdomain will serve the policy via HTTPS. As any web service it needs a DNS entry.

::

	mta-sts.example.net IN    A  192.0.2.40
	mta-sts.example.net IN AAAA  2001:db8::40


Also add CNAME records for all other domains which use your mail servers as MX.

::

	mta-sts.example.org IN CNAME mta-sts.example.net
	mta-sts.example.com IN CNAME mta-sts.example.net


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

	pdnsutil add-record example.net mta-sts A 192.0.2.40
	pdnsutil add-record example.net mta-sts AAAA 2001:db8::40
	pdnsutil add-record example.org mta-sts CNAME mta-sts.example.net
	pdnsutil add-record example.com mta-sts CNAME mta-sts.example.net



Web Server
----------


TLS Certificates
^^^^^^^^^^^^^^^^

We use :doc:`dehydrated </server/letsencrypt>` to request additional
certificates for the HTTPS policy server.

Add the following lines to :file:`/etc/dehydrated/domains.txt`

::

	...

	MTP MTA Strict Transport Security (MTA-STS)
	mta-sts.example.net mta-sts.example.org mta-sts.example.com

	...


Nginx Virtual Host
^^^^^^^^^^^^^^^^^^

Setup the virtual host in Nginx to deliver the policy over HTTPS.

Create a new virtual host :download:`/etc/nginx/sites-available/mta-sts.conf 
</server/config-files/etc/nginx/servers-available/mta-sts.example.net.conf>` 
for Nginx:

.. literalinclude:: /server/config-files/etc/nginx/servers-available/mta-sts.example.net.conf
	:linenos:
	:caption: mta-sts.example.net.conf
	:name: mta-sts.example.net.conf



Refrences
---------

 * https://datatracker.ietf.org/doc/draft-ietf-uta-mta-sts/
 * https://www.johndball.com/adding-smtp-tls-downgrade-prevention-using-mta-sts/
 * `MTA STS validator <https://aykevl.nl/apps/mta-sts/>`_