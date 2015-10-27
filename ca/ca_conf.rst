OpenSSL Configuration
=====================

In the following sections we walk trough an example OpenSSL configuration for
use with a Certificate Authority.

The configuration files are to be saved in the directory from
where the CA operates.

You are expected to change the domain name from **example.com** and
**example.org** to your own domains.


Root Certification Authority
----------------------------

The complete file is available for :download:`download 
<config-files/root-ca.cnf>`.

.. literalinclude:: config-files/root-ca.cnf
    :language: ini
    :linenos:


Intermediate Certification Authority
------------------------------------

The complete file is available for :download:`download 
<config-files/intermediate-ca.cnf>`.

.. literalinclude:: config-files/intermediate-ca.cnf
    :language: ini
    :linenos:

