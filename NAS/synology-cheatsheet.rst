:orphan:

Synology DiskStation Cheat-Sheet
================================

Command-Line Tools
------------------

Synology Services
^^^^^^^^^^^^^^^^^

::

	$ synoservice --help
	Copyright (c) 2003-2018 Synology Inc. All rights reserved.

	SynoService Tool Help (Version 15266)
	Usage: synoservice
		--help					Show this help
		--help-dev				More specialty functions for deveplopment
		--is-enabled			[ServiceName]	Check if the service is enabled
		--status				[ServiceName]	Get the status of specified services
		--enable				[ServiceName]	Set runkey to yes and start the service (alias to --start)
		--disable				[ServiceName]	Set runkey to no and stop the service (alias to --stop)
		--hard-enable			[ServiceName]	Set runkey to yes and start the service and its dependency (alias to --hard-start)
		--hard-disable			[ServiceName]	Set runkey to no and stop the service and its dependency (alias to --hard-stop)
		--restart				[ServiceName]	Restart the given service
		--reload				[ServiceName]	Reload the given service
		--pause					[ServiceName]	Pause the given service
		--resume				[ServiceName]	Resume the given service
		--pause-by-reason		[ServiceName]	[Reason]	Pause the service by given reason
		--resume-by-reason		[ServiceName]	[Reason]	Resume the service by given reason
		--pause-all		(-p)	[Reason]	(Event)	Pause all service by given reason with optional event(use -p to include packages)
		--pause-all-no-action	(-p)	[Reason]	(Event)	Set all service runkey to no but leave the current service status(use -p to include packages)
		--resume-all			(-p)	[Reason]	Resume all service by given reason(use -p to include packages)
		--reload-by-type		[type]	(buffer)	Reload services with specified type
		--restart-by-type		[type]	(buffer)	Restart services with specified type
									Type may be {file_protocol|application}
									Sleep $buffer seconds before exec the command (default is 0)


Package Control
^^^^^^^^^^^^^^^

::

	$ synopkgctl
	usage: synopkgctl <command> [...]

	command:
		correct-cfg [--config-only|--status-only] [package]
		enable <package>
		setup <package>
		start <package>
		stop <package>
		swap-on
		teardown <package>
		wait [--timeout sec] [--check_interval sec] bootup|shutdown



Power off or Reboot
^^^^^^^^^^^^^^^^^^^

::

	$ synopoweroff --help
	DS shutdown progress feasible check.
	Default: Check poweroff feasibility and shutdown if pass checks.

	usage: synopoweroff [OPTIONS]

	-h	display this help
	-f	do reboot/shutdown WITHOUT feasibility check and WITHOUT DSM auto update
	-r	do reboot rather than shutdown
	-d	debug mode
		Check poweroff feasibility and reboot if pass checks.
		Will not stop synorelayd, sshd, and telnet.


Troubleshooting
---------------

SSH Public Keys
^^^^^^^^^^^^^^^

After installing SSH public keys, they will not work out of the box because of wrong directory and file permissions

To fix it::

	$ cd
	$ chmod 0700 . .ssh
	$ chmod 0600 .ssh/authorized_keys


DSM not accessible
^^^^^^^^^^^^^^^^^^

On a freshly installed DS218play, I changed some the following settings in
**Control-Panel/Network/DSM Settings** :

Domain

Enable customized domain: Yes

Domain: <name.example.net>


After the usual reload DSM was no longer reachable, instead a page with the
Synology logo and the following message is displayed:

	**"Sorry, the page you are looking for is not found."**

File-sharing and other services are running fine. SSH console login is still
possible. Just no access to the web interface.

The error is displayed by the Nginx web server running on the DiskStation.

While looking at the Nginx configuration on the DiskStation::

	$ cat /etc/nginx/nginx.conf

It looks like this has been set deliberately:

.. code-block:: nginx

    upstream synoscgi {
        server unix:/run/synoscgi.sock;
    }

    server {
        listen <my_random_https_port> ssl http2;
        listen [::]:my_random_https_port ssl http2;

        server_name <name.example.net>;

        location / {
            return 404;
        }

        error_page 403 404 500 502 503 504 @error_page;

        location @error_page {
            root /usr/syno/share/nginx;
            rewrite (.*) /error.html break;
        }

    }

    server {
        listen <my_random_http_port>;
        listen [::]:<my_random_http_port>;

        server_name <name.example.net>;

        location / {
            return 404;
        }

        error_page 403 404 500 502 503 504 @error_page;

        location @error_page {
            root /usr/syno/share/nginx;
            rewrite (.*) /error.html break;
        }

    }

Many other server configurations are found in that file, with the default
hostname :file:`server_name _;`


Custom DDNS and IPV6
^^^^^^^^^^^^^^^^^^^^

Go to Control Panel/External Access/DDNS

Click the "Customize" button.

Add a new custom service. We are using **nsupdate.info**

Service provider: **ipv6.nsupdate.info**

Query URL: **https://ipv6.nsupdate.info/nic/update**

Click the "Save" button.

Then Click the "Add" button,

Select "ipv6.nsupdate.info" from the drop-down list.

The external address IPv6 will always remain disabled.



