#!/bin/bash -x

IRODS_DIR=/var/lib/iRODS
IRODS_TGZ=irods3.3.tgz
IRODS_URL=http://nopcode.org/get/$IRODS_TGZ


if [ ! -e /home/vagrant/.irodsprovisioned ]; then
    apt-get update
    apt-get upgrade -y
    apt-get install -q -y curl build-essential python-pip git python-dev postgresql odbc-postgresql unixodbc-dev

    cd /var/lib
    curl -s -o $IRODS_TGZ $IRODS_URL

    tar xzf $IRODS_TGZ

    cp /vagrant/irods.config $IRODS_DIR/config/

    chown -R vagrant:vagrant $IRODS_DIR
    chmod -R a+rx $IRODS_DIR

    # Use system-wide postgresql for iRODS
    echo "CREATE ROLE vagrant PASSWORD 'md5ce5f2d27bc6276a03b0328878c1dc0e2' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;" | su - postgres -c psql -
    # psql createuser does not allow password via cmdline
    #su postgres -c "createuser vagrant -s -w"

    cp /vagrant/pg_hba.conf /etc/postgresql/9.1/main/pg_hba.conf
    ln -sf /usr/lib/x86_64-linux-gnu/odbc/psqlodbca.so /usr/lib/postgresql/9.1/lib/libodbcpsql.so
    service postgresql restart

    su vagrant -c "cd $IRODS_DIR && export USE_LOCALHOST=1 && ./scripts/configure && make && ./scripts/finishSetup --noask"

    su vagrant -c "mkdir -p /home/vagrant/.irods"

    echo "export PATH=\$PATH:$IRODS_DIR:$IRODS_DIR/clients/icommands/bin" >> /home/vagrant/.bashrc

    touch /home/vagrant/.irodsprovisioned
fi
