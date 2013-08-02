#!/usr/bin/env bash

IRODS_DIR=iRODS
IRODS_TGZ=irods3.3.tgz
IRODS_URL=http://nopcode.org/get/$IRODS_TGZ
POSTGRES_DIR=/opt/postgresql

apt-get update
apt-get upgrade -y
apt-get install -q -y curl make g++

RELOAD=0

if [ ! -d /opt/$IRODS_DIR ]; then
    RELOAD=1
fi

if [ $RELOAD -eq 1 ]; then
    #Download the irods tarball if it doesn't already exist in the shared
    #directory. This can bypass some SLOOOOW downloads.
    if [ ! -f /vagrant/$IRODS_TGZ ]; then
        echo "Downloading the iRODS tarball from a Discovery Environment Data Link. This may take a while."
        curl -s -o $IRODS_TGZ $IRODS_URL
        echo "Done downloading the iRODS tarball."

        echo "Copying the tarball to the shared directory to prevent further downloads."
        cp $IRODS_TGZ /vagrant/
        echo "Done copying the tarball. DON'T CHECK IT IN!"
    else
        cp /vagrant/$IRODS_TGZ .
    fi


    #Clean up the local directory, if necessary.
    if [ -f $IRODS_DIR ]; then
        rm -rf $IRODS_DIR
    fi

    tar xzf $IRODS_TGZ
    mv $IRODS_DIR /opt/
    mkdir $POSTGRES_DIR
    rm $IRODS_TGZ

    cp /vagrant/irods.config /opt/$IRODS_DIR/config/
    cp /vagrant/installPostgres.config /opt/$IRODS_DIR/config/

    chown -R vagrant:vagrant /opt/$IRODS_DIR
    chmod -R a+rx /opt/$IRODS_DIR

    chown -R vagrant:vagrant $POSTGRES_DIR
    chmod -R a+rx $POSTGRES_DIR

    pushd /opt/$IRODS_DIR/
    su vagrant -c "export USE_LOCALHOST=1 && ./scripts/installPostgres --noask && ./scripts/configure && make && ./scripts/finishSetup --noask"
    popd
fi


cp /vagrant/irodsrc /home/vagrant/.irods/.irodsrc
chown vagrant:vagrant /home/vagrant/.irods/.irodsrc

if [ $RELOAD -eq 1 ]; then
    echo '. /home/vagrant/.irods/.irodsrc' >> /home/vagrant/.bashrc
fi
