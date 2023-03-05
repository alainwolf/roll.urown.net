Mail Client Auto-Configuration
==============================

With mail-client auto-configuration, users who setup a new mail-client or
smartphone only need to provide their mail-address and password. All the
complicated configurations for incoming and outgoing mailservers, port-number,
encryption and login methods, address-books and calendars will then be setup
automatically.

These mail clients retrieve configuration data for a mail-address
trough a combination of DNS and HTTP queries from the domain-part of the address.

As there is no univeersal standard for this, different mail-clients use
their own proprietary method, which service providers need to support on there
servers for this to work. Other clients don't even support such functionality.

Three different methods are known today to support automatic mail client
configuration:

- Apple Mac, iPhone and iPad:

  - iPhone and iPod touch with iOS 4 or later
  - iPad with iOS 4.3 or later or iPadOS 13.1 or later
  - Mac computers with OS X 10.7 or later
  - Apple TV with tvOS 9 or later

- Microsoft Outlook
- Moziila Thunderbird, also supported by:

  - Evolution (for Linux GNOME desktops)
  - FairEmail (for Android phones)
  - K9 Mail (for Android phones)
  - KMail aka Kontact (for Lunux KDE desktops)
  - NextCloud Mail App

Manually providing and mainting all these different formart is tedious.

automx2 App
-----------

`automx2 <https://automx.org/en/>`_ is a auto-configuration web-service who
can provide configuration data in all three formats to requesting clients.


Prerequesites
^^^^^^^^^^^^^

The following needs to be available beforehand:

* :doc:`/server/mariadb/index`
* :doc:`/server/nginx/index`

Create a system user who will run the service::

    $ sudo adduser --system --home /var/www/example.net/automx2 automx2


Create a database access password::

    $ pwgen -s 32 1
    jyHZdNnB3Fe3sTotihMTiuf51BH6EEq9YkCd0zTWU6GekkkO

Create a database and a user in MariaDB server to hold configuration data::

    mysql -p

::

    mysql> CREATE DATABASE `automx2` COLLATE 'utf8mb4_general_ci';
    mysql> GRANT SELECT ON automx2.* TO 'automx2'@'127.0.0.1' \
    mysql>     IDENTIFIED BY 'jyHZdNnB3Fe3sTotihMTiuf51BH6EEq9YkCd0zTWU6GekkkO';
    mysql> FLUSH PRIVILEGES;
    mysql> exit


Create a Python virtual environment for the software to be installed under::

    $ sudo -u automx2 -Hs
    $ cd /var/www/example.net/automx2
    $ wget https://github.com/rseichter/automx2/raw/master/contrib/setupvenv.sh
    $ chmod u+x setupvenv.sh
    $ ./setupvenv.sh


Software Installation
^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo -u automx2 -Hs
    $ source .venv/bin/activate
    $ pip install automx2


Software Configuration
^^^^^^^^^^^^^^^^^^^^^^

Create the file :file:`/etc/automx2/automx2.conf`.

.. code:: ini

    [automx2]

    # A typical production setup would use loglevel WARNING.
    loglevel = DEBUG

    # Echo SQL commands into log? Used for debugging.
    db_echo = no

    # MySQL database on a remote server. This example does not use an encrypted
    # connection and is therefore *not* recommended for production use.
    #db_uri = mysql://username:password@server.example.com/db

    # Database server connection
    db_uri = mysql+pymysql://automx2:jyHZdNnB3Fe3sTotihMTiuf51BH6EEq9YkCd0zTWU6GekkkO@localhost/automx2?charset=utf8mb4

    # Number of proxy servers between automx2 and the client (default: 0).
    # If your logs only show 127.0.0.1 or ::1 as the source IP for incoming
    # connections, proxy_count probably needs to be changed.
    proxy_count = 1


Initialize
^^^^^^^^^^

Initialize the database::

    $ curl http://127.0.0.1:4243/initdb/


Copy and edit the file :file:`/var/www/example.net/automx2/contrib/seed-example.json`

.. code-block:: json

    {
        "provider": "Example Net.",
        "domains": ["example.net", "example.org", "example.com"],
        "servers": [
            {"name": "mail.example.net", "type": "imap"},
            {"name": "mail.example.net", "type": "smtps"}
        ]
    }


SystemD Service
---------------

Copy the provided service file
:file:`/var/www/example.net/automx2/contrib/automx2.service` to the
:file:`/etc/systemd/system/` directory.

Ajust the file path of the ExecStart and WorkingDirectory lines to our
Installation.

.. code-block:: ini

    [Unit]
    After=network.target
    Description=MUA configuration service
    Documentation=https://rseichter.github.io/automx2/

    [Service]
    Environment=FLASK_APP=automx2.server:app
    Environment=FLASK_CONFIG=production
    ExecStart=/var/www/example.net/automx2/bin/flask run --host=127.0.0.1 --port=4243
    Restart=always
    User=automx2
    WorkingDirectory=/var/lib/automx2

    [Install]
    WantedBy=multi-user.target

Reload SystemD and enable the service::

    $ sudo systemctl daemon-reload
    $ sudo systemctl enable automx2


Updating
--------

Updating the Software
^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo -u automx2 -Hs
    $ cd /srv/web/automx2
    $ source .venv/bin/activate
    $ pip install --upgrade automx2


Updating the Database
^^^^^^^^^^^^^^^^^^^^^

::

    $ sudo -u automx2 -Hs
    $ cd /srv/web/automx2
    $ export RELEASE="2021.6"
    $ wget https://github.com/rseichter/automx2/archive/refs/tags/$RELEASE.zip
    $ unzip $RELEASE.zip
    $ cd automx2-$RELEASE/alembic


Edit the file :file:`/var/www/example.net/automx2/alembic/alembic.ini`

.. code-block:: ini

    # Database server connection
    sqlalchemy.url = mysql://automx2:jyHZdNnB3Fe3sTotihMTiuf51BH6EEq9YkCd0zTWU6GekkkO@localhost/automx2?charset=utf8mb4


Do the upgrade::

    $ source .venv/bin/activate
    make upgrade


Mozilla Thunderbird
-------------------

Thunderbird looks for configuration data in XML-format at predefined
(well-known) URLs.

This method of autonconfiguration

This also works for ...


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

Testing
-------

Microsoft
^^^^^^^^^

* `Microsoft Remote Connectivity Analyzer <https://testconnectivity.microsoft.com/>`_
* `Outlook Connectivity <https://testconnectivity.microsoft.com/tests/O365Ola/input>`_


Other Projects
--------------

* `The automx2 Web Application <https://rseichter.github.io/automx2/>`_
* `<https://github.com/smartlyway/email-autoconfig-php>`_
* `<https://github.com/olkitu/Autoconfig-PHP>`_
* `Milkys Homepage: Mail autoconfiguration for MS Outlook, Thunderbird and Apple devices <https://mcmilk.de/projects/autoconfig/>`_


References
----------

RFCs
^^^^

* :rfc:`6186` - "Use of SRV Records for Locating Email Client Services"
* :rfc:`6764` - "Locating Services for CalDAV and CardDAV"


Mozilla Thunderbird
^^^^^^^^^^^^^^^^^^^

Mozilla Wiki:

* `Thunderbird:Autoconfiguration <https://wiki.mozilla.org/Thunderbird:Autoconfiguration>`_ (2021)
* `Thunderbird:Autoconfiguration:DNSBasedLookup <https://wiki.mozilla.org/Thunderbird:Autoconfiguration:DNSBasedLookup>`_ (2009)
* `Thunderbird:Autoconfiguration:ConfigFileFormat <https://wiki.mozilla.org/Thunderbird:Autoconfiguration:ConfigFileFormat>`_ (2022)

Ben Bucksch (Moziila Dev):

* `Thunderbird Autoconfiguration <https://www.bucksch.org/1/projects/thunderbird/autoconfiguration/>`_ (2022)


Microsoft Outlook
^^^^^^^^^^^^^^^^^

Microsoft Support:

* `Outlook 2016 implementation of Autodiscover <https://support.microsoft.com/en-us/topic/outlook-2016-implementation-of-autodiscover-0d7b2709-958a-7249-1c87-434d257b9087>`_

Microsoft Build:

* `Autodiscover for Exchange <https://docs.microsoft.com/en-us/exchange/client-developer/exchange-web-services/autodiscover-for-exchange>`_
* `Microsoft Build: Autodiscover web service reference for Exchange <https://docs.microsoft.com/en-us/exchange/client-developer/web-service-reference/autodiscover-web-service-reference-for-exchange>`_
* `Microsoft Build: Autodiscover service in Exchange Server <https://docs.microsoft.com/en-us/Exchange/architecture/client-access/autodiscover?view=exchserver-2019>`_

Third-Party:

* `MSXFAQ: Autodiscover V2 <https://www.msxfaq.de/exchange/autodiscover/autodiscover_v2.htm>`_


Apple
^^^^^

Apple Support:

* `Intro to mobile device management <https://support.apple.com/de-de/guide/deployment/depc0aadd3fe/web>`_
* `Mail MDM payload settings for Apple devices <https://support.apple.com/de-de/guide/deployment/dep9c14bfc5/1/web/1.0>`_
* `Subscribed Calendars MDM payload settings for Apple devices <https://support.apple.com/de-de/guide/deployment/dep950bfdb6/1/web/1.0>`_
* `Distribute profiles manually with Profile Manager <https://support.apple.com/guide/profile-manager/distribute-profiles-manually-pmdbd71ebc9/mac>`_

Apple Developers:

* `Configuration Profile Reference (PDF) <https://developer.apple.com/business/documentation/Configuration-Profile-Reference.pdf>`_

Third-Party:

* `Over-the-air IPhone Setup Using a Signed .mobileconfig File <http://www.rootmanager.com/iphone-ota-configuration/iphone-ota-setup-with-signed-mobileconfig.html>`_
