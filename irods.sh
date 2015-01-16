#!/bin/bash -x

readonly IRODS_DEB=irods-icat-4.0.3-64bit.deb
readonly PLUGIN_DEB=irods-database-plugin-postgres-1.3.deb
readonly BASE_URL=ftp://ftp.renci.org/pub/irods/releases/4.0.3

readonly IRODS_URL=$BASE_URL/$IRODS_DEB
readonly PLUGIN_URL=$BASE_URL/$PLUGIN_DEB

readonly IRODS_USER=irods

readonly ICAT_DB=icat
readonly ICAT_USER=irods
readonly ICAT_PASSWD=YMLh1qJKTDbS

readonly IRODS_ETC=/etc/irods
readonly IRODS_HOME=/var/lib/irods
readonly IRODS_INSTALL=$IRODS_HOME/iRODS
readonly IRODS_PKG=$IRODS_HOME/packaging
readonly IRODS_TMP=/tmp/$IRODS_USER

readonly IRODS_PROV=$IRODS_INSTALL/.irodsprovisioned
readonly IRODS_DB_SETUP=$IRODS_PKG/setup_irods_database.sh

set -v

if [ ! -e "$IRODS_PROV" ]; then
    apt-get update
    apt-get upgrade -y
    apt-get install -q -y postgresql odbc-postgresql unixodbc libssl0.9.8 super

    cd /var/cache/apt/archives
    [ -e "$IRODS_DEB"  ] || wget -q "$IRODS_URL"
    [ -e "$PLUGIN_DEB" ] || wget -q "$PLUGIN_URL"
    dpkg -i "$IRODS_DEB" "$PLUGIN_DEB"

    # set up the iRODS service account
    # use the default user and group (irods and irods)
    yes "" | "$IRODS_PKG/setup_irods_service_account.sh"

    su -c "mkdir '$IRODS_TMP'" - $IRODS_USER
    su -c "touch '$IRODS_TMP/setup_irods_database.flag'" - $IRODS_USER
    cp /vagrant/irods.config "$IRODS_ETC/irods.config"

    # Use system-wide postgresql for iRODS
    echo "CREATE ROLE vagrant 
            PASSWORD 'md5ce5f2d27bc6276a03b0328878c1dc0e2' 
            SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;" | su - postgres -c psql -

    cat <<EOT | su - postgres -c psql -
      CREATE USER $ICAT_USER WITH PASSWORD '$ICAT_PASSWD';
      CREATE DATABASE $ICAT_DB;
      GRANT ALL PRIVILEGES ON DATABASE $ICAT_DB TO $ICAT_USER;
EOT

    sed -i -e 's/ \( read [^-]\)/ [ $YES ] ||\1/' "$IRODS_DB_SETUP"
    su -c "echo '$ICAT_PASSWD' | YES=1 '$IRODS_DB_SETUP'" - $IRODS_USER

    su -c "touch '$IRODS_PROV'" - $IRODS_USER
fi
