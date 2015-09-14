Securing the Domain
===================

With  `DNSSEC
<https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions>`_ we can
digitally sign our domain records. Third parties can't censor our content or
point our services to other servers, without anyone noticying. Another benefit
is, securing services with TLS keys and certificates, without the need of a
certificate authority. Also SSH public keys no longer need to be distributed as
files, as the key can be veryfied with DNSSEC secured DNS records.

While DNSSEC is usually complicated, hard to implement and manage, PowerDNS has
made it as easy as possible. See the  `PowerDNS DNSSEC documentation
<http://doc.powerdns.com/html/powerdnssec-auth.html>`_ for complete coverage.


Domain Meta-Data
----------------

The MySQL table `domainmetadata` in the PowerDNS database is used to store
domain-specific configuration settings. 

While some things work without it, it is needed for some slave server related
confiugrations and for DNSSEC purposes.

Unfortunately none of the usage friendly front-ends support this features until
today, so we have to use some SQL-Fu to set our options::

    $ mysql -u root -p pdns

All these domain-specific options are described in the PowerDNS Manual in 
`Chapter 15. Per zone settings aka Domain Metadata 
<http://doc.powerdns.com/html/domainmetadata.html>`_

.. code-block:: mysql

    INSERT INTO `domainmetadata` (
        `domain_id`, 
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.com'),
            'SOA-EDIT', 'INCEPTION-INCREMENT'
            );

    INSERT INTO `domainmetadata` (
        `domain_id`, 
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.com'),
            'ALLOW-AXFR-FROM', 'AUTO-NS'
            );

    # afraid.org Backup DNS - AXFR Source IP
    INSERT INTO `domainmetadata` (
        `domain_id`, 
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.com'),
            'ALLOW-AXFR-FROM', '208.43.71.243'
            );


Securing a Zone
---------------

The commandline tool :manpage:`pdnssec` takes care of all the complicated
tasks.

To configures the zone **example.com** with reasonable DNSSEC settings::

    $ sudo pdnssec secure-zone example.com
    Securing zone with rsasha256 algorithm with default key size
    Zone example.com secured
    Adding NSEC ordering information 

Calculates the 'ordername' and 'auth' fields for the zone so they comply with
DNSSEC settings::

     $ sudo pdnssec rectify-zone example.com

Can be used to fix up migrated data. Can always safely be run, it does no harm.
Its advised to run this command on every hosted zone, whether they are secured
with DNSSEC or not, to keep the whole database clean::

    $ sudo pdnssec rectify-all-zones


Publishing
----------

After the zone has been secured, we can tell the world about it. This is done, 
by publishing our :abbr:`DS (Domain Signing)` key with our domain registrar.

To get the :abbr:`DS` key information::

    $ sudo pdnssec show-zone exmaple.com

The command will display a bunch of keys.


In roder to setup DNSEC at your registrar, he will ask you to provide the
following information:

    1. **Key Tag**: Found on the first line of the output. `tag = nnn`. The tag
       is a number between 0 and 65,535. 
    2. **Algorithm**: Select `algo = 8` or
       `RSA-SHA256`. 
    3. **Digest Type**: Refers to one of the long lines starting
       with `DS = example.com IN DS 31085 8`. Select number 2 for the preferred 
       SHA256 digest.
    4. **Digest**: The long digest string, as displayed.

To check whether the domain is now offcially DNSSEC enabled::

    $ whois exmaple.com | grep DNSSEC
    DNSSEC:signedDelegation


Update Slave Servers
--------------------
    
Our other DNS slave servers don't know anything about all of this yet, as
PowerDNS will sign DNS records only when he is asked for such a record.

The procedure also did not update the serial number, therefore the slaves don't
know that now would be a good time to ask for updates.

By increasing the serial-number we trick PowerDNS to notify all slaves to get a
fresh copy of all our domain records.

When the slave servers receive the update-notification, they will in turn
ask for all records in our domain, by requesting a zone-transfer from our server.

PowerDNS digitally signs every record, during the zone-transfer. Slave servers
then get signed copies of all records.

To increase the serial number and trigger the update::

    $ sudo pdnssec increase-serial example.com


Testing
-------

http://dnssec-debugger.verisignlabs.com/

http://viewdns.info/dnssec/

http://www.nabber.org/projects/dnscheck/


Backup Domain Keys
------------------

A DNSSEC zone uses one or more *Key signing key (KSK)* and corresponding *zone
signing key (ZSK)*. Each of the ZSK and KSK has a public key and private key.

::

    $ sudo -sH
    $ mkdir -p ~/dnssec-keys
    $ cd ~/dnssec-keys

List all zones (and check for errors)::

    $  pdnssec check-all-zones

Proceed as follows for each domain (or zone)::

    $ export ZONE=example.com

Show DNSSEC properties of the zone, maybe back them up too::

    $ pdnssec show-zone $ZONE > $ZONE.dnssec.txt
    $ cat $ZONE.dnssec.txt


Export Key Signing Keys (KSK)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Look at lines starting with "ID = <NUMBER> (KSK) ...".
There is at least one active, but there might be more::

    $ grep '(KSK)' $ZONE.dnssec.txt
    $ export KEY_ID=<NUMBER>

Export each of these KSK private a keys::

    $ pdnssec export-zone-key $ZONE $KEY_ID > ${ZONE}_ID${KEY_ID}.ksk

Export the corresponding public keys::

    $ pdnssec export-zone-dnskey $ZONE $KEY_ID > ${ZONE}_ID${KEY_ID}.ksk.pub

If there are multiple KSK repeat until you have them all::

    $ export KEY_ID=<NUMBER>
    $ ...


Export Zone Signing Keys (ZSK)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Now repeat these steps for the KSK private and public keys::

    $ grep '(ZSK)' $ZONE.dnssec.txt
    $ export KEY_ID=<NUMBER>
    $ pdnssec export-zone-key $ZONE $KEY_ID > ${ZONE}_ID${KEY_ID}.zsk
    $ pdnssec export-zone-dnskey $ZONE $KEY_ID > ${ZONE}_ID${KEY_ID}.zsk.pub






