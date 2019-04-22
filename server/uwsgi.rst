Python Web Application Server
=============================

uWSGI is a web application server container

The uWSGI project aims at developing a full stack for building hosting
services. It is our choice for serving web applications written in the Python
programming language on our Nginx web server.


Prerequisites
-------------


python-dev
^^^^^^^^^^

python-dev is an operating-system level package which contains extended
development tools for building Python modules.

Run the following command to install python-dev::

	$ sudo apt install python-dev


pip
^^^

pip is a package manager which will help us to install the application packages
that we need.

Run the following commands to install the probably outdated pip from the
Ubuntu software repository and subsequently let it upgrade itself::

	$ sudo apt install python-pip
	$ sudo -H pip install --upgrade pip


virtualenv
^^^^^^^^^^

It is best to contain a Python application within its own environment together
with all of its dependencies. An environment can be best described (in simple
terms) as an isolated location (a directory) where everything resides. For
this purpose, a tool called virtualenv is used.

Run the following to install virtualenv using :file:`pip`::

	$ sudo -H pip install virtualenv


uWSGI Installation
------------------

uWSGI has a really fast development cycle, so the Ubuntu software packages may
not be up to date.

Nevertheless we install it from the Ubuntu software packages::

	$ sudo apt install uwsgi uwsgi-emperor uwsgi-plugin-python uwsgi-plugin-python3


After installation completes, there will be ...

 * uWSGI binaries
	* :file:`/usr/bin/uwsgi_python`
	* :file:`/usr/bin/uwsgi_python27`
	* :file:`/usr/bin/uwsgi_python3`
	* :file:`/usr/bin/uwsgi_python35`
 * uWSGI configuration directory in :file:`/etc/uwsgi-emperor/`
 * SysV service objects in
    * :file:`/etc/init.d/uwsgi`
    * :file:`/etc/init.d/uwsgi-emperor`
    * :file:`/etc/default/uwsgi` and
    * :file:`/etc/default/uwsgi-emperor`
 * logrotate scripts
	* :file:`/etc/logrotate.d/uwsgi`
	* :file:`/etc/logrotate.d/uwsgi-emperor`
 * Defaults and samples in :file:`/usr/share/uwsgi/`
 * Documentation
	* :file:`/usr/share/doc/uwsgi`
	* :file:`/usr/share/doc/uwsgi-core`
	* :file:`/usr/share/doc/uwsgi-emperor`
	* :file:`/usr/share/doc/uwsgi-plugin-python`
	* :file:`/usr/share/doc/uwsgi-plugin-python3`

Debian (and Ubuntu) specific configuration and runtime behavior information is
found in :file:`/usr/share/doc/uwsgi/README.Debain.gz`:

::
	$ zless /usr/share/doc/uwsgi/README.Debain.gz


Apps Configuration & Activation
-------------------------------

Place your uWSGI app configuration files in the directory
:file:`/etc/uwsgi/apps-available/`

To activate them add a symlink in the directory :file:`/etc/uwsgi/apps-enabled/`::

	$ ln -s /etc/uwsgi/apps-available/example-app.ini /etc/uwsgi/apps-enabled/


It then should be available as system service and started after every reboot::

	$ sudo service start uwsgi example-app


Nginx Backend
-------------

Nginx can connect to any app by using its distinct socket
(:file:`/run/uwsgi/app/example-app/socket`) as backend server.

Place the following lines outside of any virtual server configuration:

.. code-block:: nginx

	#
	# Example uWSGI app backend
	#
	upstream example-app {
	    server unix:/run/uwsgi/app/example-app/socket;
	}


This is the general idea, it may vary according to instructions of the app.


References
----------

 * `Digital Ocean Tutorial: How to Deploy Python WSGI Applications Using uWSGI Web Server with Nginx <https://www.digitalocean.com/community/tutorials/how-to-deploy-python-wsgi-applications-using-uwsgi-web-server-with-nginx>`_

 * `The uWSGI project Documentation <https://uwsgi-docs.readthedocs.io/en/latest/>`_

