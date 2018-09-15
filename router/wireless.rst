Wireless
========

Wireless configuration in the web interface:

`LuCi / Network / Wireless <https://router.lan/cgi-bin/luci/admin/network/wireless/>`_

Wireless configuration files:

:file:`/etc/config/wireless`


WiFi Device Configuration
-------------------------

The Device Configuration section covers physical settings of the radio
hardware such as channel, transmit power or antenna selection which are shared
among all defined wireless networks (if the radio hardware is multi-SSID
capable).

The available options are highly dependent of the wireless hardware the router
has built in and the operating systems device driver.


2.4 GHz Radio
^^^^^^^^^^^^^


General Setup:

================================== ====================
Operating Frequency:
Mode                               :term:`802.11n`
:term:`Channel <WLAN Channel>`     **auto**
Width:                             **20 MHz**
Transmit Power:                    **auto**
================================== ====================


Advanced Settings:

================================== ====================
Country Code:                      **CH - Switzerland**
Allow legacy :term:`802.11b` rates **No**
:term:`Distance Optimization <>`   **15 meters**
Fragmentation Threshold
RTS/CTS Threshold
Force 40MHz mode
Beacon Interval
================================== ====================


5 GHz Radio
^^^^^^^^^^^


General Setup:

================================== ====================
Operating Frequency
Mode                               :term:`802.11n`
:term:`Channel <WLAN Channel>`     **auto**
Width                              **40 MHz**
Transmit Power                     **auto**
================================== ====================


Advanced Settings:

================================== ====================
Country Code                       **CH - Switzerland**
Allow legacy :term:`802.11b` rates **No**
:term:`Distance Optimization <>`   **10 meters**
Fragmentation Threshold
RTS/CTS Threshold
Force 40MHz mode
Beacon Interval
================================== ====================


WiFi Interface Configuration
----------------------------

Per network settings like encryption and mode of operation are grouped in the
Interface Configuration. 

Wireless Security
^^^^^^^^^^^^^^^^^

To get highest possible wireless network security, as
of August 2018 the following is recommended:

 #. Use :term:`WPA2-PSK` as encryption standard. Don't use :term:`WPA` or
    :term:`WEP` or any mixed mode.

 #. Use :term:`CCMP` as cipher. Don't use :term:`TKIP`.

 #. Create your own unique wireless network name (:term:`SSID`). Don't use
    common or often used names, provider names, your own name, etc. The
    network name will be used as :term:`Salt` to :term:`hash` your wireless
    password.

 #. Create a long wireless password (max. 63 characters) with
    :term:`diceware`.

 #. :term:`802.11w` Management Frame Protection will probably not work with all
    devices. Try to set it to "Mandatory". If some clients fail to connect, set 
    it back to "Optional". 

 #. Enable :term:`WPS` push button, if your router is in a secure location, 
    without physical access from strangers.


example.net
^^^^^^^^^^^


General Setup:

================ ================
Mode             **Access Point**
ESSID            **example.net**
Network          **lan**
Hide ESSID       **No**
:term:`WMM` Mode **Yes**
================ ================


Wireless Security:

================================================= ====================
Encryption                                        **WPA2-PSK**
Cipher                                            **Force CCMP (AES)**
Key                                               **\*\*\*\*\*\*\*\***
802.11r Fast Transition                           **No**
802.11w Management Frame Protection               **Optional**
802.11w maximum timeout
802.11w retry timeout
Enable key reinstallation (KRACK) countermeasures **Yes**
Enable WPS pushbutton, requires WPA(2)-PSK        **Yes**
================================================= ====================


MAC Filter:

================== ===========
MAC-Address Filter **Disable**
================== ===========


Advanced Settings:

=================================== ===========
Isolate Clients                     **No**
Interface Name 
Short Preamble                      **Yes**
DTIM Interval
Disassociate On Low Acknowledgement **Yes**
=================================== ===========


WNDR3700 & WNDR3800 Wireless Chipsets
-------------------------------------

NETGEAR WNDR3800 routers use Atheros AR9220 (for 5 GHz) and Atheros
AR9223 (for 2.4 GHz) wireless chips.

OpenWRT interfaces with these chips using the
`ath9k Linux wireless driver <https://wireless.wiki.kernel.org/en/users/drivers/ath9k>`_ .

Atheros AR9220/AR9223 Features:

 * Supports spatial multiplexing, cyclic-delay diversity (CDD), and maximal ratio combining (MRC)
 * BPSK, QPSK, 16 QAM, 64 QAM, DBPSK, DQPSK, and CCK modulation schemes
 * Data rates of up to 130 Mbps for 20 MHz channels and 300 Mbps for 40 MHz channels
 * Wireless multimedia enhancements quality of service support (QoS)
 * 802.11e-compatible bursting
 * Support for IEEE 802.11e, h, and i standards
 * WEP, TKIP, and AES hardware encryption
 * 20 and 40 MHz channelization
 * 32-bit 0–33 and 66-MHz PCI 2.3 interface
 * Reduced (short) guard interval
 * Frame aggregation
 * Block ACK
 * IEEE 1149.1 standard test access port and boundary scan architecture supported
 * 337-pin, 12 mm x 12 mm BGA package

Atheros AR9220 Features:

 * Dynamic frequency selection (DFS) is supported in 5-GHz bands
 * All-CMOS MIMO solution inter-operable with IEEE 802.11a/b/g/n WLANs
 * 2x2 MIMO technology improves effective throughput and range over existing 802.11a/b/g products
 * 2.4/5 GHz WLAN MAC/BB processing

Atheros AR9223 Features:

 * All-CMOS MIMO solution inter-operable with IEEE 802.11b/g/n WLANs
 * 2x2 MIMO technology improves effective throughput and range over existing 802.11b/g products
 * 2.4 GHz WLAN MAC/BB processing 


ath9k Modes of operation:

 * Station
 * AP
 * IBSS
 * Monitor
 * Mesh point
 * WDS
 * P2P GO/CLIENT

ath9k Features:

    * 802.11abg
    * 802.11n

        * HT20
        * HT40
        * AMPDU
        * Short GI (Both 20 and 40 MHz)
        * LDPC
        * TX/RX STBC

    * 802.11i

        * WEP 64 / 127
        * WPA1 / WPA2

    * 802.11d
    * 802.11h
    * 802.11w/D7.0
    * :term:`WPS`
    * WMM
    * LED
    * RFKILL
    * BT co-existence
    * AHB and PCI bus
    * TDLS
    * WoW
    * Antenna Diversity


References
----------

 * `OpenWrt WiFi configuration Guide <https://openwrt.org/docs/guide-user/network/wifi/basic#wpa_enterprise_access_point>`_
 * `OpenWrt Wireless FAQ <https://wiki.openwrt.org/doc/faq/faq.wireless>`_
 * `Linux Wireless Documentation <https://wireless.wiki.kernel.org/en/users/documentation>`_
 * `Atheros AR9220 Data Sheet <http://nice.kaze.com/AR9220.pdf>`_ (PDF)
 * `Atheros AR9223 Data Sheet <http://nice.kaze.com/AR9223.pdf>`_ (PDF)
