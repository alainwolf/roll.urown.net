Entropy
=======

.. note::
   Random numbers are very important for the generation of encryption keys and 
   while encrypting communications. See [GCJ13]_.


Non-interactive systems (like servers) have a higher risk of not having enough 
random data available. Especially when they have just been installed, just 
rebooted or not many services have been running yet. See [KAea14a]_.

This section is to make sure enough random numbers are available at all times.


How much is available
---------------------

The following commands shows you how much random data is available::

	$ cat /proc/sys/kernel/random/entropy_avail


Software Installation
---------------------

The following software packages help to ensure that enough random data is 
available right from the start of the server and at all times during its 
operation:

* **Pollinate** seeds the pseudo random number generator by connecting to one or
  more Pollen (entropy-as-a-service) servers over an (optionally) encrypted 
  connection and retrieve a random seed over HTTP or HTTPS. It is intended to 
  supplement the :file:`/etc/init.d/urandom` init script.

* **haveged** uses HAVEGE (HArdware Volatile Entropy Gathering and Expansion) to 
  maintain a 1M pool of random bytes used to fill `/dev/random` whenever the 
  supply of random bits in :file:`dev/random` falls below the low water mark of 
  the device.

To install these run::

   $ sudo apt-get install pollinate haveged

*haveged* is installed as services, automatically started and runs all the time.
*pollinate* will run only once when the server just has been started and the 
random-numbers-pool may still be empty.

You may check the random-numbers pool again, to see the difference::

	$ cat /proc/sys/kernel/random/entropy_avail

Re-Generate Keys
----------------

OpenSSH
^^^^^^^

OpenSSH usually generates server automatically when the server starts the first 
time and there are no keys availble. Since its not clear if there was enouch 
random data available, OpenSSH keys should be regenerated once the packages 
above have been installed.


OpenSSL
^^^^^^^

If you have already genenrated keys (as in :doc:`server-tls`) on this server 
before, you should discard them and genreate new ones.


GNuPG
^^^^^

Same is valid for OpenPGP / GnuPG keys.
