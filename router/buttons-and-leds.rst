LEDs and Buttons
================

.. note::
   The following is specific to NETGEAR router models WNDR3700 and WNDR3800.


.. image:: wndr3800-front.*
    :alt: NETGEAR WNDR3800


LED Lights Configuration
------------------------

Goto **System -> LED Configuration** on the LUCI web interface:

https://router.lan/cgi-bin/luci/admin/system/leds


Power LED
^^^^^^^^^

.. image:: power-led.*
    :alt: Power LED
    :align: left

Shows the operational status of the device.

 * **Solid amber**: The router is starting up after being powered on.
 * **Solid green**: The router startup has completed and the router is ready.
 * **Off**: Power is not supplied to the router.
 * **Blinking green**: The firmware is corrupted.
 * **Blinking amber**: The firmware is upgrading, or the Restore Factory Settings button was pressed.


Settings are stored in :file:`/etc/config/system`::

    config led 'led_power'
        option name 'Power LED'
        option default '0'
        option trigger 'default-on'
        option sysfs 'netgear:green:power'



2.4 GHz Wi-Fi LED
^^^^^^^^^^^^^^^^^

.. image:: radio0-led.*
    :alt: 2.4 GHz LED
    :align: left

Shows the status of the 2.4 GHz wireless network.

 * **Solid green**: The unit is operating in 11n mode at 2.4 GHz.
 * **Blinking green**: Wireless data is been transmitted or received.
 * **Off**: The 11n 2.4 GHz wireless radio is off.

Settings are stored in :file:`/etc/config/system`::

    config led
        option name 'radio0'
        option sysfs 'ath9k-phy0'
        option default '0'
        option trigger 'phy0tpt'


5 GHz Wi-Fi LED
^^^^^^^^^^^^^^^

.. image:: radio1-led.*
    :alt: 5 GHz LED
    :align: left

Shows the status of the 5 GHz wireless network.

 * **Solid blue**: The unit is operating in 11n mode at 5 GHz.
 * **Blinking blue**: Wireless data is been transmitted or received.
 * **Off**: The 11n 5 GHz wireless radio is off.

Settings are stored in :file:`/etc/config/system`::

    config led
        option name 'radio1'
        option sysfs 'ath9k-phy1'
        option default '0'
        option trigger 'phy1tpt'


USB LED
^^^^^^^

.. image:: usb-led.*
    :alt: USB LED
    :align: left

Shows the status of any attached USB devices.

 * **Solid green**: The USB device had been accepted by the router and is ready to be used.
 * **Blinking**: The USB device is in use.
 * **Off**: No USB device is connected, or the Safely Remove Hardware button has been clicked and it is now safe to remove the attached USB device.

Settings are stored in :file:`/etc/config/system`::

    config led 'led_usb'
        option default '0'
        option interval '50'
        option sysfs 'netgear:green:usb'
        list port 'usb1-port1'
        list port 'usb1-port2'
        list port 'usb2-port1'
        list port 'usb2-port2'
        option name 'USB'
        option trigger 'usbdev'
        option dev '1-1'


Internet
^^^^^^^^

.. image:: wan-led.*
    :alt: Internet LED
    :align: left

Shows the status of the Internet connection.

 * **Solid green**: An IP address has been received; ready to transmit data.
 * **Solid amber**: The Ethernet cable connection to the modem has been detected.
 * **Off**: No Ethernet cable is connected to the modem.

Settings are stored in :file:`/etc/config/system`::

    config led 'led_wan'
        option name 'WAN LED (green)'
        option sysfs 'netgear:green:wan'
        option default '0'


Switch LEDs
^^^^^^^^^^^

Shows the status of any attached Ethernet cables and devices.

 * **Solid green**: A LAN port has detected a 1 Gbps link with an attached device.
 * **Solid amber**: One or more LAN ports have detected a 10/100 Mbps link with an attached device.
 * **Off**: No link is detected on any of the 4 LAN ports.


Buttons
-------

The NETGEAR WNDR3700 and WNDR3800 devices have two buttons on the front. One
for turning your WiFi on or off and one to setup your WiFi devices
automatically, without the need to enter SSIDs and passwords.


WLAN On/Off Button
^^^^^^^^^^^^^^^^^^

.. image:: wifi-toggle.*
    :alt: WLAN On/Off button
    :align: left

This button is not enabled on OpenWRT by default and additional software and
configuration is needed.

::

    router$ opkg update
    router$ opkg install wifitoggle

Configuration is stored in :file:`/etc/config/wifitoggle`::

    config wifitoggle

        # Internal name of the button to use.
        option button 'rfkill'

        # Keep Wifi state on reset, always 0 if Timer enabled
        option persistent '1'

        # Seconds for wifi to be turned off, 0 for no timer
        option timer '0'

        # LED light to use
        option led_sysfs 'netgear:green:wps'

        # Trigger to enable/disable LED
        option led_enable_trigger 'none'

        # For timer trigger, How long (in milliseconds) the LED should be off.
        option led_enable_delayoff '500'

        # For timer trigger, How long (in milliseconds) the LED should be on.
        option led_enable_delayon '500'

        # LED state before trigger: 0 means OFF and 1 means ON
        option led_disable_default '0'


Pressing and holding the wireless LAN button for 2 seconds turns the 2.4 GHz
and 5 GHz wireless radios on and off. 

If the 2.4 GHz and 5 GHz LEDs a re lit, then the wireless radio is on. If
these LEDs are off, then the wireless radios are turned off and you cannot
connect wirelessly to the router.


Wifi Protected Setup (WPS) Button
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. image:: wps-button.*
    :alt: WLAN On/Off button
    :align: left

This button is used to connect a wireless device or computer to your wireless
network by :term:`WPS` without the need to manually select the wireless
network and enter a password.

This is not enabled on OpenWRT by default and additional software and
configuration is needed.

See :doc:`wps` to set this up.

The LED below the WPS button blinks green when the router is trying to add the
wireless device or computer.

The LED stays solid green when wireless security is enabled in the router.

Settings are stored in :file:`/etc/config/system`::

    config led
        option name 'WPS LED (green)'
        option sysfs 'netgear:green:wps'
        option trigger 'none'
        option mode 'link'
        option default '1'
        option delayon '500'
        option delayoff '500'


Reset Button
^^^^^^^^^^^^

The label on the bottom of the router shows the router’s **Restore Factory
Settings** button, preset login information, MAC address, and serial number.


.. image:: wndr3800-back.*
    :alt: NETGEAR WNDR3800

.. image:: wndr3800-reset.*
    :alt: NETGEAR WNDR3800


To restore the factory default settings:

   #. Use a sharp object such as a pen or a paper clip to press and hold the
      **Restore Factory Settings** button, located on the bottom of the router,
      for over 5 seconds until the Power LED turns to blinking amber.

   #. Release the **Restore Factory Settings** button, and wait for the router
      to reboot. The factory default settings are restored so that you can
      access the router from your Web browser using the factory defaults.


Settings are stored in :file:`/etc/config/system`::

    config restorefactory
        option button 'reset'
        option action 'pressed'
        option timeout '5'


References
----------

 * https://openwrt.org/toh/netgear/wndr3700
 * https://openwrt.org/toh/netgear/wndr3800
