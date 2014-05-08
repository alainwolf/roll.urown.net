Additional Software
=====================

Automatic Updates
-----------------

.. note::
   The system must be able to send out mails, for this to work. See :doc:`/server/mail`


The **unattended-upgrades** package is used to automatically install updated packages. It is installed if selected during OS installation.

Check for it with::

    $ dpkg-query -W -f='${Status} ${Version}\n' unattended-upgrades


If it is not already, install it as follows::

    $ sudo apt-get install unattended-upgrades


To configure unattended-upgrades, edit 
:file:`/etc/apt/apt.conf.d/50unattended-upgrades` and adjust the following to fit your needs::

    Unattended-Upgrade::Allowed-Origins {
            "Ubuntu trusty-security";
    //      "Ubuntu trusty-updates";
    }; 

    Unattended-Upgrade::MinimalSteps "true";
    Unattended-Upgrade::Mail "root";
    Unattended-Upgrade::Remove-Unused-Dependencies "true";

 
Another useful package is **apticron**. apticron will configure a cron job to email an administrator information about any packages on the system that have updates available, as well as a summary of changes in each package.

To install the apticron package, in a terminal enter::

    $ sudo apt-get install apticron

Once the package is installed edit :file:`/etc/apticron/apticron.conf`, to set the email address and other options::

    EMAIL="root@example.com"


Useful Tools
------------

Some useful tools are not installed by default.

* htop
* pwgen
* MultiTail

To install these run::

    $ sudo apt-get install htop multitail pwgen


.. _increase-entropy:

Provide Entropy
---------------

.. warning::
   This is absolutely necessary for generation of encryption keys and 
   encryption of communication!

* **Pollinate** seeds the pseudo random number generator by connecting to one or
  more Pollen (entropy-as-a-service) servers over an (optionally) encrypted 
  connection and retrieve a random seed over HTTP or HTTPS. It is intended to 
  supplement the :file:`/etc/init.d/urandom` init script.

* **haveged** uses HAVEGE (HArdware Volatile Entropy Gathering and Expansion) to 
  maintain a 1M pool of random bytes used to fill `/dev/random` whenever the 
  supply of random bits in :file:`dev/random` falls below the low water mark of the 
  device.

To install these run::

   $ sudo apt-get install pollinate haveged

*haveged* is installed as services and automatically started. *pollinate* is 
started once every time the server starts up.