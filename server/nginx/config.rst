Nginx Configuration
====================

We use a modular approach here, whith most configuration settings outsourced to
individual files.

.. contents:: \ 

Nginx Main Configuration File
-----------------------------

The main configuration file is :file:`/etc/nginx/nginx.conf`.

.. code-block:: nginx
   :linenos:

    #
    # Nginx Main Configuration file
    #

    # Run as a less privileged user for security reasons.
    user                    www-data;

    # The maximum number of connections for Nginx is calculated by:
    # max_clients = worker_processes * worker_connections

    # How many worker threads to run. 
    # Ideally set to the number of CPU cores or "auto" to autodetect.
    worker_processes        auto;

    # Max. number of connections per worker
    events {
        worker_connections  2048;
    }

    # Maximum open file descriptors per process;
    # should be higher worker_connections.
    worker_rlimit_nofile    4098;

    error_log               /var/log/nginx/error.log warn;
    pid                     /var/run/nginx.pid;

    http {

        # Default HTTP configuration options
        include /etc/nginx/conf.d/*.conf;

        # Virtual server configurations
        include /etc/nginx/sites-enabled/*.conf;
    }   

If you don't set **worker_processes** to **auto** on line 13 above. You should set
it to the number of CPU cores of your server. To find out how many CPU cores are 
available, run the following command::

    $ cat /proc/cpuinfo | grep processor | wc -l
    2

The above configuration will allow a maximum of 4,096 client connections at the 
any given time (2 CPU cores which will handle 2,048 connections each). 


HTTP Configuration Options
--------------------------

On line 30 in the above :file:`/etc/nginx/nginx.conf` various default options 
from the directory :file:`/etc/nginx/conf.d` loaded. 

They are discussed in the following chapters in no particular order.


MIME-Tpes and Character-Sets
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: nginx
   :linenos:

    #
    # Nginx Default MIME-Types and Charsets Configuration
    #

     # Define the MIME types for files.
    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Update charset_types due to updated mime.types
    charset_types       text/xml
                        text/plain
                        text/vnd.wap.wml
                        application/x-javascript
                        application/rss+xml
                        text/css
                        application/javascript
                        application/json;

Logging
^^^^^^^

.. code-block:: nginx
   :linenos:

    #
    # Nginx Logging Configuration
    #
    log_format          main  '$remote_addr - $remote_user [$time_local] "$request" '
                        '$status $body_bytes_sent "$http_referer" '
                        '"$http_user_agent" "$http_x_forwarded_for"';

    # Default log file
    access_log          /var/log/nginx/access.log  main;


TCP Options
^^^^^^^^^^^

The file :file:`/etc/nginx/conf.d/tcp-options.conf` contains some optimizations 
on the network level.

.. code-block:: nginx
   :linenos:

    #
    # Nginx TCP network configuration
    #

    # Speed up file transfers by using sendfile() instead of read() and write().
    sendfile on;

    # Increase throughput by sending full TCP packets with sendfile().
    tcp_nopush on;


Open Files Cache
^^^^^^^^^^^^^^^^

:file:`/etc/nginx/conf.d/open-file-cache.conf`.


.. code-block:: nginx
   :linenos:

    #
    # Nginx Open Files Cache Configuration
    #

    # This tells Nginx to cache open file handles, "not found" errors, metadata 
    # about files and their permissions, etc.
    #
    # The upside of this is that Nginx can immediately begin sending data when a 
    # popular file is requested, and will also know to immediately send a 404 if a 
    # file is missing on disk, and so on.
    #
    # However, it also means that the server won't react immediately to changes on 
    # disk, which may be undesirable.
    #
    # Production servers with stable file collections will definitely want to enable
    # the cache.

    # Cache up to 10,000 recently used file descriptors
    # Relase inactive files from the cache after 60 seconds (default)
    open_file_cache          max=10000;

    # Also cache errors like "file not found".
    open_file_cache_errors   on;

Limits
^^^^^^

The file :file:`/etc/nginx/conf.d/limits.conf` can be used to set various 
network related limitations, like number of allowed connections per IP address 
or various buffer sizes. At this time we limit connections only and stick with 
Nginx default values for the rest.

.. code-block:: nginx
   :linenos:

    #
    # Control Simultaneous Connections
    #
    # The zone, in which session states are stored. Handles 16,000 sessions per MB
    # Returns 503 (Service Temporarily Unavailable) error if exhausted.
    limit_conn_zone $binary_remote_addr zone=addr:10m;

    # Max. number of simultaneous connections per session (IP address)
    limit_conn addr 256;


Security
^^^^^^^^

We group settings who might affect server security in the file 
:file:`/etc/nginx/conf.d/server-security.conf`.

.. code-block:: nginx
   :linenos:

    #
    # Security and Access Restriction Settings
    # 

    # Don't send the nginx version number in error pages and server header
    server_tokens off;


Default Site
^^^^^^^^^^^^

The file :file:`/etc/nginx/default-site.conf` is installed with Nginx and 
ususally displays a test page to show that installation has been successful.

However this should be changed immediately to something more usefull and secure.

.. code-block:: nginx
   :linenos:

    #
    # Default Server catch all requests ...
    #   ... without hostname
    #   ... with a numeric IP-Address as hostname
    #   ... to any hostname not defined elsewhere

    server {

        # IPv4 private address assigned by Router with DHCP
        listen      192.0.2.3:80 default_server bind;
        listen      192.0.2.3:443 ssl spdy default_server bind;

        # Port-forwarded connections from firewall-router 
        # Also catches non-SNI clients
        listen      192.0.2.10:80 default_server bind;
        listen      192.0.2.10:443 ssl spdy default_server bind;

        # wwww.example.com
        listen      192.0.2.11:80 default_server bind;
        listen      192.0.2.11:443 ssl spdy default_server bind;
        listen      [2001:db8::11]:80 default_server bind;
        listen      [2001:db8::11]:443 ssl spdy default_server bind;

        # cloud.example.com
        listen      192.0.2.12:80 default_server bind;
        listen      192.0.2.12:443 ssl spdy default_server bind;
        listen      [2001:db8::12]:80 default_server bind;
        listen      [2001:db8::12]:443 ssl spdy default_server bind;
        
        # Catch requests without the “Host” header field.
        server_name "";

        include /etc/nginx/tls.conf;
        ssl_certificate     /etc/ssl/certs/ssl-cert-snakeoil.pem;
        ssl_certificate_key /etc/ssl/private/ssl-cert-snakeoil.key;

        # Return HTTP Error Code 403 - Forbidden
        return 403;
    }

.. index:: Cipher Suite; Set in Nginx

TLS - Transport Layer Security
------------------------------

Common TLS Settings
^^^^^^^^^^^^^^^^^^^

Enforce our :ref:`cipher-suite` on our websites.

.. code-block:: nginx
   :linenos:

    #
    # TLS - Transport Layer Security (SSL)
    #
    # nginx/1.7.0
    # OpenSSL 1.0.1f 6 Jan 2014

    # Let the server decide which ciphers are preferred
    ssl_prefer_server_ciphers on;

    # Don't use SSLv2 and SSLv3
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;

    # Cipher suite selection
    ssl_ciphers 'kEDH+aRSA+AES128:kEECDH+aRSA+AES128:+SSLv3';

    # HSTS - Strict Transport Security
    add_header Strict-Transport-Security max-age=15768000; # six months

    # Diffie-Hellman ephemeral key exchange parameters
    ssl_dhparam /etc/ssl/dhparams/dh_2048.pem;

    #
    # Optimize SSL by caching session parameters. This cuts down on 
    # the number of expensive SSL handshakes. The handshake is the most 
    # CPU-intensive operation, and by default it is re-negotiated on every 
    # new/parallel connection. 
    # Further optimization can be achieved by raising keepalive_timeout, but that 
    # shouldn't be done unless you serve primarily HTTPS.
    #

    #
    # A cache (of type "shared between all Nginx workers") enables re-use of already
    # negotiated TLS connections. The cache holds about 4,000 sessions per MB.
    ssl_session_cache   shared:SSL:10m;

    # Time during which a client may reuse a cached session without re-negotiation. 
    ssl_session_timeout 10m;


OCSP Response Stapling
^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: nginx
   :linenos:

    #
    # OCSP Response Stapling
    #

    # Enables stapling of OCSP responses by the server.
    ssl_stapling on;

    # Enables verification of OCSP responses by the server. 
    ssl_stapling_verify on;

    # DNS servers used to resolve names for OCSP servers (and upstream servers)
    resolver 192.0.2.1 [2001:db8::1];


Websites
--------

Individual websites, also called virtual servers (identified by hostname and or 
IP address) are defined in the directory :file:`/etc/nginx/sites-available`.

To enable a site, a symbolic link to the server configuration is created in the 
directory :file:`/etc/nginx/sites-enabled`.

This allows quick and easy activation and de-activation of websites, while 
keeping its configuration.

Activate::

    $ sudo ln -s /etc/nginx/sites-available/example.com.conf /etc/nginx/sites-enabled/
    $ sudo service nginx restart

De-Activate::

    $ sudo rm /etc/nginx/sites-enabled/example.com.conf
    $ sudo service nginx restart

Configuration of indivudual sites depends heavely on the nature of the website. 
As reference we show a simple website who only serves static HTML pages.


Static Website Example
^^^^^^^^^^^^^^^^^^^^^^

Typically this would be saved in 
:file:`/etc/nginx/sites-available/example.com.conf` to be activated as shown 
above.

.. code-block:: nginx
   :linenos:

    #
    # example.com Website

    # Unsecured HTTP Site and or www-site - Redirect to non-www HTTPS
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.10:80;

        # IPv4 private address
        listen                  192.0.2.11:80;

        # IPv6 global address
        listen                  [2001:db8::11]:80;

        server_name             example.com www.example.com;

        # Redirect to non-www HTTPS
        return                  301 https://example.com$request_uri;
    }

    # Secured HTTPS wwww Site - Redirect to non-www
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.10:443 ssl spdy;

        # IPv4 private address
        listen                  192.0.2.11:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::11]:443 ssl spdy;

        server_name             www.example.com;

        include                 /etc/nginx/tls.conf;
        include                 /etc/nginx/ocsp-stapling.conf;
        ssl_certificate         /etc/ssl/certs/example.com.chained.cert.pem;
        ssl_certificate_key     /etc/ssl/private/example.com.key.pem;
        ssl_trusted_certificate /etc/ssl/certs/CAcert_Class_3_Root.OCSP-chain.pem;

        # Redirect to non-www HTTPS
        return                  301 https://example.com$request_uri;
    }

    # Secured HTTPS Site
    server {

        # IPv4 private address
        # Port-forwarded connections from firewall-router
        listen                  192.0.2.10:443 ssl spdy;

        # IPv4 private address
        listen                  192.0.2.11:443 ssl spdy;

        # IPv6 global address
        listen                  [2001:db8::11]:443 ssl spdy;

        server_name             example.com;

        # Default common TLS settings
        include                 /etc/nginx/tls.conf;
        include                 /etc/nginx/ocsp-stapling.conf;
        ssl_certificate         /etc/ssl/certs/example.com.chained.cert.pem;
        ssl_certificate_key     /etc/ssl/private/example.com.key.pem;
        ssl_trusted_certificate /etc/ssl/certs/CAcert_Class_3_Root.OCSP-chain.pem;

        # Default common website settings
        include                 /etc/nginx/sites-defaults/*.conf;

        # Public Documents Root
        root                    /var/www/example.com/public_html;

        # Logging Configuration
        access_log              /var/www/example.com/log/access.log;
        error_log               /var/www/example.com/log/error.log;
    }


Website Default Settings
------------------------

In the example website above there is a **include** statement on line 71 to load 
various settings, which every website should use for enhanced performance and 
security.


.. note::
    Some web applications like ownCloud might provide their own settings which 
    may duplicate or even conflict with some of the settings below. In this case
    only some of the configuation files might be included individually.

Site Security
^^^^^^^^^^^^^

.. code-block:: nginx
   :linenos:

    #
    # Default Site-Security and Access Restrictions
    #

    #
    # Limit Available Methods
    # Only allow GET, HEAD and POST requests.
    if ($request_method !~ ^(GET|HEAD|POST)$ ) {
        return 405;
    }

    #
    # Prevent clients from accessing (hidden) dot-files (i.e .htaccess, .htpasswd).
    location ~* (?:^|/)\. {
        deny all;
    }

    #
    # Prevent clients from accessing backup/config/source files
    location ~* (?:\.(?:bak|config|sql|fla|psd|ini|log|sh|inc|swp|dist)|~)$ {
        deny all;
    }

    #
    # Don't allow clients to render pages inside frames or iframes and avoid
    # clickjacking
    add_header  X-Frame-Options SAMEORIGIN;

    #
    # Enable the Cross-site scripting (XSS) filter built into most recent browsers.
    add_header  X-XSS-Protection "1; mode=block";

    #
    # Reduce exposure to drive-by downloads and protect MSIE from executing files. 
    # Prevent Internet Explorer and Google Chrome from MIME-sniffing a response away
    # from the declared content-type.
    add_header  X-Content-Type-Options: nosniff;


Compression
^^^^^^^^^^^

In :file:`/etc/nginx/sites-defaults.d/compression.conf` compression of transferred data 
from the web-server to the web-browser is activated.

.. code-block:: nginx
   :linenos:

    #
    # Compression
    #
    # The ngx_http_gzip_module module is a filter that compresses responses using 
    # the “gzip” method. This often helps to reduce the size of transmitted data by 
    # half or even more. 

    # Enable Gzip compressed.
    gzip on;

    # Compression level (1-9).
    # 5 is a perfect compromise between size and cpu usage, offering about
    # 75% reduction for most ascii files (almost identical to level 9).
    gzip_comp_level 5;

    # Don't compress anything that's already small and unlikely to shrink much
    # if at all (the default is 20 bytes, which is bad as that usually leads to
    # larger files after gzipping).
    gzip_min_length 256;

    # Compress data even for clients that are connecting to us via proxies,
    # identified by the "Via" header (required for CloudFront).
    gzip_proxied any;

    # Tell proxies to cache both the gzipped and regular version of a resource
    # whenever the client's Accept-Encoding capabilities header varies;
    # Avoids the issue where a non-gzip capable client (which is extremely rare
    # today) would display gibberish if their proxy gave them the gzipped version.
    gzip_vary on;

    # Compress all output labeled with one of the following MIME-types.
    # text/html is always compressed by HttpGzipModule
    gzip_types
        application/atom+xml
        application/javascript
        application/json
        application/rss+xml
        application/vnd.ms-fontobject
        application/x-font-ttf
        application/x-web-app-manifest+json
        application/xhtml+xml
        application/xml
        font/opentype
        image/svg+xml
        image/x-icon
        text/css
        text/plain
        text/x-component;

      # This should be turned on if you are going to have pre-compressed copies 
      # (.gz) of static files available. If not it should be left off as it will 
      # cause extra I/O for the check. It is best if you enable this in a location{} 
      # block for a specific directory, or on an individual server{} level.
      # gzip_static on;


Browser Cache
^^^^^^^^^^^^^

.. code-block:: nginx
   :linenos:

    #
    # Client Cache Control
    #

    #
    # Expire rules for static content
    # Do not use a default expire rule with nginx unless a site is completely static

    # cache.appcache, your document html and data
    location ~* \.(?:manifest|appcache|html?|xml|json)$ {
      expires -1;
    }

    # Feed
    location ~* \.(?:rss|atom)$ {
      expires 1h;
      add_header Cache-Control "public";
    }

    # Media: images, icons, video, audio, HTC
    location ~* \.(?:jpg|jpeg|gif|png|ico|cur|gz|svg|svgz|mp4|ogg|ogv|webm|htc)$ {
      expires 1M;
      access_log off;
      add_header Cache-Control "public";
    }

    # CSS and Javascript
    location ~* \.(?:css|js)$ {
      expires 1y;
      access_log off;
      add_header Cache-Control "public";
    }

    # WebFonts
    # If you are NOT using cross-domain-fonts.conf, uncomment the following directive
    location ~* \.(?:ttf|ttc|otf|eot|woff)$ {
        expires 1M;
        access_log off;
        add_header Cache-Control "public";
    }

    #
    # Filename-based cache busting
    # Route all requests for /css/style.20120716.css to /css/style.css
    # github.com/h5bp/html5-boilerplate/wiki/cachebusting
    location ~* (.+)\.(?:\d+)\.(js|css|png|jpg|jpeg|gif)$ {
       try_files $uri $1.$2;
    }

    # Force the latest IE version
    # Use ChromeFrame if it's installed for a better experience for the poor IE folk
    add_header "X-UA-Compatible" "IE=Edge";

    # Prevent mobile network providers from modifying your site
    add_header "Cache-Control" "no-transform";


Test and Activate
-----------------

To test the Nginx configuration::

    $ sudo nginx -t
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

The configuration is also tested before service restarts. Alternatively test can
be done with the service::

    $ sudo service nginx configtest
    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

