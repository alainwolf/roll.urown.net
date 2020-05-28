Video Conferencing Server
=========================

`Jitsi <https://jitsi.org/>`_ is a collection of free and open-source 
multiplatform voice (VoIP), videoconferencing and instant messaging applications
for the web platform, Windows, Linux, Mac OS X and Android.

The `Jitsi open source repository <https://github.com/jitsi>`_ on Github 
currently contains 73 repositories. The major projects include:

 * **Jitsi Meet** – video conferencing server designed for quick installation on 
   Debian/Ubuntu servers;
 * **Jitsi** Videobridge – WebRTC Selective Forwarding Unit engine for powering 
   multi-party conferences;
 * **Jigasi** - server-side application that links allows regular SIP clients to 
   join Jit Meet conferences hosted by Jitsi Videobridge;
 * **lib-jitsi-meet** - A low-level JavaScript API for providing a customized UI 
   for Jitsi Meet;
 * **Jidesha** – a Chrome and Firefox extension for Jitsi Meet;
 * **Jitsi** – an audio, video, and chat communicator that supports protocols 
   such as SIP, XMPP/Jabber, AIM/ICQ, and IRC.


Basic Jitsi Meet install
------------------------

See `<https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md>`_.


Add the Jitsi package repository
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trusting the software publisher::

    $ sudo apt-key adv --fetch-keys https://download.jitsi.org/jitsi-key.gpg.key


Adding the repository::

    $ echo 'deb https://download.jitsi.org stable/' | \
        sudo tee /etc/apt/sources.list.d/jitsi-stable.list
    $ sudo apt update


   


