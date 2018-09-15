PHP FastCGI
===========

The `PHP FastCGI Process Manager <http://www.php.net/manual/en/install.fpm.php>`_
or PHP-FPM in short is server running in the background. When a webbrowser
requests a webpage which is made by a PHP script, the web server (Nginx in our
case) will forward the request to the PHP-FPM server who will process it.
PHP-FPM then sends the script output back to webserver. At last the webserver
forwards the output back to the webbrowser.

Install PHP-FPM
---------------

::

	$ sudo apt install php7-fpm

The Ubuntu upstart service **php7-fpm** is installed and started.


PHP Configuration
-----------------

php.ini
^^^^^^^

Change the following in :file:`/etc/php/7.0/php.ini`:

.. code-block:: ini

	cgi.fix_pathinfo=0


php-fpm.conf
^^^^^^^^^^^^

The global PHP-FPM configuraton is stored in :file:`/etc/php5/fpm/php-fpm.conf`.
Nothing needs to be changed there.


Pools
^^^^^

Server pools are defined in the  :file:`/etc/php5/fpm/pools.d` directory.
Only one pool is defined :file:`/etc/php5/fpm/pools.d/www.conf`.

.. code-block:: ini

	pm.status_path = /fpm_status

.. code-block:: ini

	catch_workers_output = yes


PHP Scripts Server Restart
--------------------------

To apply the configuration changes, the server needs to be restarted::

	$ sudo restart php5-fpm


Nginx Configuration
-------------------

There are to parts to this.


PHP Backend Server
^^^^^^^^^^^^^^^^^^

First we add a backend-server definition to the main Nginx HTTP server
configuration. With this Nginx will be able to becomes a sort of proxy server
and request content to be delivered to clients from the PHP-FPM server.

.. note:

	Backend-server definitions have to be defined outside of the virtual server
	context.

Create the
:download:`php-backend.conf </server/config-files/etc/nginx/http-conf.d/70_php-backend.conf>`
configuration file in the :file:`/etc/nginx/http-conf.d/` directory:

.. literalinclude:: /server/config-files/etc/nginx/http-conf.d/70_php-backend.conf
    :language: nginx


Like all other file in the :file:`/etc/nginx/http-conf.d` directory, it will be
automatically included in the main Nginx HTTP server configuration.


PHP Script Handler
^^^^^^^^^^^^^^^^^^

Secondly we define under what circumstances, processing is turned over to the
PHP-FPM server. As this can be defined at any level (*http*, *server*,
*location*, etc), we create a file :file:`/etc/nginx/php-handler.conf` to be
included where appropriate.

.. code-block:: nginx

	#
	# Pass PHP scripts to the cgi server
	location ~ \.php$ {
	        try_files $uri =404;
	        fastcgi_split_path_info ^(.+\.php)(/.+)$;
	        include fastcgi_params;
	        fastcgi_index index.php;
	        fastcgi_pass php-backend;
	}


FastCGI Parameters
^^^^^^^^^^^^^^^^^^

The file :download:`/etc/nginx/fastcgi_params </server/config-files/etc/nginx/fastcgi_params>`
passes down important  environment variables from the context of the request
down to the scripts handling executable (e.g. PHP):

.. literalinclude:: /server/config-files/etc/nginx/fastcgi_params
    :language: nginx


To apply any changes made in to the Nginx configuration, the server needs to be
restarted::

	$ sudo service nginx restart


References
----------

 * `PHP FastCGI <https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/>`_
   in the Nginx Wiki.
