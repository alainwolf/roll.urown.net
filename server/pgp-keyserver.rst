PGP Key Server
==============

.. image:: pgp-keyserver.*
    :alt: OPDS Logo
    :align: right


.. contents::
    :depth: 1
    :local:
    :backlinks: top


A Public Key Shelf
------------------

Keyservers play an important role in public key cryptography, as the name
implies, the public keys need to be distributed publicly.

 * The recipient of a signed message needs the public key of the sender in order
   to verify the signature of the message.

 * The sender of an encrypted message needs the public key of the recipient in
   order to encrypt the message.

Keyservers act as central repositories to distribute these public keys.

In OpenPGP clients connect to OpenPGP keyservers to import public keys it needs,
if they are not already stored in its local public key-ring. Keys also need to
be updated, after they have changed or revoked.

OpenPGP clients and keyservers use the HKP (OpenPGP HTTP Keyserver Protocol)
protocol or HKPS for the the TLS secured version.


How Can I Trust a Keyserver?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Since the keyserver plays such an important role we have to put a great deal of
trust in the keyserver and its operators:

 * A keyserver could provide you with his own keys instead of the ones you ask
   for and subsequently decrypt your messages sent to them or send you signed
   messages with fake signatures.

 * By asking the server for specific keys, you also disclose with whom you
   communicate.

So the short answer to the question above is: **You can't!**


The Keyserver Pool
^^^^^^^^^^^^^^^^^^

But to mitigate the risk of anyone surveying or controlling this important part
of the "Web of Trust" keyservers have been organized in `large pools of
individual keyservers <https://sks-keyservers.net/overview-of-pools.php>`_.

A pool is maintained in DNS. When a OpenPGP client needs to talk to a keyserver
he asks for the IP address of the host ``hkps.pool.sks-keyservers.net``. A DNS
lookup for this host returns many IPv4 and IPv6 addresses of which the client
will randomly select one to connect to.

The domain *sks-keyservers.net* is `secured
<http://dnsviz.net/d/sks-keyservers.net/dnssec/>`_ with DNSSEC and therefore can
not by spoofed easily.

The keyservers in the pool are run by organizations and individuals voluntarily
all over the Internet. Everybody can setup and run a keyserver and thus become
part of the pool.


The Synchronizing OpenPGP Key Server (SKS)
------------------------------------------

To run you own keyserver, be it for your own personal use or network, or to be
part of the pool, run the `Synchronizing OpenPGP Key Server (SKS)
<https://bitbucket.org/skskeyserver/sks-keyserver>`_ software on your server.

SKS is an OpenPGP key server that correctly handles all OpenPGP features defined
in :rfc:`2440`, including photoID packages and multiple subkeys.

This keyserver implementation uses an efficient and reliable reconciliation
algorithm to keep the database in sync with other SKS servers. Additionally it
can both send and receive PKS style sync emails.


Requirements
------------


Storage Space
^^^^^^^^^^^^^

 * **11 GB** download of a full database dump;

 * **23 GB** total after import database import;


Preparations
------------


SKS Mailing List
^^^^^^^^^^^^^^^^

Join the `SKS mailing list <http://lists.nongnu.org/mailman/listinfo/sks-devel>`_
where you can ask for peers and will get notified about software issues and
updates of SKS.


Database Dump
^^^^^^^^^^^^^

Rather than starting with an empty database and attempting to populate it by
syncing with other keyservers (a bad idea because it loads up your peers with
lots of traffic and will probably fail anyway with deadlocks in the conflict
resolution system) we'll grab a static dump from an existing SKS server.
Currently
`known sources <https://bitbucket.org/skskeyserver/sks-keyserver/wiki/KeydumpSources>`_ are:

 * ftp://keyserver.mattrude.com/ generated every day at 8:00 UTC
 * https://keys.niif.hu/keydump/ generated every Monday
 * http://stueve.us/keydump/ generated every Saturday

As of November 2018 the archive size is approximately 11G, holding over 5
million keys in 90 files.

The download can take several hours. Thats why we start this first in `screen`
session and let it run.

.. warning::

    Don't download from the `current` directory on the server! If the server
    creates new dump files while you are downloading you will have to start over
    again. Use the directory with the latest date.

The dump is divided into a bunch of individual numbered files so you'll need to
fetch all of them.

::

    $ screen sudo -sH
    $ mkdir -p /var/lib/sks/dump
    $ cd /var/lib/sks/dump
    $ wget --continue \
           -r \
           --page-requisites \
           --execute robots=off \
           --timestamping \
           --level=1 \
           --cut-dirs=3 \
           --no-host-directories \
           https://keyserver.mattrude.com/dump/2018-02-13/


Proceed to `import the database dump <#database-import>`_, when the download
completes.


SKS Daemon User
^^^^^^^^^^^^^^^

For security reasons its best to run the daemon with its own unprivileged user
profile. Create this user on the server system with the following command::

    $ sudo adduser --system \
                --home /var/lib/sks
                --shell /bin/bash
                --group \
                debian-sks


IP Address
^^^^^^^^^^

Add IPv4 and IPV6 network adresses for the keyserver::

    $ sudo ip addr add 192.0.2.37/24 dev eth0
    $ sudo ip addr add 2001:db8::37/64 dev eth0


Also add them to the file :file:`/etc/network/interfaces` to make them
persistent across system restarts:

.. code-block:: ini

    # keyserver.example.net
    iface eth0 inet static
        address 192.0.2.37/24
    iface eth0 inet6 static
        address 2001:db8::37/64


DNS Records
^^^^^^^^^^^

============================ ==== ================================ ======== ===
Name                         Type Content                          Priority TTL
============================ ==== ================================ ======== ===
keyserver                    A    |publicIPv4|                              300
keyserver                    AAAA |KeyServerIPv6|
_pgpkey-http._tcp.keyserver  SRV  0 11371 keyserver.urown.net      10
_pgpkey-https._tcp.keyserver SRV  0 11372 keyserver.urown.net      10
============================ ==== ================================ ======== ===

Check the "Add also reverse record" when adding the IPv6 entry.


Firewall Rules
^^^^^^^^^^^^^^

IPv4 NAT port forwarding:

======== ========= ========================= ==================================
Protocol Port No.  Forward To                Description
======== ========= ========================= ==================================
TCP      11370     |KeyServerIPv4|           OpenPGP Keyserver Recon
TCP      11371     |KeyServerIPv4|           OpenPGP Keyserver HKP
TCP      11372     |KeyServerIPv4|           OpenPGP Keyserver HKPS
======== ========= ========================= ==================================

Allowed IPv6 connections:

======== ========= ========================= ==================================
Protocol Port No.  Destination               Description
======== ========= ========================= ==================================
TCP      80        |KeyServerIPv6|           OpenPGP Keyserver HKP and HTTP
TCP      443       |KeyServerIPv6|           OpenPGP Keyserver HKPS and HTTPS
TCP      11370     |KeyServerIPv6|           OpenPGP Keyserver Recon
TCP      11371     |KeyServerIPv6|           OpenPGP Keyserver HKP
TCP      11372     |KeyServerIPv6|           OpenPGP Keyserver HKPS
======== ========= ========================= ==================================


Tor Hidden Service
^^^^^^^^^^^^^^^^^^

Add a Tor Hidden Service by editing :file:`/etc/tor/torrc`::

    # SKS OpenPGP Key Server Hidden Service for keyserver.example.net
    HiddenServiceDir /var/lib/tor/hidden_services/keyserver
    HiddenServicePort 80 127.0.0.37:80
    HiddenServicePort 443 127.0.0.37:443
    HiddenServicePort 11370
    HiddenServicePort 11371 127.0.0.37:11371
    HiddenServicePort 11372 127.0.0.37:11372

Reload the Tor client::

    $ sudo service tor reload

Read the newly generated \*.onion hostname::

    $ sudo cat /var/lib/tor/hidden_services/keyserver/hostname
    duskgytldkxiuqc6.onion


Software Prerequisites
^^^^^^^^^^^^^^^^^^^^^^

To build, install and run SKS from source we need the Gnu C-compiler, the Ocaml
programming language and the Berkeley database libraries.

They can be installed from the Ubuntu software repository::

    $ sudo apt-get install gcc ocaml libdb-dev db-util


SKS Source Download
-------------------

As of September 2016 Ubuntu 16.04 has SKS version 1.1.5 in its repository. Since the
servers eligible for inclusion into the SKS server pool need to run version
1.1.6 we install a newer version.

We download the source code from the `SKS project website
<https://bitbucket.org/skskeyserver/sks-keyserver/downloads>`_.


The source code is signed by the `SKS Keyserver Signing Key  <http://pool.sks-
keyservers.net/pks/lookup?search=0x41259773973A612A&op=vindex>`_.  The KeyID and
fingerprint are `published on their website
<https://bitbucket.org/skskeyserver/sks-keyserver/src/tip/README.md>`_,
which is a secure site wit EV certification to Altassian Inc.

Get that in our keyring, so we can verify downloaded source code is legit::

    $ gpg2 --recv-key 0x41259773973A612A
    gpg: requesting key 0x41259773973A612A from hkps server hkps.pool.sks-keyservers.net
    gpg: key 0x41259773973A612A: public key "SKS Keyserver Signing Key" imported
    gpg: no ultimately trusted keys found
    gpg: Total number processed: 1
    gpg:               imported: 1  (RSA: 1)

Be sure to check that, key-id, name and fingerprint all match with the published
information::

    $ pub   4096R/0x41259773973A612A 2012-06-27
    Key fingerprint = C90E F143 0B3A C0DF D00E  6EA5 4125 9773 973A 612A
    uid                 [ unknown] SKS Keyserver Signing Key

If everything checks out, sign the SKS key as trusted::

    $ gpg2 --lsign-key 0x41259773973A612A


Now go ahead to download::

    $ cd /usr/loca/src
    $ wget https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.6.tgz
    $ wget https://bitbucket.org/skskeyserver/sks-keyserver/downloads/sks-1.1.6.tgz.asc


Verify the downloaded file::

    $ gpg2 --verify sks-1.1.6.tgz.asc


.. code-block:: text

    gpg: assuming signed data in `sks-1.1.6.tgz'
    gpg: Signature made Sun 07 Aug 2016 04:26:45 PM CEST
    gpg:                using RSA key 41259773973A612A
    gpg: Good signature from "SKS Keyserver Signing Key" [unknown]
    Primary key fingerprint: C90E F143 0B3A C0DF D00E  6EA5 4125 9773 973A 612A


Configuration
-------------

::

    $ cd /usr/local/src
    $ tar -xzf sks-1.1.6.tgz
    $ cd sks-1.1.6
    $ cp Makefile.local.unused Makefile.local

Edit :file:`Makefile.local` by changing the following lines as highlighted below:


.. code-block:: Makefile
    :linenos:
    :emphasize-lines: 4,5

    BDBLIB=-L/usr/lib
    BDBINCLUDE=-I/usr/include
    PREFIX=/usr/local
    LIBDB=-ldb-5.3
    MANDIR=/usr/local/share/man
    export BDBLIB
    export BDBINCLUDE
    export PREFIX
    export LIBDB
    export MANDIR



Build and Install
-----------------

::

   $ cd /usr/local/src/sks-1.1.6
   $ make dep
   $ make all
   $ make install


SKS Configuration
-----------------

:download:`/etc/sks/sksconf <config-files/etc/sks/sksconf>`

.. literalinclude:: config-files/etc/sks/sksconf
    :language: bash
    :linenos:


:download:`/etc/sks/membership <config-files/etc/sks/membership>`

.. literalinclude:: config-files/etc/sks/membership
    :language: bash
    :linenos:


System Configuration
--------------------

The following is adapted from the Ubuntu/Debian SKS software package.


Directories
^^^^^^^^^^^

Create a system envoronment for SKS, change ownership of the data directory and
various other stuff::

    $ mkdir -p /var/{lib,log,spool}/sks
    $ chown -R debian-sks:debian-sks /var/{lib,log,spool}/sks
    $ chmod -R 700 /var/{lib,log,spool}/sks
    $ find /var/{lib,log,spool}/sks -type f -exec chmod 600 '{}' ';'
    $ chgrp -R adm /var/log/sks
    $ chmod -R g+rX /var/log/sks
    $ chmod g+s /var/log/sks


System Service
^^^^^^^^^^^^^^

:download:`/etc/default/sks <config-files/etc/default/sks>`

.. literalinclude:: config-files/etc/default/sks
    :language: sh
    :linenos:


:download:`/etc/init.d/sks <config-files/etc/init.d/sks>`

.. literalinclude:: config-files/etc/init.d/sks
    :language: sh
    :linenos:


Daily Cron Job
^^^^^^^^^^^^^^

:download:`/etc/cron.daily/sks <config-files/etc/cron.daily/sks>`

.. literalinclude:: config-files/etc/cron.daily/sks
    :language: sh
    :linenos:


Log Rotation
^^^^^^^^^^^^

:download:`/etc/logrotate.d/sks <config-files/etc/logrotate.d/sks>`

.. literalinclude:: config-files/etc/logrotate.d/sks
    :language: sh
    :linenos:


Nginx Web-Server Configuration
------------------------------

For better performance and as requirement of the SKS keyserver pool, SKS traffic
is handled by Nginx and sent to SKS as a reverse proxy back-end.


Server
^^^^^^

:download:`/etc/nginx/servers-available/keyserver.example.net.conf
<config-files/etc/nginx/servers-available/keyserver.example.net.conf>`

.. literalinclude:: config-files/etc/nginx/servers-available/keyserver.example.net.conf
    :language: nginx
    :linenos:


SKS Web Application
^^^^^^^^^^^^^^^^^^^

:download:`/etc/nginx/webapps/sks-keyserver.conf
<config-files/etc/nginx/webapps/sks-keyserver.conf>`

.. literalinclude:: config-files/etc/nginx/webapps/sks-keyserver.conf
    :language: nginx
    :linenos:


Keyserver Website
^^^^^^^^^^^^^^^^^

Keyservers can be accessed by normal web-browsers, apart from OpenPGP clients.
Typically you can search for, view, download and upload keys on a rudimentary
web-interface. They usually look like the web was invented only last week.

Luckily `Matt Rude <https://github.com/mattrude>`_ has created a more modern
`OpenPGP Keyserver Website <https://github.com/mattrude/pgpkeyserver-lite>`_
available from Github::

    $ sudo mkdir -p /var/www/example.net/keyserver/public_html
    $ cd /var/www/example.net/keyserver/public_html
    $ sudo git clone https://github.com/mattrude/pgpkeyserver-lite.git
    $ sudo chown -R www-data:www-data /var/www/example.net/keyserver/public_html


Restart Nginx
^^^^^^^^^^^^^

::

    $ sudo ln -s /etc/nginx/servers-available/keyserver.example.net /etc/nginx/sites-enabled/
    $ sudo service nginx restart


HKP and HSTS
------------

The Problem
^^^^^^^^^^^

With our Nginx configuration web-browser can access the HTML interface over
plain unencrypted HTTP on the standard HTTP TCP port 80 and the non-standard
HTTP (but standard HKP) TCP port 11371. For the security aware encrypted HTTPS
connections are provided on port 443. the standard TCP port for both, HKP and
HTTPS.

Now if your domain and sub-domains have strict HSTS enabled, this creates a
problem.

If a modern browser is directed to a website on a non-standard TCP port in a
HSTS enabled domain, the browser will attempt to initiate a TLS connection on
that port, even if the URL starts with http:// and not https://. If that fails,
an error page is displayed to the user and thats it.

So users visiting our keyservers web-interface on port 11371 will be greeted
with a security error message.

This behavior may seem strange but its currently the only way of ensuring
security. The browser **MUST** enforce HSTS but also has no secure way to learn
about or assume on what other presumably non-standard TCP port number, he could
attempt a secure connection.

The problem and and subsequent decision on how this needs to be handled are
described in `this blog post
<http://securityretentive.blogspot.ch/2010/11/quick-clarification-on-hsts-http-strict.html>`_
by Andy Steingruebl.


The Workaroud
^^^^^^^^^^^^^

There is software who can sniff out the protocol connecting on a given port.
OpenVPN for example supports this, so you can hide your secret VPN gateway
behind a unsuspicious website and may also help clients to connect trough
overzealous firewalls.

`sslh <https://github.com/yrutschle/sslh>`_ is one such an Applicative Protocol
Multiplexer who allows to run multiple protocols on the same port.


sslh Installation
^^^^^^^^^^^^^^^^^

sslh is available in the Ubuntu, Debian, SUSE and Fedora software
package repositories::

    $ sudo apt-get install sslh


sslh configuration
^^^^^^^^^^^^^^^^^^

Configuration is stored in the file
:download:`/etc/sslh.cfg <config-files/etc/sslh.cfg>`. The installation does not create that, but an example configuration file is provided in
:file:`/usr/share/doc/sslh/examples/example.cfg`.


.. literalinclude:: config-files/etc/sslh.cfg
    :language: perl
    :linenos:


Testing
^^^^^^^

Launch it by hand to see of it is working alright:

::

    $ sudo sslh -F /etc/sslh.cfg --verbose --foreground


Then open https://keyserver.example.net:11371/ with your browser.

Output should look about as follows:

.. code-block:: text

    http addr: 127.0.0.37:hkp. libwrap service: (null) family 2 2
    ssl addr: 127.0.0.37:https. libwrap service: (null) family 2 2
    listening on:
        192.0.2.37:hkp
        keyserver.example.net:hkp
    timeout: 2
    on-timeout: http
    listening to 2 addresses
    turning into nobody
    sslh-fork 1.15 started
    accepted fd 5
    **** writing defered on fd -1
    probing for http
    probe http successful
    connecting to 127.0.0.37:hkp family 2 len 16
    connection from some-client.some.net:43635 to keyserver.example.net:hkp forwarded from localhost:47333 to 127.0.0.37:hkp
    flushing defered data to fd 4
    client socket closed
    connection closed down
    ...
    connection from some-other-client.some-other.net:43730 to keyserver.example.net:hkp forwarded from localhost:38496 to 127.0.0.37:https
    flushing defered data to fd 4
    accepted fd 5
    **** writing defered on fd -1
    probing for http
    probing for ssl
    probe ssl successful
    connecting to 127.0.0.37:https family 2 len 16
    ...
    server socket closed
    connection closed down


If you got a connection from the SKS pool testing scripts during your test-run,
you may visit your server status page on the SKS pool website, to see if it
still works.


Set up as Service
^^^^^^^^^^^^^^^^^

If test are successful, set it up as service.

Open :download:`/etc/default/sslh <config-files/etc/default/sslh>`.

 * Enable the service by changing the line 12 from "no" to "yes".

 * Replace the the command line options on line 17 with a reference to our
   configuration file.

.. literalinclude:: config-files/etc/default/sslh
    :language: sh
    :linenos:
    :emphasize-lines: 12, 17


Start the Service
^^^^^^^^^^^^^^^^^

::

    $ sudo service sslh start



Database Import
---------------

Lets hope the download of the database dump we `started earlier <#database-dump>`_
has completed in the meantime.

If so check that all the pieces have been downloaded correctly by comparing
their checksums against the list published by the dump provider::

    $ cd /var/lib/sks/dump
    $ md5sum -c metadata-sks-dump.txt
    sks-dump-0000.pgp: OK
    ...
    sks-dump-0261.pgp: OK

The dump now needs to be imported into the SKS database. There are two ways to
do this: either a full build (which reads in the dump you just downloaded and
leaves you with a complete, self-contained database) or a fastbuild (which just
references the dump and requires it to be left in place after the fastbuild is
complete)::

    $ cd /var/lib/sks
    $ sudo /usr/local/bin/sks_build.sh

On the next screen, choose 2.

.. code-block:: text

    Please select the mode in which you want to import the keydump:

    1 - fastbuild
        only an index of the keydump is created and the keydump cannot be
        removed.

    2 - normalbuild

        all the keydump will be imported in a new database. It takes longer
        time and more disk space, but the server will run faster (depending
        from the source/age of the keydump).
        The keydump can be removed after the import.

    Enter enter the mode (1/2): 2


This took around 4 hours on my machine (Intel Core2 Duo CPU @ 2.10GHz with 3GB
RAM) doing a normal build (option 2).


Start
-----

::

    $ sudo service sks start


Clustering
----------

If you have even more disk space available on your server, you can 
run additional instances.

Copy the database directory::

    $ sudo systemctl stop sks-recon.service sks.service
    $ sudo cp -r /var/lib/sks /var/lib/sks2
    $ sudo systemctl start sks-recon.service sks.service
    $ sudo cp -r /var/lib/sks2 /var/lib/sks3
    $ sudo sudo chown -R debian-sks:debian-sks /var/lib/sks*


It might take a few minutes to copy 23 GB of data.

Copy the configuration directory::

    $ sudo cp -r /etc/sks /etc/sks2
    $ sudo cp -r /etc/sks2 /etc/sks3


Edit the new configuration file :file:`/etc/sks2/sksconf`::

    # Set server hostname
    hostname: pgpkeys.example.net
    nodename: sks2

    # Set recon binding address
    recon_address: 127.0.0.2 ::2

    # Set recon port number
    recon_port: 11370

    # Set hkp binding address
    hkp_address: 127.0.0.2 ::2

    # Set hkp port number
    hkp_port: 11371


Edit the new configuration file :file:`/etc/sks3/sksconf`::

    # Set server hostname
    hostname: pgpkeys.example.net
    nodename: sks3

    # Set recon binding address
    recon_address: 127.0.0.3 ::3

    # Set recon port number
    recon_port: 11370

    # Set hkp binding address
    hkp_address: 127.0.0.3 ::3

    # Set hkp port number
    hkp_port: 11371


Edit the new membership file :file:`/etc/sks3/membership`::

.. to be continued ..


References
----------

 * `Matt Rudes Public Keyserver Guides <https://keyserver.mattrude.com/guides/>`_
 * `Ubuntu sks man page <http://manpages.ubuntu.com/manpages/xenial/en/man8/sks.8.html>`_ (Ubuntu Utopic 16.04)

