Nginx Configuration for Nextcloud
=================================

.. contents::
    :local:


PHP Handler for Nextcloud
-------------------------

.. code-block:: nginx

    # ----------------------------------------
    # example.net Nextcloud PHP Handler
    # ----------------------------------------
    upstream php-nextcloud-backend {
        server unix:/run/php/nextcloud-fpm.sock;
    }


FastCGI Cache Zone
------------------

.. code-block:: nginx

    # ----------------------------------------
    # example.net Nextcloud FastCGI Cache Zone
    # ----------------------------------------

    # For caching gallery thumbnails
    # https://doc.owncloud.org/server/8.2/admin_mownCloudanual/configuration_server/performance_tuning/webserver_tips.html#nginx-caching-owncloud-gallery-thumbnails
    fastcgi_cache_path /var/cache/nginx/nextcloud_temp
        levels=1:2
        keys_zone=NEXTCLOUD:100m
        inactive=60m;

    fastcgi_cache_key "$scheme$request_method$host$request_uri";
    #add_header X-Cache $upstream_cache_status;

    # FastCGI cache-read setting
    map $request_uri $skip_cache {

        # Default: Don't read from cache (set $skip_cache = 1)
        default 1;

        # Try to get following URLs from cache (set $skip_cache = 0)
        ~*/thumbnail.php 0;
        ~*/apps/galleryplus/ 0;
        ~*/apps/gallery/ 0;
    }

    map $request_uri $skip_cache {

        # Default: Store in the cache (set $no_cache = 0)
        default 0;

        # Don't store user settings pages (set $no_cache = 1)
        ~*index.php/settings 1;
    }

    # FastCGI cache-write setting
    map $http_cookie $no_cache {

        # Default: Store in the cache (set $no_cache = 0)
        default 0;

        # Don't store cookies (set $no_cache = 1)
        ~SESS 1; # Drupal session cookie
        ~wordpress_logged_in 1; # Wordpress session cookie

    }


Virtual Server
--------------


Secured HTTPS Server
^^^^^^^^^^^^^^^^^^^^

.. code-block:: nginx

    # ----------------------------------------
    # Secured HTTPS Server
    # ----------------------------------------
    server {

        # ------------------------------
        # Connection Settings

        server_name cloud.example.net;

        # IPv6 public global address
        listen [fdc1:d89e:b128:2615::31]:443 ssl http2 bind;

        # IPv4 private local address
        listen 172.27.126.31:443 ssl http2 bind;

        # IPv4 private address (Port-forwarded from NAT firewall/router)
        listen 172.27.126.30:443 ssl http2;


        # ------------------------------
        # TLS Settings

        # TLS certificate (chained) and private key
        ssl_certificate /etc/dehydrated/certs/cloud.example.net/fullchain.pem;
        ssl_certificate_key /etc/dehydrated/certs/cloud.example.net/privkey.pem;

        # Enable stapling of online certificate status protocol (OCSP) response
        include ocsp-stapling.conf;

        # TLS certificate of signing CA (to validate OCSP response when stapling)
        ssl_trusted_certificate /etc/dehydrated/certs/cloud.example.net/chain.pem;

        # OCSP stapling response file (pre-generated)
        ssl_stapling_file /etc/dehydrated/certs/cloud.example.net/ocsp.der;

        # TLS session cache (type:name:size)
        ssl_session_cache shared:cloud.example.net:10m;


        # ------------------------------
        # Common Server Settings

        # Expect-CT HTTP Reposnse Header
        include server-conf.d/20_expect-ct.conf;

        # Strict Transport Security (HSTS) HTTP Reposnse Header
        include server-conf.d/20_hsts-preload.conf;

        # Report-To HTTP Securiry Header
        include server-conf.d/20_report-to.conf;

        # Client Security HTTP Response Headers
        include server-conf.d/30_client-security-headers.conf;

        # Nginx locations for common shared files
        include server-conf.d/80_nginx-shared.conf;


        # ------------------------------
        # Custom Server Settings

        # Advertise our onion service to Tor-Browser clients
        more_set_headers
            "Onion-Location: http://chaimoob4oogheej9EeYoo8Aiy5UajeecheeGhu4ioBoegie6ohf3Pha.onion$request_uri";

        # Replace our default CORS header for Jitsi (https://meet.zrh.init7.net/)
        more_set_headers
            'Cross-Origin-Resource-Policy: cross-origin';

        # Servers Public Documents Root
        root /var/www/example.net/nextcloud;

        # Nextcloud Web application
        include webapps/nextcloud.conf;

        # Logging
        #log_not_found on;
        #log_subrequest on;
        #error_log /var/log/nginx/nextcloud-error.log info;
        #access_log /var/log/nginx/nextcloud-access.log main;
    }

Tor Onion Service
^^^^^^^^^^^^^^^^^

.. code-block:: nginx

    # ----------------------------------------
    # Tor Onion Service
    # ----------------------------------------

    server {

        # Tor Onion Service Name
        server_name chaimoob4oogheej9EeYoo8Aiy5UajeecheeGhu4ioBoegie6ohf3Pha.onion;

        # Tor Onion Service Socket
        #listen unix:/run/tor-cloud.example.net.sock;
        listen 127.0.0.31:80;


        #
        # Common Server Settings
        #

        # Server Security and Access Restrictions
        include server-conf.d/10_server-security.conf;

        # Client Security HTTP Response Headers
        include server-conf.d/30_client-security-headers.conf;

        # COEP, COOP and CORP HTTP Reposnse Header
        include server-conf.d/40_coep-coop-corp.conf;

        # Custom HTTP Error Pages
        include server-conf.d/50_error-pages.conf;

        # Fallback favicon
        #include server-conf.d/60_favicon.conf;

        # Nginx locations for common shared files
        include server-conf.d/80_nginx-shared.conf;

        # Servers Public Documents Root
        root /var/www/example.net/nextcloud;

        # Nextcloud Web application
        include webapps/nextcloud.conf;

        # Logging
        #log_not_found on;
        #log_subrequest on;
        #error_log /var/log/nginx/nextcloud-error.log info;
        #access_log /var/log/nginx/nextcloud-access.log main;
    }


Unsecured HTTP Site and Aliases
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: nginx

    # ----------------------------------------
    # Unsecured HTTP Site and Aliases
    # ----------------------------------------
    server {

        server_name cloud.example.net;

        # IPv6 public global address
        listen [fdc1:d89e:b128:2615::31]:80 deferred;

        # IPv4 private local address
        listen 172.27.126.31:80 deferred;

        # IPv4 private address (Port-forwarded from NAT firewall/router)
        listen 172.27.126.30:80;

        # Redirect to HTTPS on proper hostname
        return 301 https://$server_name$request_uri;

        # Logging
        #log_not_found on;
        #log_subrequest on;
        #error_log /var/log/nginx/nextcloud-error.log info;
        #access_log /var/log/nginx/nextcloud-access.log main;
    }


Nextcloud Web-Application
-------------------------

.. code-block:: nginx

    # ***********************************************
    # Nginx Web-App Configuration for Nextcloud
    # Nginx 1.21.6, PHP-FPM 7.4.3, Nextcloud 24.0.0
    # ***********************************************

    # See https://docs.nextcloud.com/server/24/admin_manual/installation/nginx.html

    # Max. upload file size
    client_max_body_size 16G;
    fastcgi_buffers 64 4K;

    # HTTP response headers borrowed from Nextcloud `.htaccess`
    more_set_headers "X-Robots-Tag: none";
    more_set_headers "X-Frame-Options: SAMEORIGIN";
    more_set_headers "X-XSS-Protection: 1; mode=block";

    # Specify how to handle directories -- specifying `/index.php$request_uri`
    # here as the fallback means that Nginx always exhibits the desired behaviour
    # when a client requests a path that corresponds to a directory that exists
    # on the server. In particular, if that directory contains an index.php file,
    # that file is correctly served; if it doesn't, then the request is passed to
    # the front-end controller. This consistent behaviour means that we don't need
    # to specify custom rules for certain paths (e.g. images and other assets,
    # `/updater`, `/ocm-provider`, `/ocs-provider`), and thus
    # `try_files $uri $uri/ /index.php$request_uri`
    # always provides the desired behaviour.
    index index.php index.html /index.php$request_uri;

    # Default Cache-Control policy
    expires 1m;

    # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
    location = / {
        if ( $http_user_agent ~ ^DavClnt ) {
            return 302 /remote.php/webdav/$is_args$args;
        }
    }

    location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
    }

    # Make a regex exception for `/.well-known` so that clients can still
    # access it despite the existence of the regex rule
    # `location ~ /(\.|autotest|...)` which would otherwise handle requests
    # for `/.well-known`.
    location ^~ /.well-known {

        # Properly redirect CarDav & CaldDv clients
        location = /.well-known/carddav { return 301 /remote.php/dav/; }
        location = /.well-known/caldav { return 301 /remote.php/dav/; }

        # Let Nextcloud handled all other .well-knowns
        location ^~ /.well-known { return 301 /index.php$uri; }

        try_files $uri $uri/ =404;
    }

    # Rules to hide certain paths from clients
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/) {
        return 404;
    }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
        return 404;
    }

    # Ensure this block, which passes PHP files to the PHP process, is above the blocks
    # which handle static assets (as seen below). If this block is not declared first,
    # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
    # to the URI, resulting in a HTTP 500 error response.
    location ~ \.php(?:$|/) {
        fastcgi_split_path_info ^(.+?\.php)(/.*)$;
        set $path_info $fastcgi_path_info;
        try_files $fastcgi_script_name =404;
        include fastcgi_params;

        # Avoid sending the security headers twice
        fastcgi_param modHeadersAvailable false;

        # Enable pretty urls
        fastcgi_param front_controller_active true;

        fastcgi_pass php-nextcloud-backend;
        fastcgi_intercept_errors off;
        fastcgi_request_buffering off;
        fastcgi_cache NEXTCLOUD;
        fastcgi_cache_valid 200 60m;

        # Don't read PHP's response from the cache if $skip_cache is <> 0
        fastcgi_cache_bypass $skip_cache;

        # Don't save PHP's response in the cache if $no_cache is <> 0
        fastcgi_no_cache $no_cache;

        fastcgi_cache_methods GET HEAD;

        # Logging
        #error_log /var/log/nginx/nextcloud-error.log info;
        #access_log /var/log/nginx/nextcloud-access.log main;

    }

    location ~ \.(?:css|js|svg|gif)$ {
        try_files $uri /index.php$request_uri;
        # Cache-Control policy borrowed from `.htaccess`
        expires 6M;
        # Optional: Don't log access to assets
        access_log off;
    }

    location ~ \.woff2?$ {
        try_files $uri /index.php$request_uri;
        # Cache-Control policy borrowed from `.htaccess`
        expires 7d;
        # Optional: Don't log access to assets
        access_log off;
    }

    location / {
        try_files $uri $uri/ /index.php$request_uri;
    }

    # -*- mode: nginx; indent-tabs-mode: nil; tab-width: 4; -*-



