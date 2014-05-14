#!/bin/bash -x

IRODS_DEB=irods-icat-4.0.0-64bit.deb
IRODS_URL=ftp://ftp.renci.org/pub/irods/releases/4.0.0/$IRODS_DEB
PLUGIN_DEB=irods-database-plugin-postgres-1.0.deb
PLUGIN_URL=ftp://ftp.renci.org/pub/irods/releases/4.0.0/$PLUGIN_DEB
IRODS_HOME=/var/lib/irods/iRODS
IRODS_ETC=/etc/irods

set -v

if [ ! -e $IRODS_HOME/.irodsprovisioned ]; then
    apt-get update
    apt-get upgrade -y
    apt-get install -q -y postgresql odbc-postgresql unixodbc libssl0.9.8 super

    cd /var/cache/apt/archives
    [ -e $IRODS_DEB  ] || wget -q $IRODS_URL
    [ -e $PLUGIN_DEB ] || wget -q $PLUGIN_URL
    dpkg -i $IRODS_DEB $PLUGIN_DEB

    su -c 'mkdir /tmp/irods' - irods
    su -c 'touch /tmp/irods/setup_database.flag' - irods
    cp /vagrant/irods.config /etc/irods/irods.config

    # Use system-wide postgresql for iRODS
    echo "CREATE ROLE vagrant PASSWORD 'md5ce5f2d27bc6276a03b0328878c1dc0e2' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;" | su - postgres -c psql -
    cat <<EOT | su - postgres -c psql -
CREATE DATABASE icat;
CREATE ROLE irods LOGIN PASSWORD 'YMLh1qJKTDbS';
GRANT CREATE ON DATABASE icat TO irods;
EOT

    # psql createuser does not allow password via cmdline
    #su postgres -c "createuser vagrant -s -w"

    service postgresql restart
    sleep 5

    sed -i -e 's/ \( read [^-]\)/ [ $YES ] ||\1/' ~irods/packaging/setup_database.sh

    su -c "echo 'YMLh1qJKTDbS' | YES=1 ./packaging/setup_database.sh" - irods

    echo "export PATH=\$PATH:$IRODS_HOME:$IRODS_HOME/clients/icommands/bin" >> $IRODS_HOME/../.bashrc
    chown irods:irods $IRODS_HOME/../.bashrc

    su -c "touch $IRODS_HOME/.irodsprovisioned" - irods
fi
