MTA-STS
=======

.. contents::
    :local:

SMTP Mail Transfer Agent Strict Transport Security (:term:`MTA-STS`) is a
mechanism enabling mail service providers to declare their ability to receive
Transport Layer Security (:term:`TLS`) secure :term:`SMTP` connections, and to
specify whether sending SMTP servers should refuse to deliver to :term:`MX`
hosts that do not offer TLS with a trusted server certificate.

MTA-STS does not require the use of :term:`DNSSEC` to authenticate
:term:`DANE` :term:`TLSA` records but relies on the certificate authority (CA)
system and a trust-on-first-use (:term:`TOFU`) approach to avoid
interceptions.

The TOFU model allows a degree of security similar to that of :term:`HPKP`,
reducing the complexity but without the guarantees on first use offered by
DNSSEC.

In addition, MTA-STS introduces a mechanism for failure reporting and a
report-only mode, enabling progressive roll-out and auditing for compliance.

MTA-STS was is described in :rfc:`8461`.


DNS Records
-----------

TLSRPT DNS TXT
^^^^^^^^^^^^^^

A number of protocols exist for establishing encrypted channels between
:term:`SMTP` Mail Transfer Agents, including :term:`STARTTLS`, :term:`DANE`
:term:`TLSA` and :term:`MTA-STS`.

These protocols can fail due to misconfiguration or active attack, leading to
undelivered messages or delivery over unencrypted or unauthenticated channels.

This DNS TXT entry informs any sending system to where it can send reports
with statistics and specific information about potential failures with the
recipient domain.

The recipient domain can then use this information to both detect potential
attacks and diagnose unintentional misconfigurations.

::

    _smtp._tls.example.net IN TXT v=TLSRPTv1; rua=mailto:postmaster@example.net.


Also add CNAME records for all other domains which use your mail servers as MX.

::

    _smtp._tls.example.org IN CNAME _smtp._tls.example.net.
    _smtp._tls.example.com IN CNAME _smtp._tls.example.net.


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

    pdnsutil add-record example.net _smtp._tls TXT "v=TLSRPTv1; rua=mailto:postmaster@example.net."
    pdnsutil add-record example.org _smtp._tls CNAME _smtp._tls.example.net
    pdnsutil add-record example.com _smtp._tls CNAME _smtp._tls.example.net


MTA-STS DNS TXT
^^^^^^^^^^^^^^^

The MTA-STS DNS TXT is used to declare that a policy is available to any mail
server who is asking.

::

    _mta-sts.example.net IN TXT v=STSv1; id=20160831085700Z


The "id" field serves as a reference for policy updates.

Also add CNAME records for all other domains which use your mail servers as MX.

::

    _mta-sts.example.org IN CNAME _mta-sts.example.net.
    _mta-sts.example.com IN CNAME _mta-sts.example.net.


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

    pdnsutil add-record example.net _mta-sts TXT "v=STSv1; id=$(date --utc +%Y%m%d%H%M%SZ)"
    pdnsutil add-record example.org _smtp._tls CNAME _mta-sts.example.net
    pdnsutil add-record example.com _smtp._tls CNAME _mta-sts.example.net


MTA-STS Subdomain
^^^^^^^^^^^^^^^^^

The MTA-STS subdomain will serve the policy via HTTPS. As any web service it needs a DNS entry.

::

    mta-sts.example.net IN    A  192.0.2.40
    mta-sts.example.net IN AAAA  2001:db8::40


Also add CNAME records for all other domains which use your mail servers as MX.

::

    mta-sts.example.org IN CNAME mta-sts.example.net
    mta-sts.example.com IN CNAME mta-sts.example.net


With PowerDNS we can use :file:`pdnsutil` as *root* to do this::

    pdnsutil add-record example.net mta-sts A 192.0.2.40
    pdnsutil add-record example.net mta-sts AAAA 2001:db8::40
    pdnsutil add-record example.org mta-sts CNAME mta-sts.example.net
    pdnsutil add-record example.com mta-sts CNAME mta-sts.example.net



Web Server
----------


TLS Certificates
^^^^^^^^^^^^^^^^

We use :doc:`dehydrated </server/dehydrated>` to request additional
certificates for the HTTPS policy server.

Add the following lines to :file:`/etc/dehydrated/domains.txt`

::

    ...

    MTP MTA Strict Transport Security (MTA-STS)
    mta-sts.example.net mta-sts.example.org mta-sts.example.com

    ...


Nginx Virtual Host
^^^^^^^^^^^^^^^^^^

Setup the virtual host in Nginx to deliver the policy over HTTPS.

Create a new virtual host :download:`/etc/nginx/sites-available/mta-sts.conf
</server/config-files/etc/nginx/servers-available/mta-sts.example.net.conf>`
for Nginx:

.. literalinclude:: /server/config-files/etc/nginx/servers-available/mta-sts.example.net.conf
    :linenos:
    :caption: mta-sts.example.net.conf
    :name: mta-sts.example.net.conf


Postfix Server Integration
--------------------------

The `postfix-mta-sts-resolver <https://github.com/Snawoot/postfix-mta-sts-resolver/>`_
translates any published MTA-STS policy to a postfix TLS client policy.

Policies are cached in :doc:`/server/redis` and will be available on all our
mail servers trough replication.


Installation
^^^^^^^^^^^^

The Postfix MTA-STS Resolver is available in the Ubuntu software package
repository::

    $ sudo apt install postfix-mta-sts-resolver

After installation you will find the two programs :file:`/usr/bin/mta-sts-query`
and :file:`/usr/bin/mta-sts-daemon`, a systemd service unit
:file:`/lib/systemd/system/postfix-mta-sts-resolver.service` a configuration
file :file:`/etc/mta-sts-daemon.yml` and a new system user and group called
"**_mta-sts**".


Configuration
^^^^^^^^^^^^^

Configuration is stored in the file :file:`/etc/mta-sts-daemon.yml`:

.. code-block:: yaml
    :linenos:
    :caption: mta-sts-daemon.yml
    :name: mta-sts-daemon.yml

    host: 127.0.0.1
    port: 8461
    reuse_port: true
    shutdown_timeout: 20
    cache:
        type: redis
        options:
            address: "redis://127.0.0.1:6384/0?timeout=5"
            db: 0
            password: "ZlsQPlZAwMRpBgzEvwH2J7jsWkcpC7Xr"
            minsize: 5
            maxsize: 25
    default_zone:
        strict_testing: false
        timeout: 4
    zones:
        myzone:
            strict_testing: false
            timeout: 4


Service Dependencies
^^^^^^^^^^^^^^^^^^^^

Since we cache the TLS policies for Postfix in a Redis server, we want the Redis
cache to be up and running, before the MTA-STS service starts. To make the
`postfix-mta-sts-resolver.service` dependent on the
`redis-server@postfix-tls.service`.

You can create a Systemd override file easily with the help of the
:command:`systemctl` command::

    $ sudo systemctl edit postfix-mta-sts-resolver.service

This will start your editor with an empty file, where you can add your own
custom Systemd service configuration options.

.. code-block:: ini

    [Unit]
    After=redis-server@postfix-tls.service
    BindsTo=redis-server@postfix-tls.service

After you save and exit of the editor, the file will be saved as
:file:`/etc/systemd/system/postfix-mta-sts-resolver.service.d/override.conf`
and Systemd will reload its configuration.


Postfix Configuration
^^^^^^^^^^^^^^^^^^^^^

In :file:`/etc/postfix/main.cf`::

    smtp_tls_policy_maps =
        socketmap:unix:/mta-sts/mta-sts.sock


Refrences
---------

 * `MTA STS validator <https://aykevl.nl/apps/mta-sts/>`_
 * `Postfix MTA-STS Resolver <https://github.com/Snawoot/postfix-mta-sts-resolver/>`_

# -*- mode: rst; indent-tabs-mode: nil; tab-width: 4; -*-
