#!/bin/sh
# Create Diffie-Hellmann key exchange parameters
#
mkdir -p /etc/ssl/dhparams
cd /etc/ssl/dhparams
umask 022
for dhsize in 512 1024 2048 3072 4096 ;
do
    nice openssl dhparam -out ${dhsize}.tmp ${dhsize} && \
        mv ${dhsize}.tmp dh_${dhsize}.pem && \
            chmod 644 dh_${dhsize}.pem
done
