Web Browser
===========

.. image:: firefox-logo.*
    :alt: Mozilla Firefox Logo
    :align: right
    :height: 200px
    :width: 200px


`Mozilla Firefox <https://www.mozilla.org/en-US/firefox/desktop/>`_ is default
web browser in Ubuntu and therefore already installed.

.. contents::


Settings
--------

Select "Edit" - "Preferences" from the menu.


General
^^^^^^^

Select the "General" tab in the Preferences dialog.

Change Home Page to *https://duckduckgo.com/*:

.. image:: Firefox-Preferences-General-Startup.*
    :alt: Mozilla Firefox - Preferences - General - Startup
    :scale: 75%

Untick "Prompt integration options for any website" below "Desktop Integration":

.. image:: Firefox-Preferences-General-Desktop.*
    :alt: Mozilla Firefox - Preferences - General - Desktop Integration
    :scale: 75%


Home & Search
^^^^^^^^^^^^^


Privacy & Security
^^^^^^^^^^^^^^^^^^

Select the "Privacy" tab in the Preferences dialog.

Select "Tell sites that I do not want to be tracked" under "Tracking":

.. image:: Firefox-Preferences-Privacy-Tracking.*
    :alt: Mozilla Firefox - Preferences - Privacy - Tracking
    :scale: 75%

History settings:

 * Select "Use custom settings for history".
 * Untick "Always use private browsing mode"
 * Untick "Remember my browsing and download history"
 * Untick "Remember search and form history"
 * Tick "Accept cookies from sites"
 * Select "Never" in the "Accept third-party cookies" dropdown.
 * Select "they expire" in the "Keep until" dropdown.
 * Tick "Clear history when Firefox closes"

.. image:: Firefox-Preferences-Privacy-History.*
    :alt: Mozilla Firefox - Preferences - Privacy - History
    :scale: 75%

Click the "Show Cookies..." Button:

You will see already an awful lot of cookies in the list, even on a freshly installed system after just a few minutes of browsing the web:

.. image:: Firefox-Preferences-Privacy-History-Cookies.*
    :alt: Mozilla Firefox - Preferences - Privacy - History - Cookies
    :scale: 75%

Click the "Remove All Cookies" Button and close the dialog.

Click the "Settings..." Button beisdes the checkmark "Clear history when Firefox
closes":

.. image:: Firefox-Preferences-Privacy-History-Clear.*
    :alt: Mozilla Firefox - Preferences - Privacy - History - Settings for Clearing History
    :scale: 75%

Don't worry about these rather restricting cookie-settings, as they will be
managed by some extensions we will install later on.


Advanced
^^^^^^^^

Select the "Advanced" tab in the Preferences dialog.
Select the "Data Choices" tab.

Untick "Enable Firefox Health Report":

.. image:: Firefox-Preferences-Advanced-Data.*
    :alt: Mozilla Firefox - Preferences - Advanced - Data Choices
    :scale: 75%

So Firefox borwser will no longer phone home.

After all these changes it might be time to restart Firefox.


Security and Privacy Extensions
-------------------------------

There are various `add-ons for Firefox
<https://addons.mozilla.org/en-US/firefox/>`_ which enhance security and
privacy.


uBlock Origin
^^^^^^^^^^^^^

`uBlock Origin <https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/>`_
is an efficient ad blocker: easy on memory and CPU footprint, and yet can load
and enforce thousands more filters than other popular blockers out there.


DNSSEC TLSA Validator
^^^^^^^^^^^^^^^^^^^^^

`DNSSEC TLSA Validator <https://addons.mozilla.org/en-US/firefox/addon/dnssec-validator/>`_
allows you to check the existence and validity of :term:`DNSSEC` and :term:`TLSA`
records related to the domain of the website you visit.

Colored icons in the browser address bar, indicate if a websites can be trusted,
by relying on digitally signed information provided by the owner of the websites
domain, without involvment of third-parties, like certificate authorities,
browser vendors et al.


Privacy Badger
^^^^^^^^^^^^^^

`Privacy Badger <https://www.eff.org/privacybadger>`_ stops advertisers and other
third-party trackers from secretly tracking where you go and what pages you look
at on the web. Currently in beta.

Privacy Badger is published by the `Electronic Frontier Foundation
<https://www.eff.org/>`_,


HTTPS Everywhere
^^^^^^^^^^^^^^^^

`HTTPS Everywhere <https://www.eff.org/https-everywhere>`_ automatically
connects you with HTTPS instead of HTTP on all websites that are known to
support HTTPS as well as HTTP. This includes connections to third-party sites
which may provide embedded content on a visited website.

HTTPS-Everywhere is published by the `Electronic Frontier Foundation
<https://www.eff.org/>`_ which maintains `a list
<https://www.eff.org/https-everywhere/atlas/>`_ of major websites supporting
HTTPS.


Perspectives
^^^^^^^^^^^^
`Perspectives <https://addons.mozilla.org/en-US/firefox/addon/perspectives/>`_
can ..

 * Provide a second-layer of security to detect attacks due to a compromised or
   malicious certificate authority.

 * Securely determine the validity of “self-signed” certificates that have not
   been signed by a certificate authority, avoiding the “scary” Firefox security
   error when it is safe to do so.

This plugin uses an existing set of Network Notary servers run by the
`Perspectives Project <http://www.perspectives-project.org>`_.

Perspectives is a new approach to helping computers communicate securely on the
Internet, based on a research project of the Computer Science Department at
Carnegie Mellon University. With Perspectives, public “network notary” servers
regularly monitor the TLS certificates used by 100,000s+ websites to help your
browser detect “man-in-the-middle” attacks without relying on certificate
authorities.

Visit the `Perspectives Project <http://www.perspectives-project.org>`_ for more
information how this works.


Decentraleyes
^^^^^^^^^^^^^

`Decentraleyes <https://addons.mozilla.org/en-US/firefox/addon/decentraleyes/>`_
protects you against tracking through "free", centralized, content delivery. It
prevents a lot of requests from reaching networks like Google Hosted Libraries,
and serves local files to keep sites from breaking. Complements regular content
blockers.

Blocked services:

    * Google Hosted Libraries
    * Microsoft Ajax CDN
    * CDNJS (Cloudflare)
    * jQuery CDN (MaxCDN)
    * jsDelivr (MaxCDN)
    * Yandex CDN
    * Baidu CDN
    * Sina Public Resources
    * UpYun Libraries.

Bundles ressources:

    * AngularJS
    * Backbone.js
    * Dojo
    * Ember.js
    * Ext Core
    * jQuery
    * jQuery UI
    * Modernizr
    * MooTools
    * Prototype
    * Scriptaculous
    * SWFObject
    * Underscore.js
    * Web Font Loader


Self-Destructing Cookies
^^^^^^^^^^^^^^^^^^^^^^^^

The `Self-Destructing Cookies <https://addons.mozilla.org/en-US/firefox/addon/self-destructing-cookies/>`_
extension gets rid of a site's cookies and LocalStorage as soon as you close its
tabs. This way it protects your browser from trackers and zombie-cookies.
Trustworthy services can be whitelisted.


Other Useful Extensions
^^^^^^^^^^^^^^^^^^^^^^^

Following are some extensions which are not directly related to privacy and
security but recommended as useful:

`SixOrNot <https://addons.mozilla.org/en-us/firefox/addon/sixornot/>`_
- IPv4/IPv6 Protocol Indicator.

`Cert Viewer Plus <https://addons.mozilla.org/en-US/firefox/addon/cert-viewer-plus/>`_
- Certificate viewer enhancements: PEM format view, file export, trust
configuration.

`Context Search <https://addons.mozilla.org/en-US/firefox/addon/context-search/?src=search>`_
- Expands the context menu's 'Search for' item into a list of installed search
engines, allowing you to choose the engine you want to use for each search.

`GNotifier <https://addons.mozilla.org/en-US/firefox/addon/gnotifier/>`_
- GNotifier integrates Firefox's notifications with the native
notification system from various Linux desktops including Unity.

`HeadingsMap <https://addons.mozilla.org/en-US/firefox/addon/headingsmap/>`_ -
The extension generates a documentmap or index of any web document structured
with headings and/or with sections in HTML.

`SPDY indicator <https://addons.mozilla.org/en-US/firefox/addon/spdy-indicator/>`_ - An indicator showing SPDY support in the address bar.

`Uppity <https://addons.mozilla.org/en-US/firefox/addon/uppity/>`_ - Navigate
up one level (directory) in the currently displayed website.


Extensions To Disable
^^^^^^^^^^^^^^^^^^^^^

Ubuntu installs its own extension, which might be disabled:

 * Unity Websites integration


Search-Engines
--------------

There are alternative search engines who offer same quality, but better privacy,
as the ones from Google, Yahoo or Microsoft.

DuckDuckGo
^^^^^^^^^^

`DuckDuckGo <https://duckduckgo.com/>`_ is an Internet search engine that
emphasizes protecting searchers privacy and avoiding the :term:`filter bubble`
of personalized search results. DuckDuckGo gets its results from over one
hundred `different sources <https://duck.co/help/results/sources>`_.

See `their Firefox help page
<https://duck.co/help/desktop/firefox>`_ for ways to use it with Firefox.


StartPage
^^^^^^^^^

`Startpage <https://startpage.com/>`_ puts itself between your browser and the
Google search engine. The search results are generated by Google, but without
your computer connecting with Google servers.

Additionally they offer to fetch any website and display it for you,  without
that any connection between your computer and the target website is made.

See their `"Add to browser" page
<https://startpage.com/eng/download-startpage-plugin.html?>`_ for help to add it
as search engine.


Mycroft Project
^^^^^^^^^^^^^^^

The `Mycroft project <http://mycroftproject.com/search-engines.html>`_ is a
directory of thousends of search engines, which can be each added to your search
egine list.


Search-Engines to Remove
^^^^^^^^^^^^^^^^^^^^^^^^

The following search engines can be removed, by clicking the dropdown list of
search engines and choosing the "Manage Search Engines" entry at the bottom of
the list:

 * Google
 * Yahoo!
 * Bing
 * Amazon
 * eBay

.. image:: Firefox-ManageSearchEngines.*
    :alt: Mozilla Firefox - Manage Search Engines
    :scale: 75%

Click on the "Remove" Button for every search engine you want to have removed.


Security Tests
--------------

Various pages check your browser for vulnerabilities against current threats.

`How's My SSL? <https://www.howsmyssl.com/>`_ is a cute little website that
tells you how secure your TLS client is. TLS clients just like the browser
you're reading this with.

`SSL Labs Client Test <https://www.ssllabs.com/ssltest/viewMyClient.html>`_
shows you the SSL/TLS Capabilities of your Browser and vulnerabilities against
selected discovered security issues (i.e. FREAK, POODLE).

`Qualys® BrowserCheck <https://browsercheck.qualys.com/>`_ recommends you to
scan your browser regularly to stay up to date with the latest versions and
plugins.


Other Protocol Links
--------------------

Type ``about:config`` into the Firefox address bar.

Left click your mouse on the displayed list of configuration values to add new values

Select "New" - "Boolean" from the fly-out-menu.


XMPP Instant Messaging
^^^^^^^^^^^^^^^^^^^^^^

In the appearing dialog input the following string:

 ``network.protocol-handler.expose.xmpp``

 Set it to ``true``

Select "New" - "String" from the fly-out-menu.

In the appearing dialog input the following string:

 ``network.protocol-handler.app.xmpp``

 Set it to ``/usr/bin/purple-url-handler``



