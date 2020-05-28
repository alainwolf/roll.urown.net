3rd-party Software Packages Sources
===================================

Over time various software packages which required additional 3rd-party package
sources will be installed.

Its sometimes hard to remember which packages have been installed by a 3rd-party
package source.

To uninstall all packages from specific repository::

	$ sudo ppa-purge ppa:mc3man/trusty-media


Day of Ubuntu Walllpaper
------------------------

A classic.

`Direct Package download <https://launchpadlibrarian.net/34625118/day-of-ubuntu-wallpaper_1_all.deb>`_.

::

	$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x7A5579BA519AE6BB
	$ sudo nano /etc/apt/sources.list.d/dylanmccall-ppa-trusty.list


.. code-block:: text

	deb http://ppa.launchpad.net/dylanmccall/ppa/ubuntu karmic main
	# deb-src http://ppa.launchpad.net/dylanmccall/ppa/ubuntu karmic main



Devolo Powerline
----------------

Powerline home network products.

Website: https://www.devolo.com/en/Downloads

::

	$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x093E0372DBF92DF8
	$ sudo nano /etc/apt/sources.list.d/devolo-updates.list


.. code-block:: text

	### THIS FILE IS AUTOMATICALLY CONFIGURED ###
	# You may comment out this entry, but any other modifications may be lost.
	# In particular, do not add a comment behind the entry on the same line,
	# because that's what the Ubuntu Upgrade Managaer does when disabling all 
	# third-party repositories and that would cause this entry to be re-enabled.
	# See /etc/cron.daily/devolo-updates for more details.
	deb http://update.devolo.com/linux/apt/ stable main



Guardian Project KeySync
------------------------

Various Android security tools and apps.
Keysync

Websites: 
 * https://launchpad.net/~guardianproject/+archive/ubuntu/ppa
 * https://guardianproject.info/
 * https://guardianproject.info/apps/keysync/

::

	$ sudo add-apt-repository ppa:guardianproject/ppa


upmpdcli, upplay 
----------------

Ubuntu builds for the upmpdcli UPnP front-end for mpd, the upplay Linux UPnP
Control Point and the libupnpp library they depend on.

Websites: 
	* https://launchpad.net/~jean-francois-dockes/+archive/ubuntu/upnpp1
	* http://www.lesbonscomptes.com/upmpdcli/
	* http://www.lesbonscomptes.com/upplay/

::

	$ sudo add-apt-repository ppa:jean-francois-dockes/upnpp1


MPD Music Player Daemon
-----------------------



Tor Browser Launcher and OnionShare
-----------------------------------

Ubuntu software that isn't packaged yet, including Tor Browser Launcher and
OnionShare.

Websites:

 * https://launchpad.net/~micahflee/+archive/ubuntu/ppa
 * https://github.com/micahflee/torbrowser-launcher
 * https://onionshare.org/

::

	$ sudo add-apt-repository ppa:micahflee/ppa


Nextcloud Client
----------------

Official Nextcloud packages for Ubuntu.

Websites:
 * http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.04/
 * https://owncloud.org/install/#install-clients


 ::

 	$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x977C43A8BA684223
 	$ sudo nano /etc/apt/sources.list.d/owncloud-client.list


.. code-block:: text

 	deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.04/ /


Quimup
------

QUIMUP is a client for the music player daemon (MPD) written in C++ and QT3. The
focus is on mouse handling. Playlist management is done entirely by drag-&-drop.
Playback functions are directly accessible from the system tray. Supports album
art.

Websites: 
 * https://launchpad.net/~quimup/+archive/ubuntu/quimup
 * http://coonsden.com/

::

	$ sudo add-apt-repository ppa:quimup/quimup


Ring
----

Nightly releases for `Ring <http://ring.cx/>`_. Formerly called sflphone.

::

	$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0x9842E7BDE8E242F4
	$ sudo sh -c "echo 'deb [arch=amd64] http://nightly.apt.ring.cx/ubuntu_14.04/ ring main' \
		>> /etc/apt/sources.list.d/ring-nightly-man.list"


Conky Mamager
-------------

::

	$ sudo add-apt-repository ppa:teejee2008/ppa


Tor Project
-----------

Tor and the Tor GeoIP database.

::

	$ sudo apt-key adv --keyserver keys.gnupg.net --recv-keys 0xEE8CBC9E886DDD89
	$ sudo sh -c "echo 'deb http://deb.torproject.org/torproject.org trusty main' \
		>> /etc/apt/sources.list.d/torproject.org-mainline.list"
	$ sudo sh -c "echo '# deb-src http://deb.torproject.org/torproject.org trusty main' \
		>> /etc/apt/sources.list.d/torproject.org-mainline.list"


Wine
----

The Wine Windows Emulation for Linux.

::

	$ sudo add-apt-repository ppa:ubuntu-wine/ppa


heroku.list
nginx.org-mainline.list
