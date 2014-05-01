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
    # echo "deb http://nginx.org/packages/mainline/ubuntu/ `lsb_release -sc` nginx" \
        > /etc/apt/sources.list.d/nginx.org-mainline.list
    # echo "deb-src http://nginx.org/packages/mainline/ubuntu/ `lsb_release -sc` nginx" \
        >> /etc/apt/sources.list.d/nginx.org-mainline.list
    # exit


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

    $ sudo apt-get install build-essential unzip


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


Download the source code for the ngx_cache_purge module::

    $ wget -O ngx_cache_purge-2.1.zip https://github.com/FRiCKLE/ngx_cache_purge/archive/2.1.zip
    $ unzip ngx_cache_purge-2.1.zip


Download the source code for the Google pagespeed module::

    $ wget -O ngx_pagespeed-v1.7.30.4-beta https://github.com/pagespeed/ngx_pagespeed/archive/v1.7.30.4-beta.zip
    $ unzip ngx_pagespeed-v1.7.30.4-beta
    $ cd ngx_pagespeed-1.7.30.4-beta/
    $ wget https://dl.google.com/dl/page-speed/psol/1.7.30.4.tar.gz
    $ tar -xzvf 1.7.30.4.tar.gz
    $ cd ..


Package Configuration
---------------------
Open the file :file:`/usr/local/src/nginx-1.7.0/debian/rules` with your editor.

Add the following lines to every `./configure` command in the rules file::

    --add-module=/usr/local/src/ngx_pagespeed-1.7.30.4-beta \
    --add-module=/usr/local/src/ngx_cache_purge-2.1
      
Don't forget to escape preceeding lines with a backslash ``\``.

{% include_code Nginx Debian Rules lang:make ./rules %}


Building the Software
---------------------

Build the package as follows::

    $ cd nginx-1.7.0
    $ dpkg-buildpackage -rfakeroot -uc -b
    $ cd ..

This is the rigth time to get a nice cup of coffee.


Package Installation
--------------------
Install the package::

    $ sudo dpkg --install nginx_1.7.0-1~trusty_amd64.deb

Nginx is installed and started as system service `nginx` running as user `nginx`.

Configuration files are found in the :file:`/etc/nginx` directory.

Prevent future releases to automatically overwrite our customized package::

    $ sudo apt-mark hold nginx


Test
----

Show version number and available modules::

    $ nginx -V

