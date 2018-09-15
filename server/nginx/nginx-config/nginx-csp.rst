Content Security Policies
=========================

CSP-Builder
-----------

Easily integrate Content-Security-Policy headers into your web application,
either from a JSON configuration file, or programatically.

`CSP Builder <https://github.com/paragonie/csp-builder>`_ was created by
`Paragon Initiative Enterprises <https://paragonie.com/>`_ as part of their
effort to encourage better application security practices.

Check out their other `open source projects <https://paragonie.com/projects>`_
too.


Installation
^^^^^^^^^^^^

Download and install the script sources::

    $ cd /usr/local/lib
    $ sudo git clone https://github.com/paragonie/csp-builder.git
    $ sudo chown -R ${USER} csp-builder
    $ cd csp-builder
    $ composer install


Create the calling script in
:download:`/usr/local/bin//build_csp.php </server/scripts/nginx_build_csp.php>`:

.. literalinclude:: /server/scripts/nginx_build_csp.php
    :language: php
    :linenos:

Make it executable::

    $ sudo chmod +x /usr/local/bin/nginx_build_csp.php


JSON Policy Files
^^^^^^^^^^^^^^^^^

Create a directory to store the JSON policy files and Nginx CSP files::

    $ sudo mkdir /etc/nginx/csp


Create your JSON files like the following simple example :file:`example.net.csp.json`:

.. code-block:: json
   :linenos:

    {
        "base-uri": {
            "self": true
        },
        "default-src": [],
        "frame-ancestors": [],
        "img-src": {
            "self": true
        },
        "plugin-types": [],
        "style-src": {
            "self": true,
            "unsafe-inline": true
        },
        "script-src": {
            "self": true,
            "unsafe-inline": true
        },
        "upgrade-insecure-requests": false,
        "block-all-mixed-content": true
    }


Policy Generation
^^^^^^^^^^^^^^^^^

To build the HTTP headers for this policy, use the name of the JSON file but
without the ".json" extension ...::

    $ /etc/nginx/csp
    $ nginx_build_csp.php example.net.csp

If successful, a Nginx configuration file
:file:`/etc/nginx/csp/example.net.csp.conf` has been created.

.. code-block:: nginx
   :linenos:

    add_header Content-Security-Policy "base-uri 'self'; default-src 'none'; frame-ancestors 'none'; img-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';";


If you get errors, most likely your JSON file isn't syntactically correct. You
can check your syntax on `<https://jsonchecker.com/>`_


CSP Directives
^^^^^^^^^^^^^^

As of the time this writing (November 2017) the CSP builder understands the following CSP directives:

 * `base-uri <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/base-uri>`_
 * `block-all-mixed-content <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/block-all-mixed-content>`_
 * `child-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/child-src>`_
 * `connect-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/connect-src>`_
 * `default-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/default-src>`_
 * `font-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/font-src>`_
 * `form-action <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/form-action>`_
 * `frame-ancestors <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-ancestors>`_
 * `frame-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/frame-src>`_
 * `img-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/img-src>`_
 * `manifest-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/manifest-src>`_
 * `media-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/media-src>`_
 * `object-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/object-src>`_
 * `plugin-types <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/plugin-types>`_
 * `report-only <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-only>`_
 * `report-uri <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/report-uri>`_
 * `script-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/script-src>`_
 * `style-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/style-src>`_
 * `upgrade-insecure-requests <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/upgrade-insecure-requests>`_


The following are currently not supported:

 * `disown-opener <https://w3c.github.io/webappsec-csp/#directive-disown-opener>`_ - `See notes here <https://html.spec.whatwg.org/multipage/browsers.html#disowned-its-opener>`_
 * referrer - **obsolete**, use :doc:`Referrer-Policy HTTP header </server/nginx/nginx-config/nginx-servers-conf>` instead.
 * reflected-xss - **obsolete**, use :doc:`X-XSS-Protection HTTP header </server/nginx/nginx-config/nginx-servers-conf>` instead.
 * `require-sri-for <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/require-sri-for>`_
 * `sandbox <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/sandbox>`_
 * `worker-src <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy/worker-src>`_ - will use :file:`default-source` as fallback, if absent.
