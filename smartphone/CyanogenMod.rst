CyanogenMod
===========

.. image:: CyanogenMod-logo.*
    :alt: CyanogenMod Logo
    :align: right

`CyanogenMod <http://www.cyanogenmod.org/>`_ (pronounced sigh-AN-oh-jen-mod), is
a customized, aftermarket :term:`firmware` distribution for several Android
devices. Based on the Android Open Source Project, CyanogenMod is designed to
increase performance and reliability over Android-based ROMs released by vendors
and carriers such as Google, T-Mobile, HTC, etc. CyanogenMod also offers a
variety of features & enhancements that are not currently found in these
versions of Android.

The main advantages over the device manufacturers original :term:`firmware`
(often called :term:`stock ROM`) are ...

 * Monthly updates.
 * Latest Android releases.
 * Security fixes and updates.
 * No software clutter from device manufacturer.
 * Google software and services are optional.
 * Privacy enhacements.

There is one disadvantage:

 * Your device warranty with the manufacturer may be voided.


Supported Devices
-----------------

On the `Devices <http://wiki.cyanogenmod.org/w/Devices>`_ page in the CyanogenMod
Wiki you can check if your Android device is supported.


Desktop Software
----------------

Install the following software from the Ubuntu software repository on your
Ubuntu desktop computer, to prepare the CynogenMod installation to your device.

 * `Heimdall Flash <apt://heimdall-flash-frontend>`_ to transfer and install 
   :term:`firmware` images (flash) to the Android device.

 * `Android Debug Bridge <apt://android-tools-adb>`_ 
   to manage the Android device, while connected over over USB-cable.


Preparations
------------

You need serveral things ready on your desktop computer.


Recovery Image
^^^^^^^^^^^^^^

The recovery image is a special small :term:`firmware` with limited
capabilities. It is needed to install and update the full Android system
software, as this can't be done while Android is already running. It is
therefore installed in a seperate small partition beneath the Android system.

Like the CyanogenMod firmware you need the recovey image tailored to your device.


Firmware Image
^^^^^^^^^^^^^^

The CynogenMod firmware image must have been built to match your device exactly.


Optional Google Apps Image
^^^^^^^^^^^^^^^^^^^^^^^^^^

CyanogenMod runs perfectly well without any of the usual Google apps. And with
the features described in this guide, there is absolutely nothing you should
miss, that Google provides with its various services. 

However, if you have already bought 3rd-party Android apps form the Google
android apps market, you will not be able to install them or run them, since
their license can not be veryfied by Goggle without your personal registration.

So if you still need Google Apps and services, you need to download the package
relevant to the Android version installed.


Fully charged Android Device
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

As usual, you don't want your device to shut down on the middle of a system
update.
