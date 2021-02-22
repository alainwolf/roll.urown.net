Mail Client Auto-Configuration
==============================

Some mail clients can retrieve their configuration for a mail address
automatically, trough a combination of DNS and HTTP queries leading to
configuration data provided as XML on a webserver.


Mozilla Thunderbird
-------------------

Evolution and KMail have adopted this format too.

The process is desribed at the `Autoconfiguration in Thunderbird
<https://developer.mozilla.org/en-US/docs/Mozilla/Thunderbird/Autoconfiguration>`_
page in the MDN (Mozilla Developers Network).

#. The client tries to access the following URLs in the preferred order:

   #. https://autoconfig.example.net/mail/config-v1.1.xml
   #. https://example.net/.well-known/autoconfig/mail/config-v1.1.xml


#. If successful, the XML data received on that URL will be used as
   configuration hints.


DNS Records
^^^^^^^^^^^

Add the following CNAME record to every domain you are provding mail services
for:

.. code-block:: text

    @example.org
    autoconfig  IN  CNAME autoconfig.example.net

    @example.com
    autoconfig  IN  CNAME autoconfig.example.net


.. code-block:: text

    @example.net
    autoconfig  IN      A 10.195.171.241
    autoconfig  IN   AAAA 2001:db8:3414:6b1d::10


TLS Certificates
^^^^^^^^^^^^^^^^

Since the webserver provding the auto-configuration data, will be accessed under
the hosted domain name, it needs valid certificates for every hosted domain.

In a :doc:`dehydrated domains.txt </server/dehydrated>` configuration file,
this should looks as follows:

.. code-block:: text

    # ------------------------------------------------------------
    # Mozilla Mail Client Autoconfiguration
    # ------------------------------------------------------------
    autoconfig.example.net autoconfig.example.org autoconfig.example.com > autoconfig


Nginx Server
^^^^^^^^^^^^

The Nginx server configuration :file:`/etc/nginx/servers-available/autconfig.conf`:

.. literalinclude:: /server/config-files/etc/nginx/servers-available/autoconfig.conf
    :language: nginx



XML Client Configuration Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The XML file structure and syntax is described in the
`Mozilla Wiki <https://wiki.mozilla.org/Thunderbird:Autoconfiguration:ConfigFileFormat>`_.


Provider information and domains:

.. literalinclude:: config-v1.1.xml
    :language: xml
    :lines: -15
    :linenos:

.. literalinclude:: config-v1.1.xml
    :language: xml
    :lines: 73-
    :linenos:
    :lineno-start: 73

Servers for incoming mail:

.. literalinclude:: config-v1.1.xml
    :language: xml
    :lines: 15-54
    :linenos:
    :lineno-start: 15


Servers for outgoing mail:

.. literalinclude:: config-v1.1.xml
    :language: xml
    :lines: 55-72
    :linenos:
    :lineno-start: 55


Place the XML file in the designated location at
:file:`/var/www/example.net/autoconfig/mail/config-v1.1.xml`


Microsoft Clients
-----------------

Microsoft mail clients like Outlook, Outlook Express or Office 365.

DNS Records
^^^^^^^^^^^

These clients forst look up a DNS service record, to locate any available
web-server who might have configuration data in store for the users mail domain:

.. code-block:: text

    _autodiscover._tcp SRV 10 10 443 autodiscover.example.net


.. code-block:: text

    autodiscover.example.org CNAME autodiscover.example.net


.. code-block:: text

    @example.net
    autodiscover  IN   A    10.195.171.241
    autodiscover  IN   AAAA 2001:db8:3414:6b1d::10


TLS Certificates
^^^^^^^^^^^^^^^^

Since the webserver provding the auto-configuration data, will be accessed under
the hosted domain name, it needs valid certificates for every hosted domain.

In a :doc:`dehydrated domains.txt </server/dehydrated>` configuration file,
this should looks as follows:

.. code-block:: text

    # ------------------------------------------------------------
    # Microsoft Mail Client Auto-Discovery
    # ------------------------------------------------------------
    autodiscover.example.net autodiscover.example.org autodiscover.example.com > autodiscover



Nginx Server
^^^^^^^^^^^^

The Nginx server configuration :file:`/etc/nginx/servers-available/autodiscover.conf`:

.. literalinclude:: /server/config-files/etc/nginx/servers-available/autodiscover.conf
    :language: nginx


XML Client Configuration Data
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Provider information and domains:

.. literalinclude:: Autodiscover.xml
    :language: xml
    :lines: 1-
    :linenos:
    :lineno-start: 1


Apple Mail
----------


Android K-9 Mail
----------------




Other Mail Clients
------------------


DNS SRV Records
^^^^^^^^^^^^^^^

In theory a method exists to specify servers hostnames and ports for a
particular service to use:

.. code-block:: text

    _imap._tcp.	        IN	SRV	10 10 143 mail.example.net.
    _imaps._tcp.        IN	SRV	10 10 993 mail.example.net.
    _pop3._tcp.	        IN	SRV	10 10 110 mail.example.net.
    _pop3s._tcp.        IN	SRV	10 10 995 mail.example.net.
    _smtps._tcp.        IN	SRV	10 10 465 mail.example.net.
    _submission._tcp.   IN	SRV	10 10 587 mail.example.net.

In practice no application is using them.


Common Host Names
^^^^^^^^^^^^^^^^^

Most clients will search and try (while some will not even try, but just set,
servers with common hostnames):

.. code-block:: text

    imap         IN	CNAME	mail.example.net.
    imaps        IN	CNAME	mail.example.net.
    pop3         IN	CNAME	mail.example.net.
    pop3s        IN	CNAME	mail.example.net.
    smtp         IN	CNAME	mail.example.net.
    smtps        IN	CNAME	mail.example.net.
    submission   IN	CNAME	mail.example.net.


The downside to this is, that you need TLS certificates, not only for all these
hostnames, but also all these hostnames in all domains, which have their mail
sevices hosted here.

In a :doc:`dehydrated domains.txt </server/dehydrated>` configuration file,
this should will as follows:

.. code-block:: text

    # ------------------------------------------------------------
    # Postfix Mail Server Certificates
    # ------------------------------------------------------------
    mail.example.net smtp.example.net smtp.example.org smtp.example.com smtps.example.net smtps.example.org smtps.example.com submission.example.net submission.example.org submission.example.com > postfix

    # ------------------------------------------------------------
    # Dovecot Mail Server Certificates
    # ------------------------------------------------------------
    mail.example.net imap.example.net imap.example.org imap.example.com imaps.example.net imaps.example.org imaps.example.com pop3.example.net pop3.example.org pop3.example.com pop3s.example.net pop3s.example.org pop3s.example.com > dovecot


The example above is for three domains only. For every addiotional domain, the
number of hostnames who need to be certfied by your CA increases exponentially.


References:

 * https://automx.org/en/
 * https://testconnectivity.microsoft.com/
 * https://github.com/smartlyway/email-autoconfig-php
 * :rfc:`6186` - "Use of SRV Records for Locating Email Submission/Access Services"
