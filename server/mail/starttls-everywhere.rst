StartTLS Everywhere
===================

.. image:: starttls-logo-wide.*
    :alt: StartTLS Everywhere Logo
    :width: 200px
    :align: right

About
-----

`STARTTLS Everywhere <https://starttls-everywhere.org/>`_ is a project to make
email delivery more secure. It is created and maintained by the 
`Electronic Frontier Foundation (EFF) <https://www.eff.org/>`_.

We want safer hops for email. Email goes through multiple computers (or
multiple “hops”) to get to its destination, and each hop should be as secure
as possible. More specific goals of the project include:

 * Improve :term:`STARTTLS` adoption.
 * Maintain a 
   `STARTTLS Policy List <https://starttls-everywhere.org/policy-list>`_ 
   to help prevent 
   `downgrade attacks <https://starttls-everywhere.org/faq#downgrades>`_ 
   on email services.
 * Lower the barriers to entry for running a secure mailserver.

If you have questions about STARTTLS Everywhere, check out the 
`FAQ <https://starttls-everywhere.org/policy-list>`_. If you are
an email service provider and are looking to be added to the STARTTLS
Everywhere policy list, 
`learn more here <https://starttls-everywhere.org/policy-list>`_.

If you like the project, consider 
`donating <https://supporters.eff.org/donate/>`_!


Alternative to DANE
^^^^^^^^^^^^^^^^^^^

Our DNS and mail servers already use :term:`DNSSEC` and :term:`DANE`, which is
a more scalable solution.

However, operators have been very slow to roll out DNSSEC supprt. 

We feel there is value in deploying an intermediate solution that does not
rely on DNSSEC. This will improve the email security situation more quickly.
It will also provide operational experience with authenticated SMTP over TLS
that will make eventual rollout of DANE-based solutions easier.


Adding your Domain
------------------

If you followed this guide, your mail server should already be valid member
for the StartTLS Everywhere Policy List.

 1. Point you browser to https://www.starttls-everywhere.org/add-domain/
 2. Fill in you domain, MX servers host names and you postmaster mail address.
 3. You will receive an email with a verification URL. Click on that and you
    should be done.






