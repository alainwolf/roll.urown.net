Prerequisite Software for Nextcloud
===================================

.. contents::
    :local:

This document assumes the following software and services have been already
installed and configured:

* :doc:`/server/nginx/index`
* :doc:`/server/mariadb/index`
* :doc:`/server/redis`


PHP 8.0
-------

Nextcloud Hub version 24 as released in May 2022
`recommends <https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation>`_
PHP version 8.0. Official Ubuntu 20.04 packages provide PHP version 7.4 only.

.. note::

    Its prefectly safe to install and run different PHP versions on the same
    system.

To install PHP version 8.0, the
`PHP PPA of Ondřej Surý <https://launchpad.net/~ondrej/+archive/ubuntu/php>`_
needs to be added to your systems repositories::

    $ sudo add-apt-repository ppa:ondrej/php

After that you need to explicitly choose the 8.0 version of any PHP related
package you want to install.

Nextcloud also requires and recommends the following PHP modules installed, if
using Nginx as web server and MariaDB as database server:

=========== ===========================
PHP Module  Ubuntu Package
=========== ===========================
`ctype`     Provided by `php8.0-common`
`curl`      `php8.0-curl`
`dom`       Provided by `php8.0-xml`
`filter`    Built-in with `php8.0-fpm`
`GD`        `php8.0-gd`
`hash`      Built-in with `php8.0-fpm`
`JSON`      Provided by `php8.0-fpm`
`libxml`    Provided by `php8.0-xml`
`mbstring`  `php8.0-mbstring`
`openssl`   Built-in with `php8.0-fpm`
`posix`     Provided by `php8.0-common`
`session`   Built-in with `php8.0-fpm`
`SimpleXML` Provided by `php8.0-xml`
`XMLReader` Provided by `php8.0-xml`
`XMLWriter` Provided by `php8.0-xml`
`zip`       Built-in with `php8.0-fpm`
`zlib`      Built-in with `php8.0-fpm`
`pdo_mysql` `php8.0-mysql`
`fileinfo`  Provided by `php8.0-common`
`bz2`       `php8.0-bz2`
`intl`      `php8.0-intl`
`ldap`      Not needed in our setup
`smbclient` Not needed in our setup
`ftp`       Not needed in our setup
`imap`      `php8.0-imap`
`bcmath`    `php8.0-bcmath`
`gmp`       `php8.0-gmp`
`exif`      Built-in with `php8.0-fpm`
`apcu`      `php8.0-apcu`
`memcached` `php8.0-memcached`
`redis`     `php8.0-redis`
`imagick`   `php8.0-imagick`
`pcntl`     Provided by `php8.0-cli`
`phar`      Provided by `php8.0-common`
=========== ===========================

`php8.0--cli` and `php8.0-common` are automatically installed by `php8.0--fpm`.

Package installation command::

    $ sudo apt install php8.0-fpm php8.0-cli \
        php8.0-apcu \
        php8.0-bcmath \
        php8.0-bz2 \
        php8.0-curl \
        php8.0-gd \
        php8.0-gmp \
        php8.0-imagick \
        php8.0-imap \
        php8.0-intl \
        php8.0-mbstring \
        php8.0-memcached/focal \
        php8.0-mysql \
        php8.0-redis \
        php8.0-xml \
        php8.0-zip


The installation process will start the PHP 8.0 service automatically. Since
it needs configuration we stop it for the time being::

    $ sudo systemctl stop php8.0-fpm


Other Software
--------------

=========== =============================
Software    Ubuntu Package(s)
=========== =============================
ffmpeg      `ffmpeg`
LibreOffice * `libreoffice-writer-nogui`
            * `libreoffice-math-nogui`
            * `libreoffice-calc-nogui`
            * `libreoffice-draw-nogui`
            * `libreoffice-impress-nogui`
=========== =============================

Package installation command::

    $ sudo apt install ffmpeg \
        libreoffice-writer-nogui \
        libreoffice-math-nogui \
        libreoffice-calc-nogui \
        libreoffice-draw-nogui \
        libreoffice-impress-nogui
