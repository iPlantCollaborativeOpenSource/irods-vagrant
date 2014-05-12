#!/bin/bash -x

IRODS_DIR=/var/lib/iRODS
IRODS_TGZ=3.3.tar.gz
IRODS_URL=https://github.com/irods/irods-legacy/archive/$IRODS_TGZ


if [ ! -e /home/vagrant/.irodsprovisioned ]; then
    apt-get update
    apt-get upgrade -y
    apt-get install -q -y curl build-essential python-pip git python-dev postgresql odbc-postgresql unixodbc-dev language-pack-en

    cd /var/lib

    wget -q $IRODS_URL
    tar xzf $IRODS_TGZ

    # Fix directories from tar.gz from GitHub
    mv irods-*/iRODS .
    rm -rf irods-*

    cp /vagrant/irods.config $IRODS_DIR/config/

    chown -R vagrant:vagrant $IRODS_DIR
    chmod -R a+rx $IRODS_DIR

    # Use system-wide postgresql for iRODS
    echo "CREATE ROLE vagrant PASSWORD 'md5ce5f2d27bc6276a03b0328878c1dc0e2' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;" | su - postgres -c psql -
    # psql createuser does not allow password via cmdline
    #su postgres -c "createuser vagrant -s -w"

    cp /vagrant/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf
    ln -sf /usr/lib/x86_64-linux-gnu/odbc/psqlodbca.so /usr/lib/postgresql/9.3/lib/libodbcpsql.so
    service postgresql restart
    sleep 5

    su vagrant -c "cd $IRODS_DIR && export USE_LOCALHOST=1 && ./scripts/configure && make && ./scripts/finishSetup --noask"
    RESULT=$?

    su vagrant -c "mkdir -p /home/vagrant/.irods"

    echo "export PATH=\$PATH:$IRODS_DIR:$IRODS_DIR/clients/icommands/bin" >> /home/vagrant/.bashrc
    if [ "$RESULT" != "0" ]; then
        su vagrant -c "cd $IRODS_DIR && (yes | ./irodssetup)"
    fi

    touch /home/vagrant/.irodsprovisioned
fi
