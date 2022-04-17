Git Server
==========

To store our various configuration files, we set up a private `git version
control server <https://git-scm.com/docs/git-daemon>`_.

Installation
------------

If not already installed, install the software package::

    $ sudo apt install git


`Add a user <http://manpages.ubuntu.com/manpages/focal/en/man8/adduser.8.html>`_
for the git server to run as::

    $ sudo mkdir -p /var/lib/git/.ssh
    $ sudo adduser --system --group --home /var/lib/git git


Git uses SSH to authorize users. So let's give it our SSH public key::

    $ cat ~/.ssh/authorized_keys \
        | sudo tee -a /var/lib/git/.ssh/authorized_keys
    $ sudo chown -R git:git /var/lib/git
    $ sudo chmod 0600 /var/lib/git/.ssh/authorized_keys


You may repeat this step for any other users public keys, who need access.




