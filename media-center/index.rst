:orphan:

Media Center
============

Software Updates
----------------

::

	$> sudo apt update
	$> sudo apt dist-upgrade
	$> sudo apt autoremove
	$> sudo apt autoclean


Security Settings
-----------------


Change Password
^^^^^^^^^^^^^^^

::

	desktop$ ssh osmc@media-center.example.net
	osmc@media-center.example.nets password: 
	osmc
	media-center$ passwd


SSH Key Login
^^^^^^^^^^^^^

::

	desktop$> ssh-copy-id osmc@media-center.example.net


Disable Password Authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Edit :file:`/etc/ssh/sshd_config` and change the following lines as follows::

	
	# Enable public key authentication
	PubkeyAuthentication yes

	# Disable password authentication
	PasswordAuthentication no


Restart the SSH service::

	media-center$> sudo systemctl restart ssh.service


SSH Host Key Fingerprints
^^^^^^^^^^^^^^^^^^^^^^^^^

ED 25519 Key::

	media-center$> ssh-keygen -r media-center.example.net -f /etc/ssh/ssh_host_ed25519_key.pub 


RSA Key::

	media-center$> ssh-keygen -r media-center.example.net -f /etc/ssh/ssh_host_rsa_key.pub


Hardware Video Decoder
----------------------

MPEG-2 and VC-1 license keys are available for £3.00 GBP from the 
`Raspberry Pi Store <http://www.raspberrypi.com/>`_.

Make note of your Raspberry Pi CPU serial::

	media-center$> cat /proc/cpuinfo

	Hardware	: BCM2835
	Revision	: a02082
	Serial      : 0000000012345678

Use the serial to order the license keys on the 
`Raspberry Pi Store <http://www.raspberrypi.com/>`_.

You will receive the license keys a few days later by email along with instructions::

	media-center$> echo "decode_MPG2=0x12345678" | sudo tee -a /boot/config.txt
	media-center$> echo "decode_WVC1=0x12345678" | sudo tee -a /boot/config.txt
	media-center$> reboot


Enable IPv6 Support
-------------------

::

	media-center$> sudo connmanctl
	connmanctl> services
	*AO Wired                ethernet_b827eb5e2aed_cable
	connmanctl> config ethernet_b827eb5e2aed_cable --ipv6 auto
	connmanctl> quit


CEC
---

CEC (Consumer Electronics Control) allows for control of devices over the HDMI port. 

Kodi on the Raspberri Pi has built-in support for CEC. If your TV-Set supports
it, you should be able to control Kodi by your TV remote and TV should be able
to switch on and off automatically when playback starts and stops.


References
----------

 * https://osmc.tv/wiki/raspberry-pi/frequently-asked-questions/
 * https://kodi.wiki/view/Raspberry_Pi_FAQ
