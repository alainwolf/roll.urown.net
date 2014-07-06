WebMail
=======

.. image:: RainLoop-logo.*
    :alt: RainLoop Logo
    :align: right

`RainLoop <http://rainloop.net/>`_ is a simple, modern and fast web-based email
client, free to use for personal or non-profit projects. RainLoop Webmail is
licensed under a Creative Commons license (`CC BY-NC-SA 3.0 
<http://rainloop.net/licensing/>`_).

Prerequisites
-------------

 * Installed and working :doc:`dovecot`.

 * Installed and working :doc:`/server/nginx/index`.


Download and Installation
-------------------------

::
	
	$ cd downloads
	$ wget http://repository.rainloop.net/v2/webmail/rainloop-latest.zip
	$ sudo mkdir -p /var/www/rainloop
	$ sudo unzip rainloop-latest.zip -d /var/www/rainloop
	$ sudo chown -R www-data:www-data /var/www/rainloop


Web-Server Configuration
------------------------

Webmail Virtual Host
^^^^^^^^^^^^^^^^^^^^

Create a new virtual host :download:`/etc/nginx/sites-available/webmail.conf 
<config/nginx/webmail.conf>` for Nginx:

.. literalinclude:: config/nginx/webmail.conf
    :language: nginx


RainLoop Web-Application
^^^^^^^^^^^^^^^^^^^^^^^^

Create a new web-application configuration 
:download:`/etc/nginx/webapps/rainloop.conf <config/nginx/webmail.conf>` for the 
RainLoop webmail client:

.. literalinclude:: config/nginx/rainloop.conf
    :language: nginx


Activate Restart & Restart
^^^^^^^^^^^^^^^^^^^^^^^^^^

Activate the new virtual server::

	$ cd /etc/nginx
	$ sudo ln -s sites-available/webmail.conf sites-enabled/


Check the configuration and restart the Web-Server::

	$ sudo nginx -t
	$ sudo service nginx restart


RainLoop Configuration
----------------------

Point your webbrowser to `<http://mail.example.com/?admin>`_


ownCloud Integration
--------------------

Download the RainLopp webmail-plugin for ownCloud::

	$ cd download
	$ wget http://repository.rainloop.net/v2/other/owncloud/rainloop.zip
	$ sudo mkdir -p /var/www/owncloud/apps/rainloop
	$ sudo unzip rainloop.zip -d /var/www/owncloud/apps
	$ sudo chown -R www-data:www-data /var/www/owncloud/apps

