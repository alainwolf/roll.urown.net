XCA - X Certificate and key management
======================================

.. image:: XCA-logo.*
    :alt: XCA Logo
    :align: right

`XCA application <http://xca.sourceforge.net/xca.html>`_ is intended for creating and
managing X.509 certificates, certificate requests, RSA, DSA and EC private keys,
Smartcards and CRLs. 

Everything that is needed for a CA is implemented. All CAs can sign sub-CAs
recursively. These certificate chains are shown clearly. 

For an easy company-wide use there are customiseable templates that can be used
for certificate or request generation.

All crypto data is stored in an endian-agnostic file format portable across
operating systems.

Even if you don't create and manage your onw CA, this software comes very handy
to backup all your personal, client and server keys and certificates.


Installation
------------

XCA can be installed from the Ubuntu Software-Center:

.. raw:: html

    <p>
        <a class="reference external" href="apt:xca">
        <img alt="software-center" src="../_images/scbutton-free-200px.png" />
        </a>
    </p>


Configuration
-------------

Options reference: `<http://xca.sourceforge.net/xca-12.html>`_.

Open the **File** menu and select **Options**.

We set options to match what we have set for :doc:`/server/server-tls` on the server in
our OpenSSL configuration:

 * Remove all the listed mandatory subject entries, except the **commonName**.
 * Set the standard hash alorithm to **SHA 256**.
 * Set the allowed string type to **PKIX UTF8**


Create Templates
----------------

Templates allow fast and easy creation of new certificates according to ones 
needs.


Server Template
^^^^^^^^^^^^^^^

Select the **Templates** tab.

Click the **New Template** button on the top right.

