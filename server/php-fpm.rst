Web Applications Server
=======================

The `PHP FastCGI Process Manager <http://www.php.net/manual/en/install.fpm.php>`_
or PHP-FPM in short is server running in the background. When a webbrowser 
requests a webpage which is made by a PHP script, the web server (Nginx in our 
case) will forward the request to the PHP-FPM server who will process it. 
PHP-FPM then sends the script output back to webserver. At last the webserver 
forwards the output back to the webbrowser.

Install PHP-FPM
---------------

::

	$ sudo apt-get install php5-fpm
	
The Ubuntu upstart service **php5-fpm** is installed and started.


PHP Configuration
-----------------

php.ini
^^^^^^^

Change the following in :file:`/etc/php5/fpm/php.ini`:

.. code-block:: ini

	expose_php = Off

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

First we add a backend-server definition to the main
Nginx HTTP server configuration. With this Nginx will be able to becomes a sort 
of proxy server and request content to be delivered to clients from the PHP-FPM 
server.

Create the
:download:`php-backend.conf </server/nginx/nginx-config/config-files/conf.d/php-backend.conf>`
configuration file in the :file:`/etc/nginx/conf.d/` directory:

.. literalinclude:: /server/nginx/nginx-config/config-files/conf.d/php-backend.conf
    :language: nginx
    :linenos:


Like all other file in the :file:`/etc/nginx/conf.d` directory, it will be 
automatically included in the main Nginx server configuration.


PHP Script Handler
^^^^^^^^^^^^^^^^^^

Secondly we define under what circumstances, processing is turned over to the 
PHP-FPM server. As this can be defined at any level (*http*, *server*, 
*location*, etc), we create a file :file:`/etc/nginx/php-handler.conf` to be 
included where appropriate.

.. code-block:: nginx
   :linenos:

	#
	# Pass PHP scripts to the cgi server
	location ~ \.php$ {
	        try_files $uri =404;
	        fastcgi_split_path_info ^(.+\.php)(/.+)$;
	        include fastcgi_params;
	        fastcgi_index index.php;
	        fastcgi_pass php-backend;
	}


The file :file:`/etc/nginx/fastcgi_params` inlcuded on line 6 above should look 
like this:

.. code-block:: nginx
   :linenos:

	fastcgi_param  QUERY_STRING       $query_string;
	fastcgi_param  REQUEST_METHOD     $request_method;
	fastcgi_param  CONTENT_TYPE       $content_type;
	fastcgi_param  CONTENT_LENGTH     $content_length;

	fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
	fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
	#fastcgi_param  PATH_INFO          $fastcgi_path_info;
	#fastcgi_param  PATH_TRANSLATED    $document_root$fastcgi_path_info;
	fastcgi_param  REQUEST_URI        $request_uri;
	fastcgi_param  DOCUMENT_URI       $document_uri;
	fastcgi_param  DOCUMENT_ROOT      $document_root;
	fastcgi_param  SERVER_PROTOCOL    $server_protocol;
	fastcgi_param  HTTPS              $https if_not_empty;

	fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
	fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

	fastcgi_param  REMOTE_ADDR        $remote_addr;
	fastcgi_param  REMOTE_PORT        $remote_port;
	fastcgi_param  SERVER_ADDR        $server_addr;
	fastcgi_param  SERVER_PORT        $server_port;
	fastcgi_param  SERVER_NAME        $server_name;

	# PHP only, required if PHP was built with --enable-force-cgi-redirect
	fastcgi_param  REDIRECT_STATUS    200;


To apply any changes made in to the Nginx configuration, the server needs to be 
restarted::

	$ sudo service nginx restart
