:orphan:

Router Certificate
==================

..  note::

    This is valid for Turris Omnia Routers which uses **lighttpd** as a web
    server.

..  note::

    This is for DNS-API validation with PowerDNS.

Like most network devices, the Turris Omnia Router automatically creates its
own self-signed certificate while setting itself up.

But since we run our devices under our domain name, and have enabled HSTS
for all subdomains, it will not be possible to add an exception for that
self-signed certificate in your browser.

We therefore need a valid certificate issued by a CA that is trusted by the
browser.

Furthermore we don't want to touch the web-server configuration, as these
might get lost on router firmware updates.

To achieve this we use the acme.sh shell script to request a certificate from
Let's Encrypt.

- By using the ACME DNS-01 API for domain validation there is no need for
  connections to the router during validation, which avoids the need to
  firewall reconfigurations.
- By simply replacing the existing self-signed certificate file with the CA
  issued certificate file, we avoid the need to touch the Turris Omnia web
  server configuration.


Prerequisites
-------------

* Your Internet domain;
* :doc:`/server/dns/powerdns` authoritative server;
* :doc:`/server/dns/powerdns-admin` web interface;


PowerDNS API Key
^^^^^^^^^^^^^^^^

Login on your PowerDNS-Admin web interface and create an API key for your
router.

Role: **User**

Description: *Your Routers Hostname*

Accounts: *Account of your domain name*

Domains: **example.net**

The API key is displayed only once right after creation. Make sure to copy it.


Software Installation
---------------------

Install the `acme` and `acme-dnsapi` packages.

Don't install the `luci-app-acme` package. It doesn't support the lighttpd web
server.

::

    $ opkg update
    $ opkg install acme acme-dnsapi


Scripts will be installed in :file:`/usr/lib/acme/` and configurations will be
created in :file:`/etc/acme/`.

Upgrade
^^^^^^^

`acme.sh` contains a built-in command to upgrade itself to the newest version::


    /usr/lib/acme/acme.sh --home "/usr/lib/acme" --config-home "/etc/acme" \
        --upgrade --auto-upgrade

The `--auto-upgrade` options sets a configuration to upgrade automatically in
the future.


Configuration
--------------

Edit the file :file:`/etc/config/acme`:

 .. code-block:: shell
    :caption: /etc/config/acme
    :linenos:

    config acme
        option state_dir '/etc/acme'
        option account_email 'admin@example.net'
        option debug 1

    config cert 'router'
        option enabled '1'
        option use_staging '1'
        list domains 'router.example.net'
        option keylength 'ec-256'
        option validation_method 'dns'
        option dns "dns_pdns"
        list credentials 'PDNS_Url="https://admin.example.net"'
        list credentials 'PDNS_ServerId="localhost"'
        list credentials 'PDNS_Token="****************"'
        option update_uhttpd '0'
        option update_nginx '0'
        option update_apache '0'


Initialize
----------

register a new account with Let's Encrypt::

    /usr/lib/acme/acme.sh --home "/usr/lib/acme" --config-home "/etc/acme" \
        --server letsencrypt --register-account --email admin@example.net

Set default chain::

    /usr/lib/acme/acme.sh --home "/usr/lib/acme" --config-home "/etc/acme" \
        --issue --server letsencrypt \
        --set-default-chain --preferred-chain "ISRG Root X1"

Request a new certificate::

    export PDNS_Url="https://admin.example.net"
    export PDNS_ServerId="localhost"
    export PDNS_Token="****************"
    /usr/lib/acme/acme.sh --home "/usr/lib/acme" --config-home "/etc/acme" \
        --issue --server letsencrypt \
        --domain "router.example.net" --dns "dns_pdns" --keylength "ec-256"


Customize for Turris
--------------------

Create a script to install the certificate as expected by the lighttpd server
and also reload the server:

 .. code-block:: shell
    :caption: /etc/config/acme/turris_acme
    :linenos:

    #!/usr/bin/env ash
    # shellcheck shell=dash

    export PDNS_Url="https://admin.example.net"
    export PDNS_ServerId="localhost"
    export PDNS_Token="****************"

    _ACME_HOME="/etc/acme"
    _CERT_DOMAIN="router.example.net"
    _CERT_DIR="${_ACME_HOME}/${_CERT_DOMAIN}_ecc"
    _CERT_FILE="${_CERT_DIR}/${_CERT_DOMAIN}.cer"
    _KEY_FILE="${_CERT_DIR}/${_CERT_DOMAIN}.key"
    _TURRIS_KEYCERT_FILE="/etc/lighttpd-self-signed.pem"

    # Daily certificate renewal
    /usr/lib/acme/acme.sh --cron \
        --home "/usr/lib/acme" --config-home "$_ACME_HOME"

    # Check if the certificate has changed
    if [ "$_CERT_FILE" -nt "$_TURRIS_KEYCERT_FILE" ]; then

        # Create combined keycert file
        cat "$_CERT_FILE" "$_KEY_FILE" > "$_TURRIS_KEYCERT_FILE"

        # Restart the web server (reload is not enough)
        /etc/init.d/lighttpd restart
    fi


The Cron Job
------------

 .. code-block:: shell
    :caption: /etc/cron.d/acme
    :linenos:

    MAILTO=""
    # min hour day month weekday user  command
      54  22   *   *     *       root  /etc/acme/turris_acme
