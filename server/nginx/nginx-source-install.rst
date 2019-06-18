Install from Source
===================

.. contents::
    :local:


This article describes how to install `Nginx <http://nginx.org/>`_ by compiling
it from its source-code on a Ubuntu Server.

This is a little bit more complicated then a default install, but allows us to
use the most current version and install additional 3rd-party modules like
brotli compression, new ciphers with a more recent OpenSSL version and
ngx_cache_purge.

..  note::
    All the following steps are also available as
    :download:`downloadable </server/scripts/nginx-source-install.sh>` shell
    script.


Software Package Repository
---------------------------
The Nginx project releases its own ready-made Ubuntu software packages.

The 'mainline' releases contain the latest stable code as recommended for use
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

    $ sudo apt update


Install required Software
-------------------------

Get all the stuff needed for building nginx and modules::

    $ sudo apt install autoconf build-essential devscripts git \
        libgd-dev libgeoip-dev libpcre3 libpcre3-dev libxslt1-dev libxml2-dev \
        python-dev python2.7 unzip zlib1g-dev
    $ sudo apt build-dep nginx
    $ sudo apt-get install


Set Version Numbers
-------------------

Set the `Nginx Changes <https://nginx.org/en/CHANGES>`_ version number::

    $ export NGX_VERSION=1.17.0


Set the `OpenSSL <https://github.com/openssl/openssl/releases>`_ version::

    $ export OPENSSL_VERSION=1.1.1c


Set the
`ngx_cache_purge module <https://github.com/FRiCKLE/ngx_cache_purge/releases>`_
version::

    $ export NCP_VERSION=2.3


Set the
`Headers-More module <https://github.com/openresty/headers-more-nginx-module/releases>`_ version::

    $ export NHM_VERSION=0.33


Set the
`ngx-fancyindex module <https://github.com/aperezdc/ngx-fancyindex/releases>`_ version::

    $ export FANCYINDEX_VERSION=0.4.3


Get the Source Code
-------------------

Prepare source code directory::

    $ sudo mkdir -p /usr/local/src/nginx
    $ sudo chown $USER /usr/local/src/nginx
    $ sudo chmod u+rwx /usr/local/src/nginx


Source Code for Nginx
^^^^^^^^^^^^^^^^^^^^^

Get the Nginx package source code::

    $ cd /usr/local/src/nginx
    $ apt source nginx

Modules::

    $ apt source nginx-module-geoip nginx-module-image-filter nginx-module-xslt


Source Code for OpenSSL
^^^^^^^^^^^^^^^^^^^^^^^

Get and verify OpenSSL source::

    $ cd /usr/local/src/nginx
    $ wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
    $ wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
    $ gpg2 --verify openssl-${OPENSSL_VERSION}.tar.gz.asc
    $ tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz
    $ rm openssl-${OPENSSL_VERSION}.tar.gz


Build and install a standalone OpenSSL binary (optional)::

    $ cd /usr/local/src/nginx/openssl-${OPENSSL_VERSION}/
    $ sudo mkdir -p /opt/openssl-${OPENSSL_VERSION}
    $ ./config --prefix=/opt/openssl-${OPENSSL_VERSION} no-shared
    $ make clean
    $ make depend
    $ make
    $ make test
    $ sudo make install_sw
    $ /opt/openssl-${OPENSSL_VERSION}/bin/openssl version


Source Code for Brötli
^^^^^^^^^^^^^^^^^^^^^^

Get and install `Brötli <https://github.com/google/brotli>`_ source::

    $ cd /usr/local/src/nginx
    $ git clone https://github.com/google/brotli.git
    $ cd brotli
    $ sudo python setup.py install


Get `Brötli Nginx module source <https://github.com/google/ngx_brotli>`_::

    $ cd /usr/local/src/nginx
    $ git clone https://github.com/google/ngx_brotli.git


Make sure that the git submodule has been checked out::

    cd /usr/local/src/nginx/ngx_brotli
    git submodule update --init


Source Code for Cache Purge Module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Download the source code for the
`ngx_cache_purge <https://github.com/FRiCKLE/ngx_cache_purge>`_ module::

    $ cd /usr/local/src/nginx
    $ wget -O ngx_cache_purge-${NCP_VERSION}.zip \
        https://github.com/FRiCKLE/ngx_cache_purge/archive/${NCP_VERSION}.zip
    $ unzip ngx_cache_purge-${NCP_VERSION}.zip


Source Code for Headers More Module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Download the source code for the
`headers-more-nginx-module <https://github.com/openresty/headers-more-nginx-module>`_::


    $ cd /usr/local/src/nginx
    $ wget -O ngx_headers_more-${NHM_VERSION}.tar.gz \
        https://github.com/openresty/headers-more-nginx-module/archive/v${NHM_VERSION}.tar.gz
    $ tar -xzf ngx_headers_more-${NHM_VERSION}.tar.gz


Source Code for the Fancy Index Module
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Download the source code for the
`ngx-fancyindex <https://github.com/aperezdc/ngx-fancyindex>`_ module::

    $ cd /usr/local/src/nginx
    $ wget -O ngx-fancyindex-${FANCYINDEX_VERSION}.tar.gz \
        https://github.com/aperezdc/ngx-fancyindex/archive/v${FANCYINDEX_VERSION}.tar.gz
    $ tar -xzf ngx-fancyindex-${FANCYINDEX_VERSION}.tar.gz


Package Configuration
---------------------

Open the file :download:`/usr/local/src/nginx/nginx-${NGX_VERSION}/debian/rules
<rules>` with your editor.

Add or modify lines of the `./configure` commands in the Debian
rules file. You have the following choices:

Remove unneeded modules by removing lines::

    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_image_filter_module \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-mail \
    --with-stream \


Add additional modules::

    --with-http_xslt_module \
    --add-module=/usr/local/src/nginx/headers-more-nginx-module-${NHM_VERSION} \
    --add-module=/usr/local/src/nginx/nginx-fancyindex-${FANCYINDEX_VERSION} \
    --add-module=/usr/local/src/nginx/ngx_brotli \
    --add-module=/usr/local/src/nginx/ngx_cache_purge-${NCP_VERSION} \


Set location of the OpenSSL source libraries instead of the system default:

.. code-block:: make

    --with-openssl=/usr/local/src/nginx/openssl-${OPENSSL_VERSION} \


Don't forget to escape preceding lines with a backslash ``\``.

.. literalinclude:: rules
    :caption: /usr/local/src/nginx/nginx-${NGX_VERSION}/debian/rules
    :language: make


Increase Package Version
^^^^^^^^^^^^^^^^^^^^^^^^

Ubuntu will always remember, that our package was not installed from the
official package source, and will therefore always offer to "upgrade" our package
to the "newest version", which is essentially the same version we already have.
By increasing the version number of our package, we don't get bothered with
update notfications::

    $ cd /usr/local/src/nginx/nginx-${NGX_VERSION}
    $ dch

An editor opens where the package changes can be entered.

The scheme used by Ubuntu software packages is:

.. code-block:: text

    <Upstream Version>-<Debian Version>~Ubuntu<Ubuntu Package Version>

A new version number  and your name are already pre-filled:

.. code-block:: text

 nginx (1.13.1-1~xenialubuntu1) UNRELEASED; urgency=medium
 .
   * Change server name reported in HTTP responses
   * Build against OpenSSL 1.1.0c
   * Added dynamic XSLT module
   * Added 3rd-party brotli compression module
   * Added 3rd-party cache purge module
   * Added 3rd-party Google PageSpeed module
   * Changed mail module to dynamic


After saving and closing the file the customized package source is ready for
building.


Building the Software
---------------------

In case you want to restart from a clean build::

    $ cd /usr/local/src/nginx/nginx-${NGX_VERSION}
    $ dpkg-buildpackage -rfakeroot -Tclean


Build the Nginx package as follows::

    $ cd /usr/local/src/nginx/nginx-${NGX_VERSION}
    $ dpkg-buildpackage -rfakeroot -uc -b


Depending on your options the building process might take anything form five
minutes to over a half-hour to complete.


Package Installation
--------------------

Install the package(s)::

    $ cd /usr/local/src/nginx
    $ sudo dpkg --install nginx_${NGX_VERSION}-1~xenialubuntu1_amd64.deb

Nginx is installed and started as system service `nginx` running as user `nginx`.

Configuration files are found in the :file:`/etc/nginx` directory.

Prevent future releases to automatically overwrite our customized packages::

    $ sudo apt-mark hold nginx

Test
----

Show version number and available modules::

    $ nginx -V
    nginx version: nginx/1.13.1
    built by gcc 5.4.0 20160609 (Ubuntu 5.4.0-6ubuntu1~16.04.4)
    built with OpenSSL 1.1.0f  25 May 2017
    TLS SNI support enabled
