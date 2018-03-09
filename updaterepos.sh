#!/bin/sh

set -x
set -e

# Original script by https://gitlab.com/paulcarroty/atom-rpm-deb-mirror/

echo -e "Download new RPM packages"
mkdir -p pkgs/rpms
curl -L 'https://github.com/bitwarden/desktop/releases/download/v1.0.5/Bitwarden-1.0.5-x86_64.rpm' -o pkgs/rpms/bitwarden.rpm

# generation of new RPM repository from downloaded packages
createrepo pkgs/rpms/

echo -e "Download new DEB packages"
mkdir pkgs/debs/
curl -L 'https://github.com/bitwarden/desktop/releases/download/v1.0.5/Bitwarden-1.0.5-amd64.deb' -o /tmp/bitwarden.deb


# generation of new Deb repository from downloaded packages
mkdir pkgs/debs/conf
touch pkgs/debs/conf/{option,distributions}
echo 'Codename: bitwarden' >> pkgs/debs/conf/distributions
echo 'Components: main' >> pkgs/debs/conf/distributions
echo 'Architectures: amd64' >> pkgs/debs/conf/distributions
reprepro -b pkgs/debs includedeb bitwarden /tmp/*.deb

echo "Sign the repositories"
# extract the public and private GPG keys from encrypted archive keys.tar with
# the secret openssl pass KEY, which is stored in TravisCI variables
openssl enc -aes-256-cbc -d -md sha256 -a -in signing.key.enc -out signing.key -k "$KEY"
#signing the repository metadata with my personal GPG key
gpg --import pub.gpg && gpg --passphrase "$KEY" --import signing.key
gpg --detach-sign --armor pkgs/rpms/repodata/repomd.xml
gpg --detach-sign --armor pkgs/debs/dists/bitwarden/main/binary-amd64/Release



# DOCS
# https://linux.die.net/man/8/createrepo
# http://manpages.ubuntu.com/manpages/trusty/man1/dpkg-scanpackages.1.html
# https://github.com/circleci/encrypted-files
