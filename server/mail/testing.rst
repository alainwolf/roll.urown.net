Mail Services Testing
=====================


`Test the Spammyness of your Emails <https://www.mail-tester.com/>`_


Sending a Test Message
^^^^^^^^^^^^^^^^^^^^^^

::

    $ echo "Hello World" | mail -s "Test Message" john@example.net


Test Mail Routing
--------------------

Produce two types of mail delivery reports for debugging:

What-If
^^^^^^^

Rport what would happen, but do not actually deliver mail. This mode
of operation is requested with::

    $ /usr/sbin/sendmail -bv user@domain.tld

SMTP Sessions
-------------

.. Note::

    Note the space in front of the command-line. It avoids saving your password
    in the command-line history.


Preparing username and password for the **AUTH-PLAIN** method::

    $  echo -ne '\000john@example.net\000********' | base64 -w0 ; echo
    AGpvaG5AZXhhbXBsZS5uZXQAKioqKioqKio=


Preparing username and password for the **LOGIN** method::

    $ echo -ne 'john@example.net' | base64 -w0 ; echo
    am9obkBleGFtcGxlLm5ldA==
    $  echo -ne '********' | base64 -w0 ; echo
    KioqKioqKio=


Submission Server
-----------------

::

    $ openssl s_client -starttls smtp -connect mail.example.net:submission

.. code-block:: text

    > 220 mail.example.net ESMTP Postfix
    EHLO torres.example.net
    > 250-mail.urown.net
    > 250-PIPELINING
    > 250-SIZE 26214400
    > 250-VRFY
    > 250-ETRN
    > 250-AUTH PLAIN LOGIN
    > 250-AUTH=PLAIN LOGIN
    > 250-ENHANCEDSTATUSCODES
    > 250-8BITMIME
    > 250-DSN
    > 250-SMTPUTF8
    > 250 CHUNKING


AUTH PLAIN
^^^^^^^^^^

.. code-block:: text

    AUTH PLAIN AGpvaG5AZXhhbXBsZS5uZXQAKioqKioqKio=
    > 235 2.7.0 Authentication successful


AUTH LOGIN
^^^^^^^^^^

.. code-block:: text

    AUTH LOGIN
    334
    am9obkBleGFtcGxlLm5ldA==
    334
    KioqKioqKio=


SMTP Secure Server
------------------

::

    $ openssl s_client -connect mail.example.net:ssmtp


Mail Message
-------------

.. code-block:: text

    EHLO torres.example.net
    AUTH PLAIN AGpvaG5AZXhhbXBsZS5uZXQAKioqKioqKio=
    > 235 2.7.0 Authentication successful
    MAIL FROM:<john@torres.example.net>
    > 250 2.1.0 Ok
    rcpt to:<john@example.net>
    > 250 2.1.5 Ok
    DATA
    > 354 End data with <CR><LF>.<CR><LF>
    Message-ID: <8b16a38d-20dd-25eb-fa2b-8603e8e9f68c@example.net>
    Date: Sun, 3 Jul 2022 20:58:50 +0200
    MIME-Version: 1.0
    Subject: Test Message
    To: John Doe <john@example.net>
    Content-Language: en-US
    From: John Doe <john@torres.example.net>
    Subject: Test Message

    Hi,

    This is a test message.

    Best,
    Widmore
    .
    > 250 2.0.0 Ok: queued as CDD461A811EA
    QUIT
    > DONE



Postfix Logs
------------

::

    $ journalctrl -t


postfix                   postfix/dnsblog           postfix/master            postfix/postmap           postfix/sendmail          postfix/tlsproxy
postfix/anvil             postfix/error             postfix/pickup            postfix/postscreen        postfix/smtp              postfix/trivial-rewrite
postfix/bounce            postfix/lmtp              postfix/postalias         postfix/qmgr              postfix/smtpd             postfix/verify
postfix/cleanup           postfix/local             postfix/postfix-script    postfix/scache            postfix/submission/smtpd  postfix/virtual

