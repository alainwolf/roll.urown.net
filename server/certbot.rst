
.. image:: certbot-logo.*
    :alt: Certbot Logo
    :align: right
    :height: 105px
    :width: 306px

Certbot ACME Client
===================

`Certbot <https://certbot.eff.org/>`_ is a free, open source software tool made
by the `Electronic Frontier Foundation <https://www.eff.org/>`_ (:term:`EFF`)
for automatically using `Let’s Encrypt <https://letsencrypt.org/>`_
certificates.

.. contents::
  :local:

While we are using the :doc:`/server/dehydrated` to automate certificate
renewals for many domains, hostnames and services on our main server, the
:doc:`/server/mail/postfix-mx` only provide one single service (SMTP) and
hostname. We therefore use Certbot here, with a simpler setup.


Installation
------------
.. warning::

    Certbot is supporting ECDSA certficates since **version 1.10**, which was
    released on December 1st, 2020. As of Janaury 2021 the Certbot version
    distributed with the Ubuntu software packages repository is only 0.40.0!

The Certbot version in the Ubuntu software packages repository is outdated, we
need to remove it, if it has been installed before::

    $  sudo apt remove certbot

We then install the SNAP package as per
`instructions <https://certbot.eff.org/lets-encrypt/ubuntufocal-other>`_::

    $ sudo snap install core; sudo snap refresh core
    $ sudo snap install --classic certbot
    $ sudo ln -s /snap/bin/certbot /usr/bin/certbot

Configuration
-------------

To achieve highest possible compatibility with all mail servers out there, while
still being able to use the highest available more modern encryption standards,
with servers who support them, we use both, traditinoal RSA and modern ECDSA
(elliptic curve cryptogrphy) certficates.

Certbot accepts a global configuration file that applies its options to all
invocations of Certbot. Certificate specific configuration choices should be set
in the .conf files that can be found in /etc/letsencrypt/renewal.


Global Configuration
^^^^^^^^^^^^^^^^^^^^

:file:`/etc/letsencrypt/cli.ini`

.. code-block:: ini
    :linenos:

    # Because we are using logrotate for greater flexibility, disable the
    # internal certbot logrotation.
    max-log-backups = 0

    # Options used in the renewal process
    [renewalparams]

    # This is a mail server. there is no webserver running here
    authenticator = standalone

    account = 0123456789abcdefg0123456789abcde
    server = https://acme-v02.api.letsencrypt.org/directory

    # Don't break our DANE TLSA DNS records, therefore don't create new keys,
    reuse_key = True


RSA Certificate
^^^^^^^^^^^^^^^

Create the RSA certificate::

    $ sudo certbot certonly --domain maeve.example.net --key-type rsa \
        --cert-name maeve.example.net-rsa


ECDSA Certficate
^^^^^^^^^^^^^^^^

Create the ECDSA certificate::

    $ sudo certbot certonly --domain maeve.example.net --key-type ecdsa \
        --cert-name maeve.example.net-ecdsa


Pre Renewal Hook
^^^^^^^^^^^^^^^^

:file:`/etc/letsencrypt/renewal-hooks/pre/ufw-open-ports`::

    #!/usr/bin/env bash
    echo "Opening ports on the firewall for certificate renewal."
    ufw allow 80/tcp
    ufw allow 443/tcp


Post Renewal Hook
^^^^^^^^^^^^^^^^^

:file:`/etc/letsencrypt/renewal-hooks/post/ufw-close-ports`::

    #!/usr/bin/env bash
    echo "Closing ports on the firewall."
    ufw delete allow 80/tcp
    ufw delete allow 443/tcp


Deploy Hook
^^^^^^^^^^^

:file:`/etc/letsencrypt/renewal-hooks/deploy/keycertchain`::

    #!/usr/bin/env bash
    echo "Concatenating key, cert and chain into a signle file."
    cat ${RENEWED_LINEAGE}/privkey.pem ${RENEWED_LINEAGE}/fullchain.pem \
        >/etc/postfix/chainfile.pem


:file:`/etc/letsencrypt/renewal-hooks/deploy/postfix-reload`::

    #!/usr/bin/env bash
    echo "Reloading Postfix."
    postfix reload

