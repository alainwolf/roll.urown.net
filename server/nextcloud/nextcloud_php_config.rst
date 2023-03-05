PHP Configuration for Nextcloud
===============================

.. contents::
    :local:

System's PHP FPM Configuration
------------------------------

With the
`PHP FastCGI Process Manager (FPM) <https://www.php.net/manual/en/install.fpm.php>`_
one can define individual pools of PHP servers. Each of these pools has its
own process management can run under a different system user-id and listen on
different ports and sockets, maintain their own logs, can be started and
stopped without affecting other pools and many more features.

These comes in handy when running a Nextcloud server along with unrelated PHP
scripts on the same server, or running multiple Nextcloud instances on the
same server.

However, only a subset of the configuration options from :file:`php.ini` are
available as options in the pool configuration. Some options can only be
defined system-wide for a installed PHP version and will be used by PHP-FPM
pools of that PHP version.

Some of these system-wide options are required for Nextcloud's PHP environment.
Others are recommendations but will yeld great performance benefits.

Unfortunately all PHP-FPM pools will be affected, but most of the time they
will benefit too. If somehow some of these required system-wide PHP settings
have negative effects on other pools serving other PHP applications, it might
be possible to run them in another version of PHP installed on the system.

Open the file :file:`/etc/php/8.0/fpm/php.ini`.

.. code-block:: ini

    ; Decides whether PHP may expose the fact that it is installed on the server
    ; (e.g. by adding its signature to the Web server header).  It is no security
    ; threat in any way, but it makes it possible to determine whether you use PHP
    ; on your server or not.
    ; http://php.net/expose-php
    ; Default: On
    expose_php = Off

    ; Set the error reporting level. The parameter is either an integer ;
    representing a bit field, or named constants. The named constants are ;
    described here: <https://www.php.net/manual/en/errorfunc.constants.php>`_
    ; https://www.php.net/manual/en/errorfunc.configuration.php#ini.error-reporting
    ; Default: E_ALL
    ; While this option can be set from anywhere (PHP_INI_ALL), you still want
    ; to explicitly set it here as a system-wide default for a production
    ; environment.
    error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
    display_errors = Off
    display_startup_errors = Off
    log_errors = Off
    html_errors = Off

    ; This directive determines which super global arrays are registered when PHP
    ; starts up. G,P,C,E & S are abbreviations for the following respective super
    ; globals: GET, POST, COOKIE, ENV and SERVER. There is a performance penalty
    ; paid for the registration of these arrays and because ENV is not as commonly
    ; used as the others, ENV is not recommended on productions servers. You
    ; can still get access to the environment variables through getenv() should you
    ; need to.
    ; http://php.net/variables-order
    ; Default Value: "EGPCS"
    variables_order = "GPCS"

    ; This directive determines which super global data (G,P & C) should be
    ; registered into the super global array REQUEST. If so, it also determines
    ; the order in which that data is registered. The values for this directive
    ; are specified in the same manner as the variables_order directive,
    ; EXCEPT one. Leaving this value empty will cause PHP to use the value set
    ; in the variables_order directive. It does not mean it will leave the super
    ; globals array REQUEST empty.
    ; http://php.net/request-order
    ; Default Value: None
    request_order = "GP"

    ; Whether errors should be printed to the screen as part of the output or if
    ; they should be hidden from the user.
    ; http://php.net/display-errors
    ; Default: On
    ; While this option can be set from anywhere (PHP_INI_ALL), you still want
    ; to explicitly set it here as a system-wide default for a production
    ; environment.


PHP FPM Pool for Nextcloud
---------------------------


Pool Configuration
^^^^^^^^^^^^^^^^^^

.. code-block:: ini

    short_open_tag = Off
    output_buffering = 4096
    zlib.output_compression = Off
    max_execution_time = 30
    max_input_time = 60
    memory_limit = 4G

