Instant Messaging
=================


Dino XMPP Client
----------------

`Dino <https://dino.im/>`_ is a modern open-source chat client for the desktop.
It focuses on providing a clean and reliable Jabber/XMPP experience while having
your privacy in mind.

Dino is secure by default: Your chats never leave your computer unencrypted.
Once you enabled end-to-end encryption via :term:`OMEMO` or :term:`OpenPGP`,
only you and your chat partners can read your messages, but not your server
administrator or anyone else.

If you want to increase your privacy, Dino allows you to disable read and typing
notifications – globally or only for specific contacts.

Dino is built on the :term:`XMPP` protocol, an internet standard for
decentralized communication – the instant messaging pendant to email.

Decentralization means you don't have to rely on a single provider or company,
instead you can use a federated world-wide infrastructure. You can even host
your own server!


Installation
^^^^^^^^^^^^

::

    $ sudo apt install dino-im


Signal Messenger
----------------

`Signal <https://signal.org/en/>`_ is a cross-platform encrypted messaging
service developed by the Signal Foundation and Signal Messenger LLC. It uses the
Internet to send one-to-one and group messages, which can include files, voice
notes, images and videos. Its mobile apps can also make one-to-one voice and
video calls, and the Android version can optionally function as an SMS
app.

Signal uses standard cellular telephone numbers as identifiers and uses
end-to-end encryption to secure all communications to other Signal users. The
apps include mechanisms by which users can independently verify the identity of
their contacts and the integrity of the data channel.

All Signal software is free and open-source. The clients are published under the
GPLv3 license, while the server code is published under the AGPLv3
license. The non-profit Signal Foundation was launched in February 2018 with
an initial funding of $50 million. 


Installation
^^^^^^^^^^^^

::

    $ curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
    $ echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
    $ sudo apt update && sudo apt install signal-desktop



Jitsi Video Conferencing
------------------------

**Jitsi** is a collection of free and open-source multiplatform voice (VoIP),
videoconferencing and instant messaging applications for the web platform,
Windows, Linux, macOS, iOS and Android. 

`The Jitsi project <https://jitsi.org/>`_ began with the **Jitsi Desktop**
(previously known as SIP Communicator). With the growth of :term:`WebRTC`, the
project team focus shifted to the **Jitsi Video Bridge** for allowing web-based
multi-party video calling. 

Later the team added **Jitsi Meet**, a full video conferencing application that
includes web, Android, and iOS clients. 

Jitsi also operates `meet.jit.si <meet.jit.si>`_, a version of Jitsi Meet hosted
by Jitsi for free community use.


Browser Access
^^^^^^^^^^^^^^

You can start your own conference or join any other one without installing any
software on your desktop computer.

Just point your browser to a public servers website and allow access to your
camera and microphone.

However Jitsi recommends using the `Chromium browser <https://www.chromium.org/>`_.

As of spring 2020, Firefox is not supported.


Installation
^^^^^^^^^^^^

If you prefer to have an installed client there is a AppImage

Trusting the software publisher::

    $ sudo apt-key adv --fetch-keys https://download.jitsi.org/jitsi-key.gpg.key


Adding the repository::

    $ echo 'deb https://download.jitsi.org stable/' | \
        sudo tee /etc/apt/sources.list.d/jitsi-stable.list
    $ sudo apt update


Install the package::

    $ sudo apt install 


Public Servers
^^^^^^^^^^^^^^

 A list of public accessible servers is available here:

 https://github.com/jitsi/jitsi-meet/wiki/Jitsi-Meet-Instances


Roll your own
^^^^^^^^^^^^^

See :doc:`/server/videcon/index`.
