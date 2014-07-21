:orphan:

Glossary
========

.. glossary::
    :sorted:

    3DES 
        `Triple DES (3DES) <https://en.wikipedia.org/wiki/3DES>`_ is the common
        name for the Triple Data Encryption Algorithm (TDEA or Triple DEA)
        symmetric-key block cipher, which applies the Data Encryption Standard
        (DES) cipher algorithm three times to each data block. While in theory
        it has 168 bits of security, the practical security it provides is only
        112 bits. To make things worse, there are known attacks against it, so
        that effectively it compares to about 80 bits security. 
        **Do not use!**

    AES
    Advanced Encryption Standard
        `The Advanced Encryption Standard (AES)
        <https://en.wikipedia.org/wiki/Advanced_Encryption_Standard>`_ is a is a
        symmetric-key algorithm for the encryption of electronic data
        established by a U.S. Governement institution (NIST) in 2001. AES has
        been adopted by the U.S. government for top secret information and is
        used worldwide today. It supersedes the :term:`Data Encryption Standard`
        (DES).

    AES-NI
    Advanced Encryption Standard Instruction Set
        `Advanced Encryption Standard Instruction Set (or AES-NI)
        <https://en.wikipedia.org/wiki/AES_instruction_set>`_ is an extension of
        the x86 CPU architecture from Intel and AMD. It accelarates data
        encryption and decryption if the :term:`Advanced Encryption Standard`
        (AES) is used by an application.

    Bayesian Filter
    Bayesian Filtering
    Bayesian Spam Filter
        A `Bayesian spam filter
        <https://en.wikipedia.org/wiki/Bayesian_spam_filtering>`_ (after Rev.
        Thomas Bayes) is a statistical technique of e-mail filtering. In its
        basic form, it makes use of a naive Bayes classifier on bag of words
        features to identify spam e-mail, an approach commonly used in text
        classification.

    Cipher Suite 
        A cipher suite is a standardized collection of key exchange algorithms,
        encryption algorithms (ciphers) and Message authentication codes
        (:term:`MAC`) algorithm that provides authenticated encryption schemes.
        For more information see [KAea14b]_.

    Daemon
        Long-running programms usually running in the background and providing
        services for other programs and or clients on other systems connected by
        a network. Daemons typically are started automatically on system boot 
        and run on their own, without any user interaction.

    Composer
        `Composer <https://getcomposer.org/>`_ is a tool for dependency 
        management in PHP. It allows a developer to declare the dependent 
        libraries a project needs and it will install them along the project.

    DES
    Data Encryption Standard
        The Data Encryption Standard (DES) is a previously predominant
        symmetric-key algorithm for the encryption of electronic data. It is now
        considered to be insecure. This is chiefly due to the 56-bit key size
        being too small; in January, 1999, distributed.net and the Electronic
        Frontier Foundation collaborated to publicly break a DES key in 22 hours
        and 15 minutes. The cipher has been superseded by the :term:`Advanced
        Encryption Standard` (AES) and has been withdrawn as a standard. DES was 
        developed in the early 1970s at IBM.
        **Do not use!**

    DH
    Diffie-Hellman key exchange
        `Diffie–Hellman key exchange (DH) 
        <https://en.wikipedia.org/wiki/Diffie-Hellman_key_exchange>`_ 
        is a specific method of exchanging cryptographic keys. The method allows 
        two parties that have no prior knowledge of each other to jointly 
        establish a shared secret key over an insecure communications channel. 
        This key can then be used to encrypt subsequent communications using a 
        symmetric key cipher. Youtube has a `great video 
        <https://www.youtube.com/watch?v=3QnD2c4Xovk>`_ that explains it in 5 
        minutes.

    DH Parameters
        DH parameters are pre-generated large prime-numbers, which accelerates
        the  generatation of session keys while using :term:`Diffie-Hellman key
        exchange`. To find and evaluate such prime numbers takes a long time
        (up to several minutes). Using pre-generated values allows to establish
        session keys during initial handshake and periodic renevals, without any
        noticeable delay.

    Digital Fingerprint
        See :term:`Cryptographic Hash Function`.

    ECDH
    Elliptic curve Diffie–Hellman
        Elliptic curve Diffie–Hellman (ECDH) 
        <https://en.wikipedia.org/wiki/Elliptic_curve_Diffie-Hellman>`_ is an 
        anonymous key agreement protocol that allows two parties, each having an 
        elliptic curve public–private key pair, to establish a shared secret 
        over an insecure channel. This shared secret may be directly  used as a 
        key, or better yet, to derive another key which can then be used to 
        encrypt subsequent communications using a symmetric key cipher. It is a 
        variant of the :term:`Diffie-Hellman key exchange` using :term:`elliptic 
        curve cryptography`.

    Elliptic Curve Cryptography
        TBD

    ESMTP
        `Extended SMTP (ESTMP) <https://en.wikipedia.org/wiki/Extended_SMTP>`_
        includes additions made to :term:`SMTP` who where defined in 2008 in
        :rfc:`5321`. It is in widespread use today. Like SMTP, ESMTP uses TCP 
        port 25 and TCP port 465 for :term:`SSL` secured connections.

    FS
    Forward Secrecy
    Perfect Forward Secrecy
        In cryptography, forward secrecy is a property of key-agreement
        protocols ensuring that a session key derived from a set of long-term
        keys cannot be compromised if one of the long-term keys (like the
        servers private key) is compromised in the future. Ususally either 
        :term:`Diffie-Hellman key exchange` or :term:`Elliptic curve 
        Diffie–Hellman` are used to create and exchange session keys.

    Hash Function
        TBD

    HMAC
        TBD

    IMAP
        `Internet Message Access Protocol (IMAP)
        <https://en.wikipedia.org/wiki/Imap>`_ is a protocol for email
        retrieval and storage by the :term:`MUA` from the :term:`MAS`. It was
        devloped as an alternative to :term:`POP`. IMAP unlike :term:`POP`, 
        specifically allows multiple clients simultaneously connected to the 
        same mailbox, and through flags stored on the server, different clients
        accessing the same mailbox at the same or different times can detect 
        state changes made by other clients. The IMAP protocol uses TCP port 143
        and TCP port 993 for :term:`SSL` secured IMAPS connections.

    Jabber
        See :term:`XMPP`.

    LMTP 
        The `Local Mail Transfer Protocol (LMTP) 
        <https://en.wikipedia.org/wiki/LMTP>`_ is a derivative of ESMTP, the
        extension of the Simple Mail Transfer Protocol. It is defined in 
        :RFC:`2033`.

    MAC
        TBD

    MD5
        TBD

    MDA
    Mail Delivery Agent
        Another name for :term:`LDA` or :term:`Local Delivery Agent`.

    LDA
    Local Delivery Agent
        The software program in charge of delivering mail messages to its final
        destination on the local system, usually a users mailbox, after they
        receive a message from the :term:`MTA`.

    MSA
    Message Submission Agent
        The software program in charge of receiving mail messages from the
        :term:`MUA` using the :term:`Submission` protocol. The MSA runs as a 
        :term:`daemon`.

    MUA
    Message User Agent
        The software program in charge of retrieving messages from a users
        mailbox on a :term:`MAS` or :term:`Mail Access Server`, usually using
        either :term:`IMAP` or :term:`POP3` protocols. The MUA might also submit
        mail messages to the :term:`MSA` or :term:`Message Submission Agent`
        using the :term:`Submission` protocol. MUAs are commonly known as mail
        clients. Known MUA software product examples are Microsoft Outlook or
        Mozilla Thunderbird.

    MTA
    Mail Transfer Agent
        TBD

    SMTP
        The `Simple Mail Transfer Protocol (SMTP)
        <https://en.wikipedia.org/wiki/SMTP>`_ is the protool used by a
        :term:`MTA` to transmit mails between Internet domains. First defined 
        by :rfc:`821` in 1982, it was last updated in 2008 as :term:`ESMTP`. 
        SMTP by default uses TCP port 25. SMTP connections secured by SSL, known 
        as :term:`SMTPS`, default to TCP port 465.

    SMTPS
        SSL secured SMTP connections on TCP port 465.

    Submission
        TBD

    MAS
    Mail Access Server
        TBD

    RFC
        A `Request for Comments (RFC) 
        <https://en.wikipedia.org/wiki/Request_for_Comments>`_ is a publication 
        of the Internet Engineering Task Force (IETF) and the Internet Society, 
        the principal technical development and standards-setting bodies for the
        Internet.

    POP
    POP3
        The `Post Office Protocol (POP) <https://en.wikipedia.org/wiki/POP3>`_
        is an Internet protocol used by mail clients to retrieve mail from
        remote servers over a TCP/IP connection. POP has been developed through
        several versions, with version 3 (**POP3**) being the current standard.

    SSL
        See :term:`TLS`

    TLS
        Transport Layer Security TLS) and its predecessor, Secure Sockets Layer
        (SSL), are cryptographic protocols designed to  provide communication
        security over the Internet. They use :term:`X.509` certificates and
        hence asymmetric cryptography to authenticate the counterparty with whom
        they are communicating, and to exchange a symmetric key. This session
        key is then used to encrypt data flowing between the parties. This
        allows for data/message confidentiality, and message authentication
        codes for message integrity and as a by-product, message authentication.

    X.509
        In cryptography, X.509 is an ITU-T standard for a public key
        infrastructure (PKI) and Privilege Management Infrastructure (PMI).
        X.509 specifies, amongst other things, standard formats for public key
        certificates, certificate revocation lists, attribute certificates, and
        a certification path validation algorithm.

    Sieve
        `Sieve <https://en.wikipedia.org/wiki/Sieve_%28mail_filtering_language%29>`_
        is a programming language that can be used to create filters for email.
        Sieve's base specification is outlined in :rfc:`5228`.

    XMPP
        `Extensible Messaging and Presence Protocol (XMPP)
        <https://en.wikipedia.org/wiki/Xmpp>`_  is a communications protocol for
        message-oriented middleware based on XML (Extensible Markup Language). 
        The protocol was originally named Jabber and was developed by the Jabber
        open-source community in 1999 for near real-time, instant messaging (IM),
        presence information, and contact list maintenance.

    TL;DR
        "Too Long; Didn't Read".

    RSA
        `RSA <https://en.wikipedia.org/wiki/RSA_%28cryptosystem%29>`_ is one of 
        the first practicable public-key cryptosystems and is widely used for 
        secure data transmission. In such a cryptosystem, the encryption key is 
        public and differs from the decryption key which is kept secret. RSA 
        stands for Ron Rivest, Adi Shamir and Leonard Adleman, who first 
        publicly described the algorithm in 1977. Youtube has `this video 
        <https://www.youtube.com/watch?v=wXB-V_Keiu8>`_ that explains it in 16 
        minutes.

    RC4
        `RC4 <https://en.wikipedia.org/wiki/RC4>`_ is the most widely used
        software stream cipher and  is used in popular protocols such as
        Transport Layer Security (TLS) and  WEP (to secure wireless networks).
        While remarkable for its simplicity and speed in software, RC4 has
        weaknesses that argue against its use in new systems. As of 2013, there
        is speculation that some state cryptologic agencies may possess the
        capability to break RC4 even when used in the TLS protocol. 
        **RC4 should disabled and avoided wherever possible!**

    SHA
    SHA1
    SHA-1
        `SHA-1 <https://en.wikipedia.org/wiki/SHA1>`_ is a :term:`cryptographic 
        hash function` designed by the NSA and is a U.S. Governement Standard
        published by the United States NIST in 1995. SHA stands for "secure hash
        algorithm". In 2005, analysts found attacks on SHA-1 suggesting
        that the algorithm might not be secure enough for ongoing use. The U.S,
        the German and other governements are required to move to SHA-2 after
        2010 because of the weakness. Windows will stop accepting SHA-1
        certificates by 2017. Hoever a large part of todays commercial
        certificate authorities still only issue SHA-1 signed certificates.
        **Avoid where possible!**

    SHA2
    SHA-2
    SHA-224
    SHA-256
    SHA-384
    SHA-512
    SHA-512/224
    SHA-512/256
        `SHA-2 <https://en.wikipedia.org/wiki/SHA2>`_ is :term:`cryptographic 
        hash function`, published in 2001 by the US governement (NSA & NIST), is
        significantly different from :term:`SHA-1`. SHA-2 currently consists of 
        a set of six hash functions with digests that are 224, 256, 384 or 512 
        bits.
    
    Cryptographic Hash Function
        A `cryptographic hash function
        <https://en.wikipedia.org/wiki/Cryptographic_hash_function>`_ is a hash
        function which is considered practically impossible to invert, that is,
        to recreate the input data from its hash value alone. They are used for
        digital signatures, message authentication codes (:term:`MAC`), and
        other forms of authentication. It can also be used as ordinary
        :term:`hash function`, to index data in hash tables, for
        fingerprinting, to detect duplicate data or uniquely identify files, and
        as checksums to detect accidental data corruption. Cryptographic hash
        values are sometimes called (digital) fingerprints, checksums, or just
        hash values. Some widely used ones are: :term:`MD5`, :term:`SHA-1`,
        :term:`SHA-256`
    
    XML
        TBD

    PEM
        `Privacy Enhanced Mail (PEM)
        <https://en.wikipedia.org/wiki/Privacy_Enhanced_Mail>`_ is a 1993 
        :term:`IETF` proposal for securing email using public-key cryptography. Although PEM became an IETF proposed standard it was never widely 
        deployed or used.

    PEM Encoded
    PEM File Format
        Base64 encoded binary data, often used to store :term:`X.509`
        certificates and keys usually enclosed between  "-----BEGIN
        CERTIFICATE-----" and "-----END CERTIFICATE-----" strings.

    Salt 
        In cryptography, a `salt
        <https://en.wikipedia.org/wiki/Salt_%28cryptography%29>`_ is random data
        that is used as an additional input to a :term:`cryptographic hash
        function` on a password or passphrase. The primary function of salts is
        to defend against dictionary attacks versus a list of password hashes
        and against pre- computed :term:`rainbow table` attacks. A new salt is
        randomly generated for each password. In a typical setting, the salt and
        the password are concatenated and processed with a :term:`cryptographic
        hash function`, and the resulting output (but not the original password)
        is stored with the salt in a database. Hashing allows for later
        authentication while defending against compromise of the plaintext
        password in the event that the database is somehow compromised.
        Cryptographic salts are broadly used in many modern computer systems,
        from Unix system credentials to Internet security.

    Rainbow Table
        TBD

    IETF
    Internet Engineering Task Force
        TBD

    NSA
    National Security Agency
        TBD

    NIST
    National Institute of Standards and Technology
        TBD
