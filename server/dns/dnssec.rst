Securing the Domain
===================

.. contents::
    :depth: 2
    :local:

With  `DNSSEC
<https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions>`_ we can
digitally sign our domain records. Third parties can't censor our content or
point our services to other servers, without anyone noticing. Another benefit
is, securing services with TLS keys and certificates, without the need of a
certificate authority. Also SSH public keys no longer need to be distributed as
files, as the key can be verified with DNSSEC secured DNS records.

While DNSSEC is usually complicated, hard to implement and manage, PowerDNS has
made it as easy as possible. See the  `PowerDNS DNSSEC documentation
<https://doc.powerdns.com/authoritative/dnssec/index.html>`_ for complete
coverage.


Introduction
------------

Keys used by DNSSEC
^^^^^^^^^^^^^^^^^^^

All the keys used for DNSSEC are public/private key pairs, aka asynchronous
keys.

======================== ==============================================
Key                      Description
======================== ==============================================
Key Signing Key (KSK)    Used to sign the zone signing key (ZSK).
Zone Signing Key (ZSK)   Used to sign DNS resource records for a zone.
Common Signing Key (CSK) I wish I knew.
======================== ==============================================


Record Types used by DNSSEC
^^^^^^^^^^^^^^^^^^^^^^^^^^^

========== ========================================================
Type       Description
========== ========================================================
DS         Delegation Signer
DNSKEY     Domain Name Signing Public Key
RRSIG      Resource Record Signature
CDNS       Child Copy of DNSKEY
CDS        Child Copy of DS
NSEC       Signature for a non-existing (NXDOMAIN) record
NSEC3      Signature of a hashed NXDOMAIN record
NSEC3PARAM Parameters used for hashing and signing NXDOMAIN records
========== ========================================================

The **DS** record is published by the parent zone, this record authorizes a KSK
in the child zone to sign the ZSK of the child zone.

The **DNSKEY** is used by the child zone to publish any public keys it uses for
signing. KSK or ZSK.

**RRSIG** records are used to publish the signatures of any DNS records.

**CDNS** and **CDS** records are published by a child zone during key roll-over.
They inform the parent zone about all the keys in use, so that the parent can
update its DS (delegation signer) records for the child.


Cryptographic Algorithms
^^^^^^^^^^^^^^^^^^^^^^^^

The key pairs can be created using one of the following cryptographic
algorithms. The each have a number (defined and managed by :term:`IANA`). The
number then is used in DNS records to identify the key and use the correct
algorithms when calculating proof of a signature.

==================== === ===========
Public Key Algorithm Nr. Status
==================== === ===========
RSAMD5                 1 Forbidden
DSA                    3 Optional
RSASHA1                5 Mandatory
RSASHA1-NSEC3-SHA1     6 Recommended
RSASHA256              8 Recommended
RSASHA512             10 Recommended
ECC-GOST              12 Optional
ECDSAP256SHA256       13 Recommended
ECDSAP384SHA384       14 Recommended
ED25519               15 Optional
ED448                 16 Optional
==================== === ===========

======= ===================== ================= ====================
Number  Mnemonics             DNSSEC Signing    DNSSEC Validation
======= ===================== ================= ====================
      1 RSAMD5                MUST NOT          MUST NOT
      3 DSA                   MUST NOT          MUST NOT
      5 RSASHA1               NOT RECOMMENDED   MUST
      6 DSA-NSEC3-SHA1        MUST NOT          MUST NOT
      7 RSASHA1-NSEC3-SHA1    NOT RECOMMENDED   MUST
      8 RSASHA256             MUST              MUST
     10 RSASHA512             NOT RECOMMENDED   MUST
     12 ECC-GOST              MUST NOT          MAY
     13 ECDSAP256SHA256       MUST              MUST
     14 ECDSAP384SHA384       MAY               RECOMMENDED
     15 ED25519               RECOMMENDED       RECOMMENDED
     16 ED448                 MAY               RECOMMENDED
======= ===================== ================= ====================

See :del:`RFC 6944` and :rfc:`8624`.

See `DNS Security Algorithm Numbers <https://www.iana.org/assignments/dns-sec-alg-numbers/dns-sec-alg-numbers.xhtml#dns-sec-alg-numbers-1>`_


Digest Algorithms
^^^^^^^^^^^^^^^^^

================ === ===========
Digest Algorithm Nr. Status
================ === ===========
SHA-1              1 Mandatory
SHA-256            2 Mandatory
GOST R 34.11-94    3 Optional
SHA-384            4 Optional
================ === ===========

See `Delegation Signer (DS) Resource Record (RR) Type Digest Algorithms <https://www.iana.org/assignments/ds-rr-types/ds-rr-types.xhtml#ds-rr-types-1>`_


Secure Entry Points
^^^^^^^^^^^^^^^^^^^

==== ===========================================================================
Flag Meaning
==== ===========================================================================
 256 Only allowed to sign anything if signed by a key with the SEP flag.
 257 Authorized by the parent zone DS record to sign anything in the child zone.
==== ===========================================================================


DNSSEC and Time-To-Live
^^^^^^^^^^^^^^^^^^^^^^^

Every record returned in answers from DNS servers has a time-to-live (TTL)
value. The tell a client how long a record can be cached, so we don't have to
ask every time we need the same information again.

Typical TTL values for DNS hosts range from one week (86400 seconds) down to
five minutes (300 seconds) i.e. for dynamic IPs who might change anytime.

In non-DNSSEC records these are fixed values. The client does not know when the
record was created. He just gets the permission to cache it for the said number
of seconds, regardless how old the record already was when he asked for it.
After expiration the record will be retrieved again by the resolver if needed,
regardless if it changed or not.

The authoritative server does not need to do anything, as long a the record does
not change.

With DNSSEC things are different. The signatures have fixed time periods in
which they are valid. I.e. the signature for the SOA record of example.net is
valid exactly from January 2nd at 16:52:12 (20180102162512) until January the
23rd at 13:48:22 (20180123134822).

The records must be re-signed by the authoritative server before they expire or
they will not be accepted anymore by resolvers with DNSSEC support.


The DS Record
^^^^^^^^^^^^^

E.g.::

    # dig +multiline example.net. DS

    ; <<>> DiG 9.10.3-P4-Ubuntu <<>> +multiline example.net. DS
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 33503
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 6, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;example.net.       IN DS

    ;; ANSWER SECTION:
    example.net.        33698 IN DS 61250 8 1 (
                    EBF5191249B08ADBA60DC57DE26F8D530FE5D17D )
    example.net.        33698 IN DS 31589 8 2 (
                    5A9EAEFC7CC7D6946E1D106418427D272D406B835BA9
                    EA0219DFBD3974A54A81 )
    example.net.        33698 IN DS 31589 8 1 (
                    628FCA4806B2E475DA9FD97A1FB57B7E26F8494C )
    example.net.        33698 IN DS 54761 8 2 (
                    9FDE7678F418E724ACE98537E0EAD92BB96B3109072D
                    076A117492DB708CE238 )
    example.net.        33698 IN DS 54761 8 1 (
                    2B45E49265B30032497E0D61D259F4ACF821A5A0 )
    example.net.        33698 IN DS 61250 8 2 (
                    984E001501B50F8D7B73935E12A0B15E9DCE5498F088
                    5C3C6193B4DCB8DDAD36 )

    ;; Query time: 0 msec
    ;; SERVER: 172.20.10.43#53(172.20.10.43)
    ;; WHEN: Sat Jan 06 11:31:16 CET 2018
    ;; MSG SIZE  rcvd: 292

The structure of a DS record is as follows:

============ =========== =====================================================
Field        Example     Description
============ =========== =====================================================
Key Tag            61250 Identifies the key across parent and child zones.
Algorithm              8 Which type of key (algorithm) the child key is using.
Digest Type            1 Identifies the digest algorithm used by the parent.
Digest       EBF5...D17D The digest of the child's public key.
============ =========== =====================================================


The **digest** is calculated by concatenating the domain name and the rdata
portion of the zone’s DNSKEY record (flags, protocol, algorithm, and public
key), and hashing the result with the algorithm.


The DNSKEY records
^^^^^^^^^^^^^^^^^^

Contains the public key of either a KSK or a ZSK::

    $ dig +multiline example.net. DNSKEY

    ; <<>> DiG 9.10.3-P4-Ubuntu <<>> +multiline example.net. DNSKEY
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50414
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 3, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;example.net.       IN DNSKEY

    ;; ANSWER SECTION:
    example.net.        900 IN DNSKEY 257 3 8 (
                    AwEAAcSvBHUuazPyycexMEFH9+oQoJXAugbelISqKM0e
                    Qv4jPsp1qws6+rs6mpBgxwE6bOqOqAUDnXqkjPiLE8st
                    Q6l2r1jCN/Ad8N+tOqCPMIG93RE233PKm3hDK1KoLEmR
                    9us2vRfkM1H/tt0UuL/4RoVdUCHH8jcp9tueMQzQG4RO
                    nE/HctTb+WR/zBFa+GjGdoQGdjasr5CDrXvImipyG9fJ
                    ZQ+wNtAzjMpl2dR2oJERE9HFnv52GblveqAZcw3HqCn2
                    MsF8QKOFcPEXVk1lOtaqb0bBqftLEuoNysbYcKoXOO4Z
                    nKcxPB+bHoeHTWSvz5XSoCwulwE15xJ/GrA1rrk=
                    ) ; KSK; alg = RSASHA256; key id = 61250
    example.net.        900 IN DNSKEY 256 3 8 (
                    AwEAAZ/9wpQpBVsh1WLWtgOewqesLtZLV1nOgle7OmKs
                    aPSX4gFEWP3znBXICNsuFAaOY0JYZKO6A7Pip+6cmwiR
                    A34mr5Xk3XNtTPMfoT55D1qE/l8zMHBspEgulIFPSBPc
                    WQpXTkxQKIpYzn4yhak7BKBOm8I0AFDHlehtdf8qys9t
                    ) ; ZSK; alg = RSASHA256; key id = 17491
    example.net.        900 IN DNSKEY 257 3 8 (
                    AwEAAbMqsFTYoin5LDKjSo0Ix0nj29adzS97t2n3QImu
                    svDp8llLbKmG3wVX99FbLL232oVfvL1QgP3Uqa88yxrJ
                    iwJ+BxT5SWaU0kFbfEvLlAIwkcp8fIpZPiPLo0tXXFu7
                    h0LtXWUYMei1Q4wzxVaxTAWBuDnbUM+g629FeI9052lQ
                    DYpSa32CzDRXLXJ23hR2lNRecCnTXw+kudfL3oxUTUKi
                    Ijjf0zDcoa3G0TCogMhgXnJJ32havw+u3HevDLLQq5hk
                    KTR55Ymr8bagm7N0V8ZAxvnCG5ix9SFLvjG/7BQUEOgI
                    eeyoZoTGGkeFEA2Hs+j8BNPXwML+ETlYsgeaAwc=
                    ) ; KSK; alg = RSASHA256; key id = 51916

    ;; Query time: 14 msec
    ;; SERVER: 127.0.0.1#53(172.20.10.43)
    ;; WHEN: Sat Jan 06 11:26:45 CET 2018
    ;; MSG SIZE  rcvd: 740


The structure of a DNSKEY record is as follows:

============ =========== =====================================================
Field        Example     Description
============ =========== =====================================================
Flags                256 Zone key and secure entry point (SEP) flags.
Protocol               3 Always 3
Algorithm              8 The public key algorithm used to create the key.
Public Key   AwEA...ys9t The full public key.
============ =========== =====================================================

DNSKEY Flags
````````````

======== =============================
Bit      Flag
======== =============================
  0 -  6 Reserved
       7 Zone Key Flag
  8 - 14 Reserved
      15 Secure Entry Point (SEP) Flag
      16 Reserved
======== =============================

Flag Bits
`````````

================ ============= ===================================================
Flag Bits Values Decimal Value Description
================ ============= ===================================================
000000000000000              0 Key is neither a zone key nor a secure entry point.
000000000000001              1 Key is not a zone key but is a secure entry point.
000000100000000            256 Key is a zone key but not a secure entry point.
000000100000001            257 Key is a zone key and a secure entry point.
================ ============= ===================================================


The RRSIG record
^^^^^^^^^^^^^^^^

The signatures of DNS answers to queries are not displayed by default. Use the
:code:`+dnssec` option to make them visible::

    $ dig +multiline +dnssec example.net. SOA

    ; <<>> DiG 9.10.3-P4-Ubuntu <<>> +multiline +dnssec example.net. SOA
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5858
    ;; flags: qr rd ra ad; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags: do; udp: 4096
    ;; QUESTION SECTION:
    ;example.net.       IN SOA

    ;; ANSWER SECTION:
    example.net.        3588 IN SOA sns.dns.icann.org. noc.dns.icann.org. (
                    2017120519 ; serial
                    7200       ; refresh (2 hours)
                    3600       ; retry (1 hour)
                    1209600    ; expire (2 weeks)
                    3600       ; minimum (1 hour)
                    )
    example.net.        3588 IN RRSIG SOA 8 2 3600 (
                    20180123134822 20180102162512 17491 example.net.
                    bfE6eVnjxMcX/UH2rzc7HRZ1DwetaTVseDeMVUQEAwno
                    ioWhGnsHxaXs6pA7btGEC9ZIZ3PgUiexL1fWxOU4p049
                    3dy1wkkUrmEj22viN/cj0S1DhhP2x/8ROqpG+L4Rhovx
                    BtvD3H+uOeVGRIXQ781UiXL4po/ti7AdFDSf49I= )

    ;; Query time: 0 msec
    ;; SERVER: 127.0.0.1#53(172.20.10.43)
    ;; WHEN: Sat Jan 06 12:02:54 CET 2018
    ;; MSG SIZE  rcvd: 268


The structure of a RRSIG record is as follows:

==================== ============== ============================================
Field                Example        Description
==================== ============== ============================================
Original Type        SOA            The type of record that has been signed.
Algorithm                         8 The algorithm used for signing
Number of Labels                  2 If the answer was formed from a wildcard
                                    record.
Original TTL                   3600 The time-to-live of the signed record.
Signature Expiration 20180123134822 The expiration time of the signature.
Signature Inception  20180102162512 The time when the record was signed.
Key Tag                       17491 The key-tag of the key used for signing.
Name of Signer       example.net.   The name of the zone who signed the record.
Signature            bfE6...49I=    The signature.
==================== ============== ============================================


Number of Labels
````````````````

Wildcard records need special handling during verification.

Lets assume the zone has a wildcard record of :code:`*.example.net` and we ask
for the IP address of :code:`books.example.net`.

The server will return the IP address as A record along with signature for its record :code:`*.example.net`.

Without DNSSEC the client does not even have to know if the answer was formed
out of a wildcard record. But with DNSSEC if it tries to validate the answer
:code:`books.example.net` with the signature for :code:`*.example.net` the
validation fails.

To resolve this problem the "number of labels" field is used. If the number of
labels has a value which is the same as we have asked for, its a normal existing
record.

In the case of our example we asked for a domain name consisting of
three parts: **books**, **example** and **net**.

 * If the "Number of Labels" has a value of **3**, the client knows he can
   validate the signature normally using the host names he asked for.

 * If the "Number of Labels" has value of less, lets say "2", the client will
   validate the signature against the :code:`*.example.net` and not against what
   he asked for.


Child Copy of DNSKEY (CDNS) Record
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Child copy of DNSKEY record, for transfer to parent.


Child Copy of DS (CDS) Record
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Child copy of DS record, for transfer to parent


NSEC Record
^^^^^^^^^^^

NSEC3 Record
^^^^^^^^^^^^


NSEC3PARAM Record
^^^^^^^^^^^^^^^^^


Pre-Requisites
--------------


Domain Meta-Data
^^^^^^^^^^^^^^^^

.. note::

    Some of the following changes will tell PowerDNS to manage the SOA serial
    number automatically. The serial stored in the database may therefore no
    longer be relevant. Always check the serial by doing a SOA query on your DNS
    server like :code:`$ dig @192.0.2.41 SOA example.net` and not a lookup
    in the database or your front-end.


The MySQL table `domainmetadata` in the PowerDNS database is used to store
domain-specific configuration settings.

While some things work without it, it is needed for some slave server related
configurations and for DNSSEC purposes.

Unfortunately ~`none of the usage friendly front-ends support this features
until today`~, so we have to use some SQL-Fu to set our options::

    $ mysql -u root -p pdns

All these domain-specific options are described in the PowerDNS Manual in
`Chapter 15. Per zone settings aka Domain Metadata
<http://doc.powerdns.com/html/domainmetadata.html>`_

.. code-block:: mysql

    -- Automatically increment the SOA serial number after DNSSEC signatures
    -- have been refreshed.  Avoids slaves to server DNS records with expired
    -- signatures.
    INSERT INTO `domainmetadata` (
        `domain_id`,
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.net'),
            'SOA-EDIT', 'INCEPTION-INCREMENT'
            );

    -- Automatically increment the SOA serial number after changes made trough
    -- API calls or signatures have been refreshed. Avoids slaves to server DNS
    -- records with expired signatures.
   INSERT INTO `domainmetadata` (
        `domain_id`,
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.net'),
            'SOA-EDIT-API', 'INCEPTION-INCREMENT'
            );

    -- Automatically rectify zone (as needed by DNSSEC for NSEC/NSEC3)
    -- after any changes made trough API calls.
    INSERT INTO `domainmetadata` (
        `domain_id`,
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.net'),
            'API-RECTIFY', '1'
            );

    -- Allow all slaves to request AXFR zone transfers
    INSERT INTO `domainmetadata` (
        `domain_id`,
        `kind`, `content`
        ) VALUES (
            (SELECT id from domains where name='example.net'),
            'ALLOW-AXFR-FROM', 'AUTO-NS'
            );

To get a list of all your domains meta-data:


.. code-block:: mysql

    SELECT domains.name AS Domain, kind AS Option, content AS Value
        FROM domainmetadata
        LEFT JOIN domains ON domainmetadata.domain_id = domains.id
        ORDER BY Domain, Option, Value ASC;


=========== =============== ===================
Domain      Option          Value
=========== =============== ===================
example.net ALLOW-AXFR-FROM AUTO-NS
example.net API-RECTIFY     1
example.net SOA-EDIT        INCEPTION-INCREMENT
example.net SOA-EDIT-API    INCEPTION-INCREMENT
example.org ALLOW-AXFR-FROM AUTO-NS
example.org API-RECTIFY     1
example.org SOA-EDIT        INCEPTION-INCREMENT
example.org SOA-EDIT-API    INCEPTION-INCREMENT
=========== =============== ===================


Securing a Zone
---------------

Key Generation
^^^^^^^^^^^^^^

The commandline tool :manpage:`pdnssec` takes care of all the complicated
tasks.

To configures the zone **example.net** with reasonable DNSSEC settings::

    $ sudo pdnssec secure-zone example.net
    Securing zone with rsasha256 algorithm with default key size
    Zone example.net secured
    Adding NSEC ordering information

Calculates the 'ordername' and 'auth' fields for the zone so they comply with
DNSSEC settings::

     $ sudo pdnssec rectify-zone example.net

Can be used to fix up migrated data. Can always safely be run, it does no harm.
Its advised to run this command on every hosted zone, whether they are secured
with DNSSEC or not, to keep the whole database clean::

    $ sudo pdnssec rectify-all-zones


NSEC
^^^^


Publishing
^^^^^^^^^^

After the zone has been secured, we can tell the world about it. This is done,
by publishing our :abbr:`DS (Domain Signing)` key with our domain registrar.

To get the :abbr:`DS` key information::

    $ sudo pdnssec show-zone exmaple.com

The command will display a bunch of keys.

In oder to setup DNSEC at your registrar, he will ask you to provide the
following information:

    1. **Key Tag**: Found on the first line of the output. `tag = nnn`. The tag
       is a number between 0 and 65,535.
    2. **Algorithm**: Select `algo = 8` or
       `RSA-SHA256`.
    3. **Digest Type**: Refers to one of the long lines starting
       with `DS = example.net IN DS 31085 8`. Select number 2 for the preferred
       SHA256 digest.
    4. **Digest**: The long digest string, as displayed.

To check whether the domain is now offcially DNSSEC enabled::

    $ whois exmaple.com | grep DNSSEC
    DNSSEC:signedDelegation


Updating Slaves
^^^^^^^^^^^^^^^

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

    $ sudo pdnssec increase-serial example.net


Testing
^^^^^^^

http://dnssec-debugger.verisignlabs.com/

http://viewdns.info/dnssec/

http://www.nabber.org/projects/dnscheck/


Operations
----------

Algorithm Roll-over
^^^^^^^^^^^^^^^^^^^

.. note::

    DNSSEC algorithm roll-overs are in many ways similar to normal roll-overs, but
    with these two caveats:

     * The KSK and ZSK should be rolled at the same time;
     * The old ZSK cannot be withdrawn until the KSK roll-over is complete.

The following procedure should only be be used if a algorithm is considered weak
or attacks have been published.

Lets assume that up to today our domain example.net has been signed with the
RSASHA1 algorithm which is considered weak today.

From now on our domain records should be signed with ECDSA keys, p-256 elliptic
curve cryptography and SHA-256 digest algorithms.

 #. Create a new key-pair with the new algorithm ECDSAP256SHA256 to be used as
    KSK, but leave it as inactive for now. Also don't publish the public key
    anywhere yet.

 #. Create a new key-pair with the new algorithm ECDSAP256SHA256 to be used as
    ZSK. This one can be activated, so that our zone is getting populated with
    new signatures using the new algorithm, alongside the old one which also
    remains active.

 #. Look for the record with highest TTL in your zone. Double that time to wait
    for the next step. This is to make sure the signatures with the new
    algorithms are populated everywhere in caches.

 #. After the wait activate the new KSK generated earlier but not activated.

 #. Communicate the new KSK to your registrar and wait for DS delegation
    records to appear.

 #. Wait for the SOA TTL to expire. This is to make sure all caches picked up
    you new KSK therefore are able to verify the new signatures.

 #. Let your registrar remove the old KSK.

 #. Wait for the DS TTL of your parent to expire. This is to make sure all
    caches know that the old KSK is no longer usable for verification.

 #. Deactivate and remove the old ZSK from your zone.


Scheduled KSK Roll⁻Over
^^^^^^^^^^^^^^^^^^^^^^^

The following procedure should be used for the planned roll-over once a year.

A KSK roll-over requires a new public key transmitted to the registrar.

 #. Create a new KSK key/pair.

 #. Activate the key so zone signing keys (ZSK) will be signed by both the new
    and old KSK during the transition period.

 #. Make sure all records are re-signed and all slaves have picked the changes.

 #. Provide the public key to the registrar of the domain.

 #. Wait for publication of new DS records in the parent domain.

 #. Wait for the domains cache time (TTL in the SOA record) is over.

 #. De-activate the old KSK.


Emergency KSK Roll-Over
^^^^^^^^^^^^^^^^^^^^^^^

This procedure should be followed when ever an emergency roll-over needs to take
place (e.g. a suspected key compromise).


ZSK Roll-Over
^^^^^^^^^^^^^


Security Considerations
-----------------------


Key Material
^^^^^^^^^^^^


Zone Transfer
^^^^^^^^^^^^^



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

    $ export ZONE=example.net

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
