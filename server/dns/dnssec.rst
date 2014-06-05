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


Preparation
-----------

There is only one thing to be done beforehand:

According to :rfc:`4035`, the :abbr:`TTL (Time to live)` for :abbr:`NS (Name
Server)` records at the parent should match the :abbr:`DS (Domain Signature)`
:abbr:`TTL`. PowerDNS will set the :abbr:`DS (Domain Signature)` :abbr:`TTL` to
86,400 seconds (1 day) so we should change all our :abbr:`NS` records to the
same :abbr:`TTL`.


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

..  Note::
    
    DNS Records are signed live by the server when requested and then cached. So
    the whole procedure did not update the serial number and the slaves don't
    know nothing about.

Add. delete or change a record to trigger an update from the slaves. So they 
start serving signed records too.


Testing
-------

http://dnssec-debugger.verisignlabs.com/

http://viewdns.info/dnssec/

http://www.nabber.org/projects/dnscheck/
