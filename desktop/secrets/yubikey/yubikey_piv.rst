YubiKey SmartCard
==================

.. image:: yubikey_neo.*
    :alt: YubiKey NEO
    :align: right


The YubiKey NEO support the Personal Identity and Verification Card (PIV)
interface specified in the National Institute of Standards and Technology
(NIST). This enables you to perform RSA or ECC sign and decrypt operations using
a private key stored on the YubiKey. Your YubiKey acts as a SmartCard in this
case, through common interfaces like PKCS#11.


Prerequisites
-------------


Additional Software
-------------------

* YubiKey PIV Manager (with graphic interface)
* YubiKey PIV Tool (command line)
* OpenSC - Smart card utilities with support for PKCS#15 compatible cards

::

    $ sudo apt install yubikey-piv-manager opensc libengine-pkcs11-openssl


Disable Gnome SmartCard Login
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

    As soon as you have installed `opensc` and the system detects your YubiKey
    as a SmartCard, the login und lock screen of Ubuntu will only allow
    SmartCard login.


To disable this behavior, disable ScmartCard logins in Gnome settings as
follows::

    $ sudo -u gdm env -u XDG_RUNTIME_DIR -u DISPLAY DCONF_PROFILE=gdm \
        dbus-run-session gsettings set org.gnome.login-screen \
            enable-smartcard-authentication false

    $ gsettings set \
        org.gnome.login-screen \
        enable-smartcard-authentication false

The first command is for the login screen, the second one for your user
session.


Setup the Yubikey
-----------------

If you have a YubiKey that was not previously set up with YubiKey PIV Manager, a
PIN has to be set the first time YubiKey PIV Manager is accessing the YubiKey.


The PIN
^^^^^^^

* The PIN is a password that you type when you are using your YubiKey to ...
    * request new certificates
    * log into websites using a certificate stored on your YubiKey
    * sign or decrypt mails using a certificate stored on your YubiKey
* The PIN must be 4 to 8 characters in length.
* The PIN can contain lower- and uppercase English characters and numbers.
* Use of nonalphanumeric characters in the PIN are possible but not recommended.
* Entering an incorrect PIN three times consecutively will cause the PIN to
  become blocked, rendering the SmartCard features of your YubiKey unusable.

Let KeepassX generate a random PIN.

The PUK
^^^^^^^

The PUK can be used to reset the PIN if it is ever lost or becomes blocked after
the maximum number of incorrect attempts. Setting a PUK is optional.

If you use your PIN as the Management Key, the PUK is disabled for technical
reasons.

The requirements and restrictions of the PUK are the same as for the PIN:

* The PUK must be 4 to 8 characters in length.
* The PUK may contain lower- and uppercase English characters and numbers.
* Use of nonalphanumeric characters in the PUK are possible but not recommended.

If PIN complexity is enforced, the same rules are applied to the PUK.

If the PUK ever becomes blocked, either by deliberately choosing to block it or
by giving the wrong PUK value 3 times, it can only be unblocked by performing a
complete reset.

Let KeepassX generate a random PUK.


Management Key
^^^^^^^^^^^^^^

By default the YubiKey PIV Manager lets you use the PIN as Management Key too.
**This is not recommended for security and compatibility reasons**.

* The Management Key must be a 24 byte long 3DES key (24-byte random hex string).


.. image:: KeePassX_YubiKey_NEO_Smart_Card.*
    :alt: Starting YubiKey PIV Manager


Setting the PIN
^^^^^^^^^^^^^^^

1. Start the "YubiKey PIV Manager" application from the Dash.

.. image:: yubikey_piv_start.*
    :alt: Starting YubiKey PIV Manager


2. Insert your YubiKey NEO in any USB slot.

YubiKey PIV Manager will detect that your YubiKey is not initialized and
therefore ask for a new PIN.

.. image:: yubikey_piv_init.*
    :alt: YubiKey PIV Initialization


3. Select "Use a separate key" under "Management Key".

A random 24 byte 3DES Key is automatically created to be used as management key.

.. image:: yubikey_piv_seperate_management_key.*
    :alt: YubiKey PIV Initialization - Using a separate Management Key


4. Deactivate "Generate a certificate for authentication" under "Authentication
certificate".

5. Enter the PIN generated with KeePassX earlier and confirm it.

6. Copy the Management Key to the clipboard and store it in KeePassX.

5. Enter the PUK generated with KeePassX earlier and confirm it.

7. Click OK.


Mozilla Applications Configuration
----------------------------------

The procedure is the same for Firefox Browser, Thunderbird Mail Client and Tor
Browser Bundle.

Find the location of the OpenSC PKCS#11 library installed earlier::

    > find /usr/lib -name opensc-pkcs11.so
    /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
    /usr/lib/x86_64-linux-gnu/pkcs11/opensc-pkcs11.so

The second one usually is just a link to the first one.

In your Mozilla Application ...

#. Open "Settings"
#. Select "Advanced"
#. Select "Certificates"
#. Click the "Cryptographic Modules" button
#. Click the "Load" button
#. Change the module name to "OpenSC PKCS#11 Module"
#. Enter the path of the library as found before (:file:`/usr/lib/x86_64-linux-gnu/opensc-pkcs11.so`)
#. Click the "Ok" button


References
----------

* `yubico.com: YubiKey PIV for Smart Card <https://www.yubico.com/support/knowledge-base/categories/yubikey-piv/>`_
* `dev.yubico: PIN and Management Key <https://developers.yubico.com/yubikey-piv-manager/PIN_and_Management_Key.html>`_
* `OpenSC Wiki <https://github.com/OpenSC/OpenSC/wiki/>`_
