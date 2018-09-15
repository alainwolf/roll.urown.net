Keeping the Router Updated
==========================

Let the router tell us when there are updates available.


Software Packages
-----------------


The excellent `opkg upgrade script <https://github.com/tavinus/opkg-upgrade>`_ 
from Gustavo Arnosti Neves.

The router must be able to :doc:`send out mails <router-mail>`.


Installing the Script
^^^^^^^^^^^^^^^^^^^^^

::

    router$ opkg install ca-certificates openssl-util

    router$ wget 'https://raw.githubusercontent.com/tavinus/opkg-upgrade/master/opkg-upgrade.sh' \
        -O "/tmp/opkg-upgrade.sh"
    router$ chmod 755 "/tmp/opkg-upgrade.sh"
    router$ /tmp/opkg-upgrade.sh --install


Checking for Updates
^^^^^^^^^^^^^^^^^^^^

::

    router$ opkg-upgrade


Cron Job
^^^^^^^^

Let's create a scheduled job, that checks for updated packages every 16 hours,
and notifies us by mail::

    router$ EDITOR=$(which nano) crontab -e


Insert the line as follows:

.. code-block:: bash
   :linenos:

    # Send any output by mail to hostmaster@example.net
    MAILTO=hostmaster@example.net
    #
    #min hour mday month wday cmd
    35   */16 *    *     *    /usr/sbin/opkg-upgrade --text-only --ssmtp hostmaster@example.net

    # crontab and fstab must end with the last line a space or comment


Use CTRL+X and Y to save and exit.

Restart cron to re-read its configuration::

    router$ /etc/init.d/cron restart



OpenWRT Releases
----------------

No automation here.

You need to follow the `OpenWrt Project <https://openwrt.org/>`_ page.


Firmware Download
^^^^^^^^^^^^^^^^^

The OpenWRT firmware images have a checksum to verify its integrity after download.

The file containing the checksum are signed with an OpenPGP key. The OpenWRT team uses a distinct "release signing key" to sign the checksum files of a major OpenWRT release and subsequent point releases.

The release keys are published on the 
`OpenWrtPublic Keys page <https://openwrt.org/docs/guide-user/security/signatures>`_.

So the steps necessary to download and verify a firmware image:

 #. Find appropriate firmware image file on the download site or one of the 
    mirror sites.
 #. Download the image file.
 #. Download the checksum file (found at the bottom of the download page).
 #. Download the OpenPGP signature file of the checksum file (also found at the 
    bottom of the download page).
 #. Download the public OpenPGP release key from the OpenWrtPublic Keys page
 #. Add the release key to your public keyring, set trust and sign it locally.
 #. Verify the OpenPGP signature of the checksum file.
 #. Verify the integrity of the image file with the checksum file.

Thats a lot of work. Fortunately there is a script which takes care of all the
steps, except the first one.

OpenWRT supplies a
`convenience script <https://openwrt.org/docs/guide-user/security/release_signatures#downloadsh>`_ 
to automate the required download and signature verification steps.

With the download script its enough to supply the URL of the firmware image to download::

    desktop$ cd ~/Downloads
    desktop$ wget -O openwrt-download.sh https://openwrt.org/_export/code/docs/guide-user/security/release_signatures?codeblock=1
    desktop$ chmod 755 openwrt-download.sh
    desktop$ ./openwrt-download.sh https://downloads.lede-project.urown.net/releases/18.06.0/targets/ar71xx/generic/openwrt-18.06.0-ar71xx-generic-wndr3800-squashfs-sysupgrade.bin


Transfer the verified image to the router::

    desktop$ scp openwrt-18.06.0-ar71xx-generic-wndr3800-squashfs-sysupgrade.bin \
        root@router.lan:/tmp/sysupgrade.bin


Preparation
^^^^^^^^^^^

Make sure you have all your relevant config-files listed in the
:file:`/etc/sysupgrade.conf` file on the router::

    router$ less /etc/sysupgrade.conf


Make sure you have all your user-installed packages listed in the file
:file:`/root/opkg-user-installed.txt`::

    router$ awk '/^Package:/{PKG= $2} /^Status: .*user installed/{print PKG}' /usr/lib/opkg/status \
        > /root/opkg-user-installed.txt


Make one last :doc:`backup <router-backup>` before starting the system upgrade
procedure::

    router$ /root/openwrt-backup.sh


Firmware Upgrade
^^^^^^^^^^^^^^^^

::

    router$ sysupgrade -v /tmp/sysupgrade.bin


Post-Upgrade
^^^^^^^^^^^^

TBD


References
----------

 * `Luci sysupgade <https://openwrt.org/docs/guide-user/installation/sysupgrade.cli>`_
 * `Upgrading LEDE firmware from the Command Line <https://openwrt.org/docs/guide-user/installation/sysupgrade.cli>`_
