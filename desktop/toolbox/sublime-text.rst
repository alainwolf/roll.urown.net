.. image:: sublime-text-logo.*
    :height: 200px
    :width: 200px
    :alt: Sublime Text Logo
    :align: right


Sublime Text 
============

`Sublime Text <https://www.sublimetext.com/>`_ is a proprietary cross-platform
source code editor with a Python application programming interface (API). It
natively supports many programming languages and markup languages, and
functions can be added by users with plugins, typically community-built and
maintained under free-software licenses. 


Software Installation
---------------------

Install the projects PGP key::

	$> wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -


Ensure apt is set up to work with https sources::

	$> sudo apt install apt-transport-https


Add the stable software release channel::

	$> echo "deb https://download.sublimetext.com/ apt/stable/" | \
		sudo tee /etc/apt/sources.list.d/sublime-text.list


Update apt sources and install Sublime Text::

	$> sudo apt update
	$> sudo apt install sublime-text



Package Control
^^^^^^^^^^^^^^^

Packages are a collection of resource files used by Sublime Text: plugins,
syntax highlighting definitions, menus, snippets and more.


Regular users rarely need to know how to install packages by hand, as
automatic package managers are available.

The de facto package manager for Sublime Text is 
`Package Control <https://packagecontrol.io/>`_.


To install Package Control in Sublime Text 3 open the Tools menu and select the
"Install Package Control ..." menu entry.

There is also a `simple installation <https://packagecontrol.io/installation>`_
procedure for older versions.

::

	$> cd "$HOME/.config/sublime-text-3/Installed Packages/"
	$> wget -O "Package Control.sublime-package"  \
		https://packagecontrol.io/Package%20Control.sublime-package


After that you can access it in the "Preferences" menu as "Package Comtrol".

To install a package, select "Install a package" which opens a search box, where
you can look for the package name.


Recommended Packages
--------------------


`Editor​Config <https://packagecontrol.io/packages/EditorConfig>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sublime Text plugin for `EditorConfig <https://editorconfig.org/>`_. Helps
developers maintain consistent coding styles between different editors 


`Emacs-like Modelines <https://packagecontrol.io/packages/Emacs-like%20Modelines>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Emacs-like Modelines for Sublime Text 2 (and 3).



`Sublime Linter <https://packagecontrol.io/packages/SublimeLinter>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The code linting framework for Sublime Text 3. 

*lint*, or a *linter*, is a static code analysis tool used highlight programming
errors, bugs, stylistic errors, and suspicious constructs. The term originates
from a Unix utility that examined C language source code.

You then install plug-ins for any script and programming languages you need.


`Sublime​Linter-shellcheck <https://packagecontrol.io/packages/SublimeLinter-shellcheck>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This linter plugin for SublimeLinter provides an interface to 
`shellcheck <https://www.shellcheck.net/>`_, to find bugs in shell-scripts. 


Before using this plug-in, ensure that shellcheck is installed on your system::

    $> sudo apt install shellcheck



`Sublime​Linter-php <https://packagecontrol.io/packages/SublimeLinter-php>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SublimeLinter 3 plugin for PHP, using :file:`php -l`. 

This requires that a `php <https://www.php.net/>`_ command-line interpreter is
installed as well::

    $> sudo apt install php-cli



`nginx <https://packagecontrol.io/packages/nginx>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Syntax highlighting for Nginx configuration files.


`INI <https://packagecontrol.io/packages/INI>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Syntax highlighting for INI and REG files in Sublime Text.


`HTML-CSS-JS Prettify <https://packagecontrol.io/packages/HTML-CSS-JS%20Prettify>`_
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This is a Sublime Text 2 and 3 plugin allowing you to format your HTML, CSS,
JavaScript, JSON, React and Vue code. It uses a set of nice beautifier scripts
made by Einar Lielmanis. The formatters are written in JavaScript, so you'll
need something like `node.js <https://nodejs.org/en/>`_ to interpret the
JavaScript code outside the browser.

This will work with either HTML, CSS, JavaScript, JSON, React and Vue files.


To install Node::

    $> sudo apt install nodejs




References
----------

 * `Official Sublime Text Documentation <https://www.sublimetext.com/docs/3/>`_

 * `Sublime Text Unofficial Documentation <https://sublime-text-unofficial-documentation.readthedocs.io/>`_

