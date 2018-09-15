Mail Filters
============

Global Scripts
---------------

Spam Filter
^^^^^^^^^^^

::

    #
    # Move spam mails into to the designated junk folder
    # Flag message as Spam
    # The folder is create if it doesn't exist already.
    #
    require [ "fileinto", "imap4flags" ];
    if header :contains "X-Spam-Flag" "YES" {
        fileinto :create :flags "\\Junk", "\\Seen" "Spam";
        stop;
    }


Mailing Lists
^^^^^^^^^^^^^

::

    #
    # Move Mailing-List Messages in to its own folder.
    # The folder is create if it doesn't exist already.
    #
    require [ "variables", "fileinto", "mailbox" ];
    if anyof (  header "Precedence" "list",
                header "Precedence" "bulk",
                exists "List-Id" )
    {
        # Mailman lists
        if header :matches "X-BeenThere" "*<*@*"
        {
            fileinto :create "Lists.${2}";
            stop;
        }
        # Other lists
        elseif header :matches "List-ID" "*<*@*"
        {
            fileinto :create "Lists.${2}";
            stop;
        }
        # Unknown
        else
        {
            fileinto :create "Lists";
        }
    }


Sieve References
----------------

 * `Dovecot - Pigeonhole Sieve Interpreter <https://wiki2.dovecot.org/Pigeonhole/Sieve/>`_
 * `FastMail - How to use Sieve <https://www.fastmail.com/help/technical/sieve-howto.html>`_
 * `Wikipedia on Sieve <https://en.wikipedia.org/wiki/Sieve_(mail_filtering_language)>`_


Testing Your Sieve Scripts
--------------------------

 * `FastMail Sieve Tester <https://www.fastmail.com/cgi-bin/sievetest.pl>`_
