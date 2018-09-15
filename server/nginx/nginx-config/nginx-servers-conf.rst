Server Default Settings
=======================

.. contents::
  :local:


In the example server defined earlier there is a **include** statement to load
various settings, which every website should use for enhanced performance and
security.

.. code-block:: nginx
   :linenos:

    # Common Server Settings
    include     server-conf.d/*.conf;


.. note::

    Some web applications like ownCloud might provide their own settings which
    may duplicate or even conflict with some of the settings defined here. In
    this case only some of the configuration files might be included
    individually.

Since the order in which these configurations are applied does matter, the files
are numbered.

The configuration options are explained in the files comments


Server Security
---------------

In the file
:download:`/etc/nginx/server-conf.d/10_server-security.conf
</server/config-files/etc/nginx/server-conf.d/10_server-security.conf>`
we set various security related settings which every website should include..

.. literalinclude:: /server/config-files/etc/nginx/server-conf.d/10_server-security.conf
    :language: nginx
    :linenos:


Client Security
---------------

In the file
:download:`/etc/nginx/server-conf.d/20_client-security.conf
</server/config-files/etc/nginx/server-conf.d/20_client-security.conf>`
we set various security related settings which every website should include..

.. literalinclude:: /server/config-files/etc/nginx/server-conf.d/20_client-security.conf
    :language: nginx
    :linenos:


Error Pages
-----------

The file :download:`/etc/nginx/server-conf.d/50_error-pages.conf </server/config-files/etc/nginx/server-conf.d/50_error-pages.conf>`
defines a  fallback error page for every HTTP client error (error-4xx.html) and
HTTP server error (http-5xx.html). Individual error pages for specific errors
will be delivered to clients if they exist (i.e. :file:`error-404.html`).

.. literalinclude:: /server/config-files/etc/nginx/server-conf.d/50_error-pages.conf
    :language: nginx
    :linenos:


No Transform
------------

The file :download:`/etc/nginx/server-conf.d/70_no_transform.conf </server/config-files/etc/nginx/server-conf.d/70_no_transform.conf>`.

.. literalinclude:: /server/config-files/etc/nginx/server-conf.d/70_no_transform.conf
    :language: nginx
    :linenos:


Browser Cache
-------------

The cache of our visitors web browsers is the best place to improve the website
performance for our visitors and reduce the load on our servers.

We use file
:download:`/etc/nginx/server-defaults/80_client-cache-control.conf
</server/config-files/etc/nginx/server-conf.d/80_client-cache-control.conf>`
to control what and how long is cached by our visitors browser cache.

.. literalinclude:: /server/config-files/etc/nginx/server-conf.d/80_client-cache-control.conf
    :language: nginx
    :linenos:






