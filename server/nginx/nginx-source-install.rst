Install Nginx from Source
==========================

This article describes how to install `Nginx <http://nginx.org/>`_ by compiling it 
from sourcecode on Ubuntu Server.

This is a litte bit more complicated then a default install, but allows us to 
use the most current version and install additional 3rd-party modules like 
Google PageSpeed and ngx_cache_purge.


Software Package Repository
---------------------------
The Nginx project relaeases its own readymade Ubuntu software packages.

The 'mainline' releases contain the latest stable code as recommendet for use 
by the project.

Add these software repositories to the systems package list::

    $ sudo -s
     echo "deb http://nginx.org/packages/mainline/ubuntu/ `lsb_release -sc` nginx" \
        > /etc/apt/sources.list.d/nginx.org-mainline.list
    $ echo "deb-src http://nginx.org/packages/mainline/ubuntu/ `lsb_release -sc` nginx" \
        >> /etc/apt/sources.list.d/nginx.org-mainline.list
    $ exit


All software packages released by the project are signed with a GPG key.

Add the signing key to the systems trusted keyring::

    $ wget -O - http://nginx.org/keys/nginx_signing.key | sudo apt-key add -


For working with the source code later, the signing key needs to be added to 
the personal trusted keyring too::

    $ wget -O - http://nginx.org/keys/nginx_signing.key | \
        gpg --no-default-keyring --keyring ~/.gnupg/trustedkeys.gpg --import -


Update the systems packages list::

    $ sudo apt-get update


Install required Software
-------------------------

Get essential stuff needed for building packages in general::

    $ sudo apt-get install build-essential devscripts unzip


Get all the stuff needed for building the nginx package::

    $ sudo apt-get build-dep nginx


Get the Source Code
-------------------

Prepare source code directory::

    $ sudo mkdir -p /usr/local/src
    $ sudo chown $USER /usr/local/src
    $ sudo chmod u+rwx /usr/local/src
    $ cd /usr/local/src


Get the nginx package source code::

    $ apt-get source nginx


Download the source code for the 
`ngx_cache_purge <https://github.com/FRiCKLE/ngx_cache_purge>`_ module::

    $ NCP_VERSION=2.3
    $ wget -O ngx_cache_purge-${NCP_VERSION}.zip \
        https://github.com/FRiCKLE/ngx_cache_purge/archive/${NCP_VERSION}.zip
    $ unzip ngx_cache_purge-${NCP_VERSION}.zip


Download the source code for the 
`Google pagespeed <https://github.com/pagespeed/ngx_pagespeed>`_ module::

    $ NPS_VERSION=1.9.32.3
    $ wget -O ngx_pagespeed-${NPS_VERSION}-beta.zip \
        https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip
    $ unzip ngx_pagespeed-${NPS_VERSION}-beta.zip
    $ cd ngx_pagespeed-release-${NPS_VERSION}-beta/
    $ wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz
    $ tar -xzvf ${NPS_VERSION}.tar.gz
    $ cd ..


Package Configuration
---------------------
Open the file :file:`/usr/local/src/nginx-1.7.11/debian/rules` with your editor.

Add the following lines to every `./configure` command in the rules file::

    --add-module=/usr/local/src/ngx_cache_purge-2.3 \
    --add-module=/usr/local/src/ngx_pagespeed-1.9.32.3-beta

Don't forget to escape preceeding lines with a backslash ``\``.

.. code-block:: make
   :linenos:
   :emphasize-lines: 56,57,97,98

    #!/usr/bin/make -f

    #export DH_VERBOSE=1
    CFLAGS ?= $(shell dpkg-buildflags --get CFLAGS)
    LDFLAGS ?= $(shell dpkg-buildflags --get LDFLAGS)
    WITH_SPDY := $(shell printf "Source: nginx\nBuild-Depends: libssl-dev (>= 1.0.1)\n" | \
        dpkg-checkbuilddeps - >/dev/null 2>&1 && \
        echo "--with-http_spdy_module")

    %:
        dh $@ 

    override_dh_auto_configure: configure_debug

    override_dh_strip:
        dh_strip -Xdebug

    override_dh_auto_build:
        dh_auto_build
        mv objs/nginx objs/nginx.debug
        CFLAGS="" ./configure \
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_stub_status_module \
            --with-http_auth_request_module \
            --with-mail \
            --with-mail_ssl_module \
            --with-file-aio \
            $(WITH_SPDY) \
            --with-cc-opt="$(CFLAGS)" \
            --with-ld-opt="$(LDFLAGS)" \
            --with-ipv6 \
            --add-module=/usr/local/src/ngx_cache_purge-2.3 \
            --add-module=/usr/local/src/ngx_pagespeed-1.9.32.3-beta 
        dh_auto_build

    configure_debug:
        CFLAGS="" ./configure \
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --error-log-path=/var/log/nginx/error.log \
            --http-log-path=/var/log/nginx/access.log \
            --pid-path=/var/run/nginx.pid \
            --lock-path=/var/run/nginx.lock \
            --http-client-body-temp-path=/var/cache/nginx/client_temp \
            --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
            --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
            --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
            --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
            --user=nginx \
            --group=nginx \
            --with-http_ssl_module \
            --with-http_realip_module \
            --with-http_addition_module \
            --with-http_sub_module \
            --with-http_dav_module \
            --with-http_flv_module \
            --with-http_mp4_module \
            --with-http_gunzip_module \
            --with-http_gzip_static_module \
            --with-http_random_index_module \
            --with-http_secure_link_module \
            --with-http_stub_status_module \
            --with-http_auth_request_module \
            --with-mail \
            --with-mail_ssl_module \
            --with-file-aio \
            $(WITH_SPDY) \
            --with-cc-opt="$(CFLAGS)" \
            --with-ld-opt="$(LDFLAGS)" \
            --with-ipv6 \
            --with-debug \
            --add-module=/usr/local/src/ngx_cache_purge-2.3 \
            --add-module=/usr/local/src/ngx_pagespeed-1.9.32.2-beta

    override_dh_auto_install:
        dh_auto_install
        /usr/bin/install -m 644 debian/nginx.conf debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/win-utf debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/koi-utf debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/koi-win debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/mime.types debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/scgi_params debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/fastcgi_params debian/nginx/etc/nginx/
        /usr/bin/install -m 644 conf/uwsgi_params debian/nginx/etc/nginx/
        /usr/bin/install -m 644 html/index.html debian/nginx/usr/share/nginx/html/
        /usr/bin/install -m 644 html/50x.html debian/nginx/usr/share/nginx/html/
        /usr/bin/install -m 644 debian/nginx.vh.default.conf debian/nginx/etc/nginx/conf.d/default.conf
        /usr/bin/install -m 644 debian/nginx.vh.example_ssl.conf debian/nginx/etc/nginx/conf.d/example_ssl.conf
        /usr/bin/install -m 755 objs/nginx  debian/nginx/usr/sbin/


Increase Package Version
^^^^^^^^^^^^^^^^^^^^^^^^

Ubuntu will always remember, that our package was not installed from the 
official package source, and will therefore always offer to "upgrade" our package 
to the "newest version", which is essentially the same version we already have. 
By increasing the version number of our package, we don't get bothered with 
update notfications::

    $ cd /usr/local/src/nginx-1.7.11
    $ dch

An editor opens where the package changes can be entered. 

The scheme used by Ubuntu software packages is:

.. code-block:: text

    <Upstream Version>-<Debian Version>~Ubuntu<Ubuntu Package Version>

A new version number  and your name are already pre-filled:

.. code-block:: text

    nginx (1.7.11-1~trustyubuntu1) UNRELEASED; urgency=medium

      * Added Google pagespeed module
      * Added ngx_cache_purge module

     -- First Last <user@example.com>  Tue, 28 Oct 2014 20:35:00 +0100

    nginx (1.7.11-1~trusty) trusty; urgency=low

      * 1.7.11

     -- Sergey Budnevitch <sb@nginx.com>  Tue, 28 Oct 2014 16:35:00 +0400


After saving and closing the file the customized package source is ready for 
building.


Building the Software
---------------------

Build the package as follows::

    $ cd nginx-1.7.11
    $ dpkg-buildpackage -rfakeroot -uc -b
    $ cd ..

The building process might take around 5 minutes to complete.


Package Installation
--------------------

Install the package::

    $ sudo dpkg --install nginx_1.7.11-1~trustyubuntu1_amd64.deb

Nginx is installed and started as system service `nginx` running as user `nginx`.

Configuration files are found in the :file:`/etc/nginx` directory.

Prevent future releases to automatically overwrite our customized package::

    $ sudo apt-mark hold nginx


Test
----

Show version number and available modules::

    $ nginx -V

Remove Apache
-------------

The default webserver on Ubuntu is Apache. If any previously installed package
also installed the Apache web server as a dependency, it need to be
uninstalled, as multiple web servers will fight each  other over the HTTP ports
on the system::

    $ sudo apt-get remove apache2
    $ sudo apt-get autoremove
