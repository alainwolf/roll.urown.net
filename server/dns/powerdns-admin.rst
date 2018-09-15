PowerDNS-Admin
==============

`PowerDNS-Admin <https://github.com/ngoduykhanh/PowerDNS-Admin>`_ is a web-based
administration interface for PowerDNS.

Unlike other older front-end applications for PowerDNS, who often write
directly to the PowerDNS database, it uses the PowerDNS application
programming interface introduced in PowerDNS 3.x and 4.x.


Prerequisites
-------------

 * A working PowerDNS installation;
 * MariaDB database server for storage of zone meta-data, users and their roles;
 * Git to get the source code;
 * Python language development environment;
 * Development libraries for MariaDB, SASL, LDAP and SSL
 * uWSGI Python application web-server;
 * Nginx web-server as a reverse proxy to the web application;

A random password for the database user (16 characters recommended)::

	$ pwgen -cns 16 1


A random Flask secret app key (24 characters recommended)::

	$ pwgen -cns 24 1


Database
--------

Independently of PowerDNS storing its data in a MariaDB database, PowerDNS-
Admin uses its own database to store users, access rights and various other
information about the managed domains (zones).

To create the database used by the PowerDNS-Admin application start an
interactive session with root privileges on your database server::

	$ mysql -u root -p
	Enter password: ********

While using your MariaDB root password to login.


.. code-block:: mysql

	mysql> CREATE DATABASE powerdnsadmin;
	mysql> GRANT ALL PRIVILEGES ON powerdnsadmin.* TO 'powerdnsadmin'@'localhost'
			IDENTIFIED BY '********';
	mysql> FLUSH PRIVILEGES;
	mysql> quit


While using the random database user password created earlier.


Installation
------------

Software Libraries
^^^^^^^^^^^^^^^^^^

Install required software packages::

	$ sudo apt-get install libsasl2-dev libldap2-dev libmariadbclient-dev


Source Code
^^^^^^^^^^^

.. note::

	As of now (October 2016) PowerDNS-Admin does only run with Python 2.x,
	although support for Python 3 is
	`planned <https://github.com/ngoduykhanh/PowerDNS-Admin/issues/120>`_.


Download the source code of the project from GitHub and set the web-server user
as its owner::

	$ cd /usr/local/lib
	$ sudo git clone https://github.com/ngoduykhanh/PowerDNS-Admin.git
	$ sudo chown -R www-data:www-data PowerDNS-Admin


We work as the web-server user from here on::

	$ sudo -u www-data -Hs


Create a new virtual Python environment called :file:`flask` and activate it::

	$ cd /usr/local/lib/PowerDNS-Admin
	$ virtualenv --python=python2.7 flask
	$ source ./flask/bin/activate

You should now see that your are working in a virtual environment by looking at
your system command prompt::

	(flask) $

Install required Python packages::

	(flask) $ pip install -r requirements.txt
	(flask) $ pip install mysql


Configuration
-------------

Copy the configuration example and edit it::

	(flask) $ cp config_template.py config.py


:download:`/usr/local/lib/PowerDNS-Admin/config.py <config/config.py>`:


Basic Settings
^^^^^^^^^^^^^^

 * Enable CSRF (Cross-Site Request Forgery) protection for the HTML forms.
   Default is True.
 * Set a secret key to sign the users browser cookies for user session
   protection.
 * The address and port where the applications web-interface listens for
   incoming requests.


.. literalinclude:: config/config.py
    :language: python
    :lines: 4-9


Database Connection
^^^^^^^^^^^^^^^^^^^

.. literalinclude:: config/config.py
    :language: python
    :lines: 23-28

While using the random database user password created earlier.


Disable LDAP Connection
^^^^^^^^^^^^^^^^^^^^^^^

Since we don't have or use LDAP, we disable it by commenting out the relevant
entries.

.. literalinclude:: config/config.py
    :language: python
    :lines: 40-48


PowerDNS API Server Connection
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is how the web application connects to the API interface of the PowerDNS
server.

Settings should match with your REST-API server configuration of :doc:`powerdns`.

.. literalinclude:: config/config.py
    :language: python
    :lines: 72-75


DNS Record Types
^^^^^^^^^^^^^^^^

The allowed DNS types. The defaults ('A', 'AAAA', 'CNAME', 'SPF', 'PTR', 'MX',
'TXT') are very minimal.

A `list of all the types of DNS records <https://doc.powerdns.com/md/types/>`_
which PowerDNS supports is available in the
`PowerDNS server documentation <https://doc.powerdns.com/md/>`_.

We recommend the following, which are used throughout other chapters in this
guide:

 * A (mapping hostnames to IPv4 addresses)
 * AAAA (mapping hostnames to IPv6 addresses)
 * CERT (to store SSL/TLS certificates in DNS)
 * CNAME (alias of a hostname)
 * MX (mail exchange servers)
 * NAPTR (reverse mapping of phone numbers to VoIP addresses)
 * NS (the name-servers responsible for a domain)
 * OPENPGPKEY (store PGP keys in DNS)
 * PTR (reverse mapping of IP addresses to host names)
 * SPF (Sender Policy Framework against mail spam)
 * SSHFP (to store SSH public key fingerprints in DNS)
 * SRV (mapping service connections in domains)
 * TLSA (SSL/TLS certificates that a service is allowed to present to clients)
 * TXT (store text in DNS)

The following might be used in our domains too, but should not be allowed to be
edited by users, as they are managed elsewhere.

 * CDNSKEY (DNSSEC related)
 * CDS (DNSSEC related)
 * DNSKEY (DNSSEC related, managed by :file:`pdnsutil`)
 * KEY (DNSSEC related)
 * NSEC, NSEC3, NSEC3PARAM (DNSSEC related, managed by :file:`pdnsutil`)
 * RRSIG (DNSSEC related, managed by :file:`pdnsutil`)
 * SOA (Start Of Authority, defines a domain in DNS)
 * TKEY, TSIG (keys to sign and authenticate communications between authorized
   DNS servers and clients)


.. literalinclude:: config/config.py
    :language: python
    :lines: 77-78


Initialize Database
-------------------

Let it create the database records::

	(flask) $ ./create_db.py


First Run
---------

Let it start for a first time to create the administrative user::

	(flask) $ ./start.py


Point your browser to http://192.0.2.41:9393 to create your first user
account, which automatically will have administrative privileges.

Log-out with your browser and stop the server by pressing CTRL-C in you session.


uWSGI Configuration
-------------------

Create a uWSGI app configuration in the :file:`/etc/uwsgi/apps-available/powerdns-admin.ini` with the following contents:

.. literalinclude:: /server/config-files/etc/uwsgi/apps-available/powerdns-admin.ini
    :language: ini


The lines commented out, are already defined in the system-wide defaults.

Create a symlink to activate::

	$ cd /etc/uwsgi/
	$ sudo ln -s apps-available/powerdns-admin.ini apps-enabled/


Start the uwsgi service::

	$ sudo service uwsgi start powerdns-admin


Nginx Configuration
-------------------

Create the file :file:`/etc/nginx/webapps/powerdns-admin.conf` as follows:


.. literalinclude:: /server/config-files/etc/nginx/webapps/powerdns-admin.conf
    :language: nginx


Include the file in the appropriate Nginx server definition:

.. code-block:: nginx

	    # PowerDNS-Admin
	    include     webapps/powerdns-admin.conf;


Test the and reload the Nginx configuration::

	$ sudo service nginx conftest && sudo service nginx reload



References
----------

 * https://github.com/ngoduykhanh/PowerDNS-Admin/blob/master/README.md
 * https://github.com/ngoduykhanh/PowerDNS-Admin/wiki
 * https://linuxse.co/2015/12/powerdns-admin-web-ui-install-manage-powerdns-server/
