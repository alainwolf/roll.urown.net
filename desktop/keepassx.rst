KeePassX
========

`KeePassX <https://www.keepassx.org/>`_ is probably the single most important 
software program and personal database.

Every piece of information that needs to stay private should be kept exclusively 
in the KeePassX database.

Installation
------------

KeePassX is in the Ubuntu software repository:

`Click here to install KeePassX <apt://keepassx>`_


Keyboard Issue
--------------

If you are using a non-english keyboard layout like german (DE) or swiss (CH) 
the auto-type function of KeePassX will type wrong special-characters in 
usernames and passwords. To work around this problem, one can set the used 
keyboard layout to the X-Windows system::

	$ setxkbmap <keymap>

Where *<keymap>* is the keymap you use (ch, fr, en-us, de, ..., etc.).

.. note::
   The following procedure has to be done again every time KeePassX is updated 
   or reinstalled.


To do this automatically every time you start KeePassX, edit the file 
:file:`/usr/share/keepassx.desktop` and modify the command on the line which 
says **Exec** from :code:`Exec=keepassx %f` to 
:code:`Exec=sh -c 'setxkbmap <keymap> && keepassx %f'`. Where <keymap> is the keymap 
you use (ch, fr, en-us, de, ..., etc.).

::

	$ sudo editor /usr/share/applications/keepassx.desktop

.. code-block:: bash
   :linenos:
   :emphasize-lines: 7

	[Desktop Entry]
	Name=KeePassX
	GenericName=Cross Platform Password Manager
	GenericName[de]=Passwortverwaltung
	GenericName[es]=Gestor de contraseñas multiplataforma
	GenericName[fr]=Gestionnaire de mot de passe
	Exec=Exec=sh -c 'setxkbmap ch && keepassx %f'
	Icon=keepassx
	Comment=Cross Platform Password Manager
	Comment[de]=Passwortverwaltung
	Comment[es]=Gestor de contraseñas multiplataforma
	Comment[fr]=Gestionnaire de mot de passe
	Terminal=false
	Type=Application
	Categories=Qt;Utility;Security;
	MimeType=application/x-keepass;
	X-SuSE-translate=true


Reference
^^^^^^^^^

`Ask Ubuntu - KeePassX Auto-Type is no longer operational
<http://askubuntu.com/questions/330617/keepassx-auto-type-in-no-longer-operational/380722#380722>`_