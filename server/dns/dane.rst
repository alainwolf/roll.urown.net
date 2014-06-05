DANE - DNS-based Authentication of Named Entities
=================================================

Now that the information provided by our DNS servers is digitally signed and
therefore can be trustetd, we can use our DNS servers to publish additional
authenticated and verifieable informamtion.

.. note::

	Note that DNSSEC and therefore also DANE are implemented very very slowly.
	As of May 2014 not even all :abbr:`TLD (Top Level Domains)`s are ready for
	DNSSEC. Less then 10% of the internet domains have implemented DNSEC and
	secured their records. The same is the case for clients. No major browser,
	mail- client or messaging application supports anything DNSSEC related out
	of the box.


Hash-Slinger
------------

As with all things DNS and TLS and certainly the combination of them, things get
overly complicated quickly.

Therefore we install the little helper program called  `hash-slinger
<http://www.internetsociety.org/deploy360/resources/hashslinger-a-tool-for-
creating-tlsa-records-for-dane/>`_. For its operation, the trusted root key of
the top-level DNS root must be available, to correctly check all signatire along
the way. The tool unbound-anchor just does that.

They are both in the Ubuntu Software Repository::

	$ sudo apt-get install unbound-anchor hash-slinger
	$ sudo unbound-anchor
	$ sudo wget -O /etc/unbound/dlv.isc.org.key \
			http://ftp.isc.org/www/dlv/dlv.isc.org.key

Once installed the new commands :manpage:`tlsa`, :manpage:`openpgpkey` and
:manpage:`sshfp` are available.


TLSA
----
Using :abbr:`TLSA (Transport Layer Security Authentication)` records in DNS we
can provide information  about a server certificate. A connecting client can
query DNS to verify the certificate the server hs presented, without the need of
a third-party, like the various commercial certificate authorities.

The TLSA entry in DNS consists of a service name and a unique identifiable
information of the server certificate (a hash).

To create such a DNS :abbr:`RR (Resource Record)` for our webserver
*example.com*::

	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem example.com
	_443._tcp.example.com. IN TLSA 3 0 1 f8df4b2edd791edc98fa856a0ee8a5d4a1387d5a6bef8be7cdfea74e76a2a0e5


A line will displayed which can be used with cut and paste in zone files.

If you use PowerDNS server with the poweradmin web interface, add records as
follows:

.. warning::

	Note that the TLSA command above displays a point "." at the end of "_443._tcp.example.com".
	DO NOT include the point when using the webinterface!

===================== ==== ======================================================================
Name                  Type Content                                                               
===================== ==== ======================================================================
_443._tcp.example.com TLSA 3 0 1 f8df4b2edd791edc98fa856a0ee8a5d4a1387d5a6bef8be7cdfea74e76a2a0e5
===================== ==== ======================================================================

.. note::
	
	The fields **Priority** and **TTL** can be left empty.

Repeat the above for every webserver in your DNS who answers on TLS port 443::

	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem www.example.com
	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem cloud.example.com

For creating records of other non-web types of servers, the port number has to be added to TLSA command.

For a XMPP server::

	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem --port 5269 xmpp.example.com
	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem --port 5222 xmpp.example.com

for a mail server::

	$ tlsa --create --certificate /etc/ssl/certs/example.com.cert.pem --port 25 mail.example.com
