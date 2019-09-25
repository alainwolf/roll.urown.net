Electronic Books
================

.. image:: Calibre-logo.*
    :alt: Calibre Logo
    :align: right

`calibre <http://calibre-ebook.com/>`_ is a free and open source e-book library
management application developed by users of e-books for users of e-books. It
has a cornucopia of features divided into the following main categories:

 * Library Management
 * E-book conversion
 * Syncing to e-book reader devices
 * Downloading news from the web and converting it into e-book form
 * Comprehensive e-book viewer
 * Content server for online access to your book collection
 * E-book editor for the major e-book formats


Software Installation
---------------------

While calibre is available in the Ubuntu Software-Center, the `version available 
<apt://calibre>`_ is likely to be outdated.

The `Calibre download page <http://calibre-ebook.com/download_linux>`_ on the calibre
website provides a scary looking command line to download and install calibre
onn Linux desktop systems::

    $ sudo -v && \
        wget -nv -O- \
            https://raw.githubusercontent.com/kovidgoyal/calibre/master/setup/linux-installer.py |\
        sudo python -c "import sys; \
                        main=lambda:sys.stderr.write('Download failed\n'); \
                        exec(sys.stdin.read()); main()"


Synchronize with ownCloud
-------------------------

Calibre stores all books and its database in one directory (ususally called
:file:`Calibre Library` in your home directory). To access your collection of
electronic books from everywhere, especially with your reading and mobile
devices, synchronize this directory with :doc:`/desktop/owncloud-client`.

On the server-side, the library then is made available online by the
:doc:`/server/ebooks` server.


Digital Rights Management (DRM)
===============================

eBooks in the ePub-format protected by digital rights management (DRM).

Online libraries and book-shops sometimes distribute DRM protected files by
letting you download a file called :file:`URLLink.acsm`.

`Adobe Digital Editions <https://en.wikipedia.org/wiki/Adobe_Digital_Editions>`_ 
is needed to access these eBooks. Since there is no Linux version of Adobe 
Digital Editions, the Windows version is installed under :doc:`/desktop/wine`.


Adobe Digital Editions 4.5
--------------------------

From `WineHQ - Adobe Digital Editions 4.5 <https://appdb.winehq.org/objectManager.php?sClass=version&iId=33276&iTestingId=104640>`_:

1. Download Adobe Digital Editions 4.5 from its `official Adobe download page
<https://www.adobe.com/ch_de/solutions/ebook/digital-editions/download.html>`_.

2. Install required packages::
    
    $> sudo apt install winbind winetricks


3. Prepare a new 32-Bit Wine environment for Adobe Digital Editiions 4.5::

    $> WINEARCH=win32 WINEPREFIX="$HOME/.wineADE" wine wineboot


4. Install Microsoft Windows fonts and Microsoft .NET Framework 4::

    $> WINEARCH=win32 WINEPREFIX="$HOME/.wineADE" \ 
        winetricks corefonts dotnet40

6. Fix graphical display bugs::

    $> WINEARCH=win32 WINEPREFIX="$HOME/.wineADE" \
        winetricks  ddr=gdi


5. Install the downloaded Adobe Digital Editions 4.5::

    $> WINEARCH=win32 WINEPREFIX="$HOME/.wineADE" \
        wine ~/Downloads/ADE_4.5_Installer.exe

7. Start Adobe Digital Editions 4.5::

    $> WINEARCH=win32 WINEPREFIX="$HOME/.wineADE" \
        wine "c:\Program Files (x86)\Adobe\Adobe Digital Editions 4.5\DigitalEditions.exe"


Adobe Digital Edtions 2011
--------------------------

::

    WINEARCH=win32 WINEPREFIX=${HOME}/.wine32 winetricks adobe_diged

This creates a new wine environment in the directory 
:file:`${HOME}/.local/share/wineprefixes/adobe_diged`.



Technical Background
^^^^^^^^^^^^^^^^^^^^

The download site will serve the :file:`URLLink.acsm` as mime-type 
`application/vnd.adobe.adept+xml`.

Firefox will lookup how to handle this content in a file called
:file:`mimeTypes.rdf` in your Mozilla Firefox profile directory:

.. code-block:: xml

    <RDF:Description RDF:about="urn:mimetype:handler:application/vnd.adobe.adept+xml"
                   NC:alwaysAsk="true"
                   NC:useSystemDefault="true"
                   NC:saveToDisk="false">
    <NC:externalApplication RDF:resource="urn:mimetype:externalApplication:application/vnd.adobe.adept+xml"/>
    </RDF:Description>

The part "externalApplication" essentially means, ask the operating system
desktop environment to handle this.

Ubuntu Desktop will lookup its own database, to find out how to handle this. You
can query the database as follows:

::

    $> gio mime application/vnd.adobe.adept+xml
    Default application for “application/vnd.adobe.adept+xml”: wine-extension-acsm.desktop
    Registered applications:
        wine-extension-acsm.desktop
    Recommended applications:
        wine-extension-acsm.desktop

The :file:`wine-extension-acsm.desktop` is found in the
:file:`${HOME}/.local/share/applications` directory. It should contain the
command to start wine along with Adobe Digital Editions::

    $> cat /home/wolf/.local/share/applications/wine-extension-acsm.desktop
    [Desktop Entry]
    Type=Application
    Name=Adobe Digital Editions 4.5.10
    MimeType=application/vnd.adobe.adept+xml;
    Exec=env WINEPREFIX="/home/wolf/.wineADE" wine start /ProgIDOpen Adobe.ACSMessage %f
    NoDisplay=true
    StartupNotify=true
    Icon=3C25_DigitalEditions.0


De-DRM eBooks
-------------

The good news is, you can remove DRM from your eBooks. There is a plugin for
Calibre, the eBook library application, which once installed, will do this
automatically with every eBook you add to your Calibre library.

The bad news is, its a bit complicated to setup:

We use Calibre under Linux, but the Adobe DRM stuff runs under Windows only. To
run windows programs in Linux, the Windows emulation software called wine is
used.

The scripts who do the magic of releasing your eBooks from DRM are Python
scripts. As those Python scripts must access the Adobe Digital stuff, they also
have to be run in the same emulated Windows environment. Therefore our wine
environment needs to be able to run Python scripts. A Python-version for Windows
must therefore be installed under the wine environment.

DRM is done by encrypting the media-content and decrypting it only for
authorized access. The scripts use Python modules for cryptography, which also
must be installed under the wine environment.


Python for Windows
^^^^^^^^^^^^^^^^^^

Use the following command-line to install it::
    
    $ env WINEARCH=win32 WINEPREFIX="/home/wolf/.wineADE" winetricks python26


Python Crypto Modules
^^^^^^^^^^^^^^^^^^^^^

`PyCrypto 2.6 for 32bit Windows and Python 2.6 
<http://www.voidspace.org.uk/python/modules.shtml#pycrypto>`_::

    $ cd Downloads
    $ wget http://www.voidspace.org.uk/downloads/pycrypto26/pycrypto-2.6.win32-py2.6.exe
    $ env WINEARCH=win32 WINEPREFIX="/home/wolf/.wineADE" \
        wine pycrypto-2.6.win32-py2.6.exe


DeDRM Plug-in for Calibre
^^^^^^^^^^^^^^^^^^^^^^^^^

The DRM removal plugin can remove DRM from Kindle, eBooks Barnes & Noble ePub
ebooks, any ebooks using Adobe Digital Editions DRM and and the older Mobipocket
and eReader ebooks. 

1. Go to `Apprentice Alf’s Blog <http://apprenticealf.wordpress.com/>`_ and
download the tools archive :file:`DeDRM_tools_6.6.3.zip` or newer from the link
provided: `<https://github.com/apprenticeharper/DeDRM_tools/releases>`_.

2. Unzip the downloaded :file:`DeDRM_tools_6.6.1.zip`.

3. Open the Calibre Application

4. From the Preferences menu select “Change calibre behavior”.

5. Click on Plugins (under “Advanced”) — it looks like a jigsaw puzzle piece.

6. Click on the large “Load plugin from file” button

7. Navigate to the tools folder unzipped in step 2 and install the plug-in by
selecting the file
:file:`DeDRM_tools_6.6.3/DeDRM_calibre_plugin/DeDRM_plugin.zip`.


