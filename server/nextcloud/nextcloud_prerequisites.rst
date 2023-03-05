Prerequisite Software for Nextcloud
===================================

.. contents::
    :local:

This document assumes the following software and services have been already
installed and configured:

* :doc:`/server/nginx/index`
* :doc:`/server/mariadb/index`
* :doc:`/server/redis`


PHP 8.2
-------

Nextcloud version 25.0.4 as released in February 2023
`recommends <https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#prerequisites-for-manual-installation>`_
PHP version 8.2. Official Ubuntu 22.04 packages provide PHP version 8.2.

.. note::

    Its prefectly safe to install and run different PHP versions on the same
    system.

To install PHP version 8.2, the
`PHP PPA of Ondřej Surý <https://launchpad.net/~ondrej/+archive/ubuntu/php>`_
is a recommended addition to your systems repositories::

    $ sudo add-apt-repository ppa:ondrej/php

After that you need to explicitly choose the 8.2 version of any PHP related
package you want to install.

Nextcloud also requires and recommends the following PHP modules installed, if
using Nginx as web server and MariaDB as database server:

=========== ===========================
PHP Module  Ubuntu Package
=========== ===========================
`ctype`     Provided by `php8.2-common`
`curl`      `php8.2-curl`
`dom`       Provided by `php8.2-xml`
`filter`    Built-in with `php8.2-fpm`
`GD`        `php8.2-gd`
`hash`      Built-in with `php8.2-fpm`
`JSON`      Provided by `php8.2-fpm`
`libxml`    Provided by `php8.2-xml`
`mbstring`  `php8.2-mbstring`
`openssl`   Built-in with `php8.2-fpm`
`posix`     Provided by `php8.2-common`
`session`   Built-in with `php8.2-fpm`
`SimpleXML` Provided by `php8.2-xml`
`XMLReader` Provided by `php8.2-xml`
`XMLWriter` Provided by `php8.2-xml`
`zip`       Built-in with `php8.2-fpm`
`zlib`      Built-in with `php8.2-fpm`
`pdo_mysql` `php8.2-mysql`
`fileinfo`  Provided by `php8.2-common`
`bz2`       `php8.2-bz2`
`intl`      `php8.2-intl`
`ldap`      Not needed in our setup
`smbclient` Not needed in our setup
`ftp`       Not needed in our setup
`imap`      `php8.2-imap`
`bcmath`    `php8.2-bcmath`
`gmp`       `php8.2-gmp`
`exif`      Built-in with `php8.2-fpm`
`apcu`      `php8.2-apcu`
`memcached` `php8.2-memcached`
`redis`     `php8.2-redis`
`imagick`   `php8.2-imagick`
`pcntl`     Provided by `php8.2-cli`
`phar`      Provided by `php8.2-common`
=========== ===========================

`php8.2--cli` and `php8.2-common` are automatically installed by `php8.2--fpm`.

Package installation command::

    $ sudo apt install php8.2-fpm php8.2-cli \
        php8.2-apcu \
        php8.2-bcmath \
        php8.2-bz2 \
        php8.2-curl \
        php8.2-gd \
        php8.2-gmp \
        php8.2-imagick \
        php8.2-imap \
        php8.2-intl \
        php8.2-mbstring \
        php8.2-memcached \
        php8.2-mysql \
        php8.2-redis \
        php8.2-xml \
        php8.2-zip


The installation process will start the PHP 8.2 service automatically. Since
it needs configuration we stop it for the time being::

    $ sudo systemctl stop php8.2-fpm


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
