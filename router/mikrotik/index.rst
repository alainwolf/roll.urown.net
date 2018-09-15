:orphan:

MikroTik RouterOS
=================

SSH

Certificates

Email
-----

::

	/tool e-mail



Scripts

	Backup

	Update-Check

	:global admin_email admin@urown.net
	:set current_os [/system routerboard get]

	/tool e-mail send to=$admin_email subject="RouterOS Update available"
		body="RouterOS Update available\nUptime = $UPTIME\nCPU Load = $CPU\nDSL1 = $DSL1\nDSL2 = $DSL2\nFTP = $FTP\n\nPowered by J." from=$gmailid server=$gmailip start-tls=yes


Scheduler
SNMP
