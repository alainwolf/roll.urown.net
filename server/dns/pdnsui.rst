pdnsui
======

A PowerDNS UI ThatDoesntSuck™ (well, hopefully).

::

	$ sudo apt-get install bundler ruby-ramaze ruby-dnsruby
	$ cd /var/www/server.lan/public_html/
	$ chmod -R g+rw .
	$ git clone https://leucos@github.com/leucos/pdnsui.git
	$ cd pdnsui/
	$ git checkout develop
	$ mysqladmin -u root -p create pdns-test
	$ mysql -u root -p pdns-test < misc/powerdns.mysql
	$ mysql -u root -p pdns-test
	

.. code-block:: mysql

	> CREATE USER 'pdnsui'@'localhost' IDENTIFIED BY '********';
	> GRANT ALL PRIVILEGES ON `pdns-test`.* TO 'pdnsui'@'localhost';
	> FLUSH PRIVILEGES;
	> QUIT;

::

	$ cp config/database.rb.sample-mysql config/database.rb
	$ bundle


