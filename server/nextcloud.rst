:orphan:


Nextcloud
=========

Prerequisites
-------------

Webserver

Mailserver

DNS Records

PHP

::

    $ sudo apt install php-fpm
        php-curl php-gd php-xml php-mbstring php-zip \
        php-mysql \
        php-bz2 php-intl \
        php-bcmath php-gmp \
        php-apcu php-redis \
        php-imagick ffmpeg
        libreoffice-writer-nogui libreoffice-math-nogui libreoffice-calc-nogui \
        libreoffice-draw-nogui libreoffice-impress-nogui

Auto-installed:
  - php-cli (installed by php-fpm)
  - php-common (installed by php-fpm)
  - php-json (installed by php-common)

Not available as apt package:
  - PHP module ctype (provided by php-common)
  - PHP module dom (provided by php-xml)
  - PHP module hash (only on FreeBSD)
  - PHP module iconv (provided by php-common)
  - PHP module libxml (provided by php-xml)
  - PHP module openssl (built-in of php-fpm)
  - PHP module posix (provided by php-common)
  - PHP module session (built-in of php-fpm)
  - PHP module SimpleXML (provided by php-xml)
  - PHP module XMLReader (provided by php-xml)
  - PHP module XMLWriter (provided by php-xml)
  - PHP module zlib (built-in of php-fpm)
  - PHP module fileinfo (provided by php-common)
  - PHP module exif (built-in of php-fpm)
  - PHP module pcntl (provided by php-cli)

  - PHP module fileinfo (highly recommended, enhances file analysis performance)
  - PHP module bz2 (recommended, required for extraction of apps)
  - PHP module intl (increases language translation performance and fixes sorting of non-ASCII characters)
  - PHP module bcmath (for passwordless login)
  - PHP module gmp (for passwordless login)
  - PHP module exif (for image rotation in pictures app)
  - PHP module apcu (for memory caching)
  - PHP module memcached
  - PHP module redis (for Transactional File Locking)
  - PHP module imagick (for preview generation)
  - ffmpeg (for preview generation)
  - LibreOffice (for preview generation)
  - PHP module pcntl (enables command interruption by pressing ctrl-c)

php-fpm has the following built.in:
  - Core
  - date
  - filter
  - hash
  - libxml
  - openssl
  - pcre
  - Reflection
  - session
  - sodium
  - SPL
  - standard
  - zlib.

php-commn Provides:
  - php-calendar,
  - php-ctype,
  - php-exif,
  - php-ffi,
  - php-fileinfo,
  - php-ftp,
  - php-iconv,
  - php-pdo,
  - php-phar,
  - php-posix,
  - php-shmop,
  - php-sockets,
  - php-sysvmsg,
  - php-sysvsem,
  - php-sysvshm,
  - php-tokenizer,
