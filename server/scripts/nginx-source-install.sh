#!/usr/bin/env bash
#
# Install Nginx from source
# Last update: Apr 14, 2021
#
# Set version numbers
export NGX_VERSION="1.19.10"      # Nginx - https://nginx.org/en/CHANGES (Apr 13 2021)
export OPENSSL_VERSION="1.1.1k"   # OpenSSL - https://github.com/openssl/openssl/releases (Mar 25, 2021)
export FANCYINDEX_VERSION="0.5.1" # Fancy Index Module - https://github.com/aperezdc/ngx-fancyindex/releases (Oct 26, 2020)
export NCP_VERSION="2.3"          # Nginx Cache Purge Module - https://github.com/FRiCKLE/ngx_cache_purge/releases (Dec 23, 2014)
export NHM_VERSION="0.33"         # Nginx Headers More Module - https://github.com/openresty/headers-more-nginx-module/releases (Nov 4, 2017)
export NGINX_DEBIAN_RULES="file:///home/wolf/Downloads/rules"
export SRC_DIR
SRC_DIR=$(mktemp -d --suffix=_ngx_src_${NGX_VERSION})
#SRC_DIR="/usr/local/src/nginx-$NGX_VERSION"

# Exit on errors
set -e

# Exit on undefined variables
set -u

# Update repositories
sudo apt-get --yes update

# Get all the stuff needed for building nginx and modules
sudo apt-get --yes install autoconf build-essential devscripts git \
        libgd-dev libgeoip-dev libpcre3 libpcre3-dev libxslt1-dev libxml2-dev \
        python-dev unzip zlib1g-dev
#sudo apt-get --yes install build-essential git software-properties-common apt-transport-https ufw
sudo apt-get --yes build-dep nginx

# Prepare source code directory
mkdir -p "$SRC_DIR"
#chown ${USER} ${SRC_DIR}
#chmod u+rwx ${SRC_DIR}

# Source Code for Nginx
cd "$SRC_DIR" || exit 1
apt-get --yes source nginx

# Source Code for OpenSSL
cd "$SRC_DIR"
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz.asc
gpg --verify openssl-${OPENSSL_VERSION}.tar.gz.asc
tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz
rm openssl-${OPENSSL_VERSION}.tar.gz

# Build OpenSSL (Optional)
cd "${SRC_DIR}/openssl-${OPENSSL_VERSION}/"
sudo mkdir -p /opt/openssl-${OPENSSL_VERSION}
./config --prefix=/opt/openssl-${OPENSSL_VERSION} no-shared
make clean
make depend
make
make test
sudo make install_sw
/opt/openssl-${OPENSSL_VERSION}/bin/openssl version
sudo ln --symbolic --force /opt/openssl-${OPENSSL_VERSION} /opt/openssl

# Source Code for Brotli
cd "$SRC_DIR"
sudo rm -rf brotli
git clone https://github.com/google/brotli.git
cd brotli
sudo python setup.py install

# Source Code for Brotli Nginx Module
cd "$SRC_DIR"
rm -rf ngx_brotli
git clone https://github.com/google/ngx_brotli.git
cd "${SRC_DIR}/ngx_brotli"
git submodule update --init

# Source Code for Nginx Cache Purge Module
cd "$SRC_DIR"
rm -rf ngx_cache_purge-${NCP_VERSION}
wget -O ngx_cache_purge-${NCP_VERSION}.zip \
    https://github.com/FRiCKLE/ngx_cache_purge/archive/${NCP_VERSION}.zip
unzip ngx_cache_purge-${NCP_VERSION}.zip

# Source Code for Nginx Headers More Module
cd "$SRC_DIR"
wget -O ngx_headers_more-${NHM_VERSION}.tar.gz \
    https://github.com/openresty/headers-more-nginx-module/archive/v${NHM_VERSION}.tar.gz
tar -xzf ngx_headers_more-${NHM_VERSION}.tar.gz

# Source Code for the Fancy Index Module
cd "$SRC_DIR"
wget -O ngx-fancyindex-${FANCYINDEX_VERSION}.tar.gz \
    https://github.com/aperezdc/ngx-fancyindex/archive/v${FANCYINDEX_VERSION}.tar.gz
tar -xzf ngx-fancyindex-${FANCYINDEX_VERSION}.tar.gz

# Debian Package configuration from roll.urown.net
curl --output /tmp/nginx_debian_rules "${NGINX_DEBIAN_RULES}"
cp --backup /tmp/nginx_debian_rules "${SRC_DIR}/nginx-${NGX_VERSION}/debian/rules"
chmod +x "${SRC_DIR}/nginx-${NGX_VERSION}/debian/rules"

# Package version information
cd "${SRC_DIR}/nginx-${NGX_VERSION}"
debchange "Build against OpenSSL ${OPENSSL_VERSION}"
debchange 'Added XSLT module'
debchange 'Added 3rd-party brotli compression module'
debchange "Added 3rd-party cache purge module ${NCP_VERSION}"
debchange "Added 3rd-party fancy index module ${FANCYINDEX_VERSION}"
debchange "Added 3rd-party headers-more module ${NHM_VERSION}"
debchange 'Removed mail module'
debchange 'Removed stream module'

cd "${SRC_DIR}/nginx-${NGX_VERSION}"

# Clean the source
dpkg-buildpackage --root-command=fakeroot --rules-target=clean

# Build the package
dpkg-buildpackage --root-command=fakeroot --build=binary

# Ready to install
cd "$SRC_DIR"
ls -lth "${SRC_DIR}/nginx_${NGX_VERSION}-1~$( lsb_release -sc )ubuntu1_amd64.deb" \
    "${SRC_DIR}/nginx-dbg_${NGX_VERSION}-1~$( lsb_release -sc )ubuntu1_amd64.deb"

echo "Done and ready to install, please run:"
echo "  ********************************************************************************* "
sudo dpkg --install "${SRC_DIR}/nginx_${NGX_VERSION}-1~$( lsb_release -sc )ubuntu1_amd64.deb"
sudo dpkg --install "${SRC_DIR}/nginx-dbg_${NGX_VERSION}-1~$( lsb_release -sc )ubuntu1_amd64.deb"
sudo apt-mark hold nginx nginx-dbg
echo "  sudo rm -rf ${SRC_DIR}                                                            "
echo "  ********************************************************************************* "
