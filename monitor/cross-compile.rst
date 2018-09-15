:orphan:

Building with sbuild
--------------------

Create a clean disposable `Debian Stretch` building environment::

	$ sudo apt install debootstrap systemd-container
	$ sudo debootstrap stretch /var/lib/container/stretch http://deb.debian.org/debian
	$ sudo systemd-nspawn -D /var/lib/container/stretch




Building with pbuilder
----------------------

Create a `Debian Stretch` system environment::

	$ sudo apt install debootstrap systemd-container
	$ sudo debootstrap stretch /var/lib/container/stretch http://deb.debian.org/debian
	$ sudo systemd-nspawn -D /var/lib/container/stretch


Inside your Debian environment, install `pbuilder`,
the "personal package builder"::

	$ sudo apt-get install pbuilder debootstrap devscripts debian-archive-keyring


Create the personal package building environment::

	$ sudo pbuilder create --architecture armhf \
		--mirror https://debian.ethz.ch/debian/ \
		--distribution stretch \
		--debootstrapopts "--keyring=/usr/share/keyrings/debian-archive-keyring.gpg" \
		--debootstrapopts --arch=armhf \
		--debootstrapopts --variant=buildd
	$ echo 'PBUILDERSATISFYDEPENDSCMD="/usr/lib/pbuilder/pbuilder-satisfydepends-apt"' >> ~/.pbuilderrc


Get the source code::

	$ wget -O - https://packages.icinga.com/icinga.key | apt-key add -
	$ echo "deb-src http://packages.icinga.com/debian icinga-stretch main" >> /etc/apt/sources.list
	$ apt-get update
	$ apt-get source icinga2


Build::

	$ pbuilder build --host-arch armhf icinga2_2.8.1-1.stretch.dsc


Building with dpkg-buildpackage
-------------------------------

Create a clean disposable `Debian Stretch` building environment::

	$ sudo apt install debootstrap systemd-container
	$ sudo debootstrap stretch /var/lib/container/stretch http://deb.debian.org/debian
	$ sudo systemd-nspawn -D /var/lib/container/stretch


Inside you fresh Debian environment::

	$ wget --no-check-certificate -O - https://packages.icinga.com/icinga.key | apt-key add -
	$ echo "deb-src http://packages.icinga.com/debian icinga-stretch main" >> /etc/apt/sources.list
	$ echo "deb-src http://deb.debian.org/debian stretch main" >> /etc/apt/sources.list


Add support for the target CPU architecture::

	$ dpkg --add-architecture armhf
	$ apt-get update


Install the developers tool-chain::

	$ apt-get install build-essential crossbuild-essential-armhf
	$ apt-get install debhelper gcc-4.9-source libc6-dev:armhf \
		linux-libc-dev:armhf libgcc1:armhf binutils-arm-linux-gnueabihf bison \
		flex libtool gdb sharutils netbase libcloog-isl-dev libmpc-dev \
		libmpfr-dev libgmp-dev systemtap-sdt-dev autogen expect chrpath \
		zlib1g-dev zip


Try to install the package build-dependencies (it will fail, but we will see
what is missing)::

	$ cd /usr/local/src
	$ apt-get build-dep -a armhf icinga2
	Reading package lists... Done
	Reading package lists... Done
	Building dependency tree
	Reading state information... Done
	Some packages could not be installed. This may mean that you have
	requested an impossible situation or if you are using the unstable
	distribution that some required packages have not yet been created
	or been moved out of Incoming.
	The following information may help to resolve the situation:

	The following packages have unmet dependencies:
	 builddeps:icinga2:armhf : Depends: debhelper:armhf (>= 9)
	                           Depends: dh-systemd:armhf (>= 1.5)
	                           Depends: g++:armhf (>= 1.96) but it is not going to be installed
	                           Depends: make:armhf (>= 3.81)
	E: Unable to correct problems, you have held broken packages.


	$ apt install cpp-6:armhf



Get the source code::

	$ apt-get source icinga2


Build the package::

	$ cd icinga2-2.8.1
	$ CONFIG_SITE=/etc/dpkg-cross/cross-config.armhf DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -aarmhf -J8














 * https://suihkulokki.blogspot.ch/2017/06/cross-compiling-with-debian-stretch.html
