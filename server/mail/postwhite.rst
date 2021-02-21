:orphan:

Postscreen Whitelist
====================

`Postwhite <https://www.stevejenkins.com/blog/2015/11/postscreen-whitelisting-smtp-outbound-ip-addresses-large-webmail-providers/>`_
is a script that generates a whitelist for Postfix's Postscreen for a mail
sending domain by fetching the domains SPF records.

This is espacially usefull for large mail senders, like, for example, Gmail,
Outlook or Mailchimp.

As discussed in the previous chapter, we use Postscreen to spare our MTA from
reading and analyzing the 90% of mails which are easely identified as spam by
its IP address.

But from the remaining 10% legitimate delivery attempts we receive, around 85%
are coming from the worlds largest mail providers. These providers usually keep
their services very tight and clean of spam. But also blocking them in any way,
leads instantly to severe problems with your mail users.

Wouldn't it be nice to have a way of skipping all the greylisting,
DNS-RBL-cheking and other network and sanity checking?

Since (with the execption of Yahoo!) the outbound IP addresses of these
providers MTA's are found in their SPF records, one can build a up-to-date
whitelist of their IP addresses by fetching and analyzing their SPF records.


Install SPF-Tools
-----------------

`SPF-Tools <https://github.com/spf-tools/spf-tools>`_ is a collection of shell
scripts for taming the SPF (Sender Policy Framework) records in order to fight
10-maximum-DNS-look-ups limit.

Postwhite relies on the SPF-Tools for the heavy lifting of gathering the IP
addresses.

::

    $ cd /usr/local/bin
    $ sudo git checkout -b mkearey/255_characters \
        https://github.com/spf-tools/spf-tools.git


Install Postwhite
-----------------

::

    $ cd /usr/local/bin
    $ sudo git checkout https://github.com/stevejenkins/postwhite.git


Postwhite Setup & Configuration
-------------------------------

::

    $ sudo mkdir -p /etc/postwhite
    $ sudo cp /usr/local/bin/postwhite/postwhite.conf /etc/postwhite


::

    # CONFIGURATION OPTIONS FOR POSTWHITE
    # https://github.com/stevejenkins/postwhite
    # POSTWHITE WILL LOOK FOR THIS FILE IN /etc/postwhite.conf

    # FILE PATHS
    spftoolspath=/usr/local/bin/spf-tools
    postfixpath=/etc/postfix
    postfixbinarypath=/usr/sbin
    whitelist=postscreen_spf_whitelist.cidr
    blacklist=postscreen_spf_blacklist.cidr
    yahoo_static_hosts=/etc/postwhite/yahoo_static_hosts.txt

    # CUSTOM HOSTS
    # Enter custom hosts separated by a space, ex: "example.com example2.com example3.com"
    custom_hosts="example.net example.com example.org"

    # Include list of Yahoo Outbound IPs from https://help.yahoo.com/kb/SLN23997.html?
    include_yahoo="yes"

    # Do you also want to build a blacklist?
    enable_blacklist=no
    blacklist_hosts=""

    # Do what to invalid IPv4 addresses and CIDRs?
    # Valid settings are 'remove' 'fix' or 'keep'
    invalid_ip4=fix

    # Simplify (remove) IP addresses from the whitelist that are already covered by CIDRs?
    # WARNING: Enabling this option can dramatically increase the time Postwhite takes to
    # run if you have many mailers selected. Try it once, then come back and turn it off. :)
    simplify=no

    # Reload Postfix Automatically when done?
    reload_postfix=yes


Postwhite Cron-Jobs
-------------------

Daily cron job to refresh the IP address whitelist,
:file:`/etc/cron.daily/postwhite`::

    #!/bin/sh

    set -e

    # Update Postfix Postscreen white-list with IP addresses of mail providers
    /usr/local/bin/postwhite/postwhite \
        /etc/postwhite/postwhite.conf > /dev/null 2>&1


Yahoo! has SPF records too, but they don't contain any IP addresses, as they
rely on reverse-DNS entries of their **yahoo.com** domain,

Weekly cron job to refresh Yahoo outbound mail server IP addresses
:file:`/etc/cron.weekly/postwhite-yahoo`::

    #!/bin/sh

    set -e

    # Update Postfix Postscreen white-list with Yahoo Mail IP addresses
    /usr/local/bin/postwhite/scrape_yahoo \
        /etc/postwhite/postwhite.conf > /dev/null 2>&1


Postfix Configuration
---------------------

Add the whitelist to the Postscreen configuration in the main Postfix configuration-file :file:`/etc/postfix/main.cf`::

    ...

    # Postscreen Settings
    #

    # What networks are permanently whitelisted to send mails?
    postscreen_access_list =
        #permit_mynetworks
        cidr:${meta_directory}/postscreen_access.cidr
        cidr:${meta_directory}/postscreen_spf_whitelist.cidr


    ...

