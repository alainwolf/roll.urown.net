Installation
============

.. note::
   The following has been done on NETGEAR router model WNDR3800. 
   Your mileage will vary. 
   Consult the relevant OpenWRT `supported_devices <https://openwrt.org/supported_devices>`_ page.


Firmware Download
-----------------

The OpenWRT firmware images have a checksum to verify its integrity after download.

The file containing the checksum are signed with an OpenPGP key. The OpenWRT team uses a distinct "release signing key" to sign the checksum files of a major OpenWRT release and subsequent point releases.

The release keys are published on the 
`OpenWrtPublic Keys page <https://openwrt.org/docs/guide-user/security/signatures>`_.

So the steps necessary to download and verify a firmware image:

 #. Find appropriate firmware image file on the 
    `download site <https://downloads.openwrt.org/>`_ or one of the 
    `mirror sites <https://openwrt.org/downloads#mirrors>`_.
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

With the download script its enough to supply the URL of the firmware image to
download (as found in step 1. above)::

    desktop$ cd ~/Downloads
    desktop$ wget -O openwrt-download.sh \
    	https://openwrt.org/_export/code/docs/guide-user/security/release_signatures?codeblock=1
    desktop$ chmod 755 openwrt-download.sh
    desktop$ ./openwrt-download.sh \
    	https://downloads.lede-project.urown.net/releases/18.06.0/targets/ar71xx/generic/openwrt-18.06.0-ar71xx-generic-wndr3800-squashfs-factory.img


Firmware Installation
---------------------

Using NETGEARs factory default settings, you router should have setup an IPv4
network 192.168.1.1/24 on your LAN and Wireless LAN and use the IPv4 address
192.168.1.1 for itself.

If your workstation hasn't already be automatically configured for this
network you can do so manually::

	worktation$ sudo ip address add 192.168.1.$(( 100 + RANDOM % 150 ))/24 dev


Use the TAB key on your keyboard at the end of the command-line after 'dev' to
select your Ethernet device.

Open your router homepage at http://192.168.1.1/ with your browser.

Select the Administration page, use firmware file selection button and
firmware upgrade button to start firmware upgrade process.

Confirm firmwware upgrade to OpenWrt.

Wait upload process, firmware upgrade process, additional wait up to 10
minutes. You wiil be able to notice this moment when browser won't be load
http://192.168.1.1/index.htm at its next updating.



