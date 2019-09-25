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



Packages
--------

Regular users rarely need to know how to install packages by hand, as
automatic package managers are available.

The de facto package manager for Sublime Text is 
`Package Control <https://packagecontrol.io/>`_.

There is a `simple installation <https://packagecontrol.io/installation>`_.

::

	$> cd "$HOME/.config/sublime-text-3/Installed Packages/"
	$> wget -O "Package Control.sublime-package"  \
		https://packagecontrol.io/Package%20Control.sublime-package


Sublime​Linter-php -  SublimeLinter 3 plugin for PHP, using php -l. 

nginx by brandonwamboldt - Improved syntax support for Nginx configuration
files

SublimeLinter-contrib-nginx-lint by irvinlim - SublimeLinter 3 plugin for
NGINX config files, using nginx-lint (using
https://github.com/temoto/nginx-lint).

Sublime​Linter - The code linting framework for Sublime Text 3 

HTML-CSS-JS Prettify - HTML, CSS, JavaScript, JSON, React/JSX and Vue code
formatter for Sublime Text 2 and 3 via node.js 

Editor​Config - Sublime Text plugin for EditorConfig - Helps developers maintain consistent coding styles between different editors 

Vim​Modelines - Sublime Text 3 plugin to parse and apply Vim modelines 



References
----------

 * `Official Sublime Text Documentation <https://www.sublimetext.com/docs/3/>`_

 * `Sublime Text Unofficial Documentation <https://sublime-text-unofficial-documentation.readthedocs.io/>`_

