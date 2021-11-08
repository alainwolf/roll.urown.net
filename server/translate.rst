Translate
=========

`LibreTranslate <https://github.com/LibreTranslate/LibreTranslate#libretranslate>`_
is a free and open source machine translation API, entirely self-hosted. Unlike
other APIs, it doesn't rely on proprietary providers such as Google or Azure to
perform translations. Instead, its translation engine is powered by the open
source
`Argos Translate library <https://github.com/argosopentech/argos-translate>`_.

.. contents::

.. note::

    The steps below are loosly based on the
    `LibreTranslate-init <https://github.com/argosopentech/LibreTranslate-init>`_
    script for Ubuntu 20.04.


Prerequisites
-------------

* :doc:`/server/nginx/index`
* :doc:`/server/uwsgi`
* `git` - fast, scalable, distributed revision control system

Add a system user for `libretranslate`::

    $ sudo adduser --system --ingroup www-data \
        --home /var/lib/libretranslate libretranslate


Setup
-----

Update packages::

    $ sudo apt update


Python Language Tools
^^^^^^^^^^^^^^^^^^^^^

Install the following prereqesite packages::

    $ sudo apt install \
        build-essential \
        python3-virtualenv \
        python3-pip \
        python-is-python3 \
        libssl-dev libffi-dev


PyICU is a Python extension which enables Python to use the ICU C++ libraries.
Thus the ICU libraries need to be installed (and and pkg-config to find them).

See
`Pyicu fails to install on Ubuntu 20.04 <https://community.libretranslate.com/t/pyicu-fails-to-install-on-ubuntu-20-04/23>`_

Install PyICU dependencies::

    $ sudo apt install libicu-dev python3-icu pkg-config


LibreTranslate Source-Code
^^^^^^^^^^^^^^^^^^^^^^^^^^

Clone the LibreTranslate source code::

    $ cd /var/lib/libretranslate
    $ sudo -u libretranslate git clone https://github.com/LibreTranslate/LibreTranslate.git


Python Virtual Environment
^^^^^^^^^^^^^^^^^^^^^^^^^^

Setup a virtual Python environment in the source directoy::

    $ sudo -u libretranslate virtualenv LibreTranslate/env


Installation
^^^^^^^^^^^^

Activate the Python Virtual Environment::

    $ sudo -u libretranslate bash
    $ source LibreTranslate/env/bin/activate
    (env)$


.. note::

    The following commands must be excuted from inside the Python virtual
    environment.

Install `gunicorn` and `LibreTranslate` from within the Python virtual
environment::

    (env)$ LibreTranslate/env/bin/pip install gunicorn
    (env)$ LibreTranslate/env/bin/pip install -e LibreTranslate/

This might take a few minutes to complete. After completion you can start
LibreTranslate manually for a test-drive.

Test-run on `172.27.88.28` port `5000`::

    (env)$ ~/LibreTranslate/env/bin/libretranslate --host 172.27.88.28

It will immediately start updating its languages models, which might take a
while. Point you browser to `http://172.27.88.28:5000`.

Pres :kbd:`Ctrl+C` to terminate the server.

Exit the Python virtual environment and the libretranslate user environment::

    (env)$ exit


Systemd Socket and Service
--------------------------

Systemd Socket
^^^^^^^^^^^^^^

:file:`/etc/systemd/system/libretranslate.socket`:

.. literalinclude:: /server/config-files/etc/systemd/system/libretranslate.socket


Systemd Service
^^^^^^^^^^^^^^^

:file:`/etc/systemd/system/libretranslate.service`:

.. literalinclude:: /server/config-files/etc/systemd/system/libretranslate.service


Reload Systemd configuration and activate the new service::

    $ sudo systemctl daemon-reload
    $ sudo systemctl start libretranslate
    $ sudo systemctl enable libretranslate.service libretranslate.socket


Nginx Configuration
-------------------

Web Server
^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/nginx/servers-available/translate.example.net.conf
    :language: nginx
    :linenos:


Web Application
^^^^^^^^^^^^^^^

.. literalinclude:: /server/config-files/etc/nginx/webapps/libretranslate.conf
    :language: nginx
    :linenos:
