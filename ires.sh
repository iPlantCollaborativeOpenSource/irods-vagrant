#!/bin/bash -x

IRODS_DEB=irods-resource-4.0.0-64bit.deb
IRODS_URL=ftp://ftp.renci.org/pub/irods/releases/4.0.0/$IRODS_DEB
IRODS_HOME=/var/lib/irods/iRODS
IRODS_ETC=/etc/irods

set -v

if [ ! -e $IRODS_HOME/.irodsprovisioned ]; then
    apt-get update
    apt-get upgrade -y
    apt-get install -q -y libssl0.9.8

    cd /var/cache/apt/archives
    [ -e $IRODS_DEB  ] || wget -q $IRODS_URL
    dpkg -i $IRODS_DEB

    # Instructs the setup script to pull default values
    # from irods.config
    su -c 'touch /tmp/setup_resource.flag' - irods
    cp /vagrant/ires.config  /etc/irods/irods.config

    sed -i -e 's/ \( read [^-]\)/ [ $YES ] ||\1/' ~irods/packaging/setup_resource.sh
    ICAT_ADMIN_PASSWORD=$(grep 'IRODS_ADMIN_PASSWORD =' /vagrant/icat.config | awk -F\' '{print $2}')
    su -c "YES=1 ./packaging/setup_resource.sh '$ICAT_ADMIN_PASSWORD'" - irods

    echo "export PATH=\$PATH:$IRODS_HOME:$IRODS_HOME/clients/icommands/bin" >> $IRODS_HOME/../.bashrc
    chown irods:irods $IRODS_HOME/../.bashrc

    su -c "touch $IRODS_HOME/.irodsprovisioned" - irods
fi
