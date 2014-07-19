#!/bin/bash

# iputing a large file initiates multiple connections,
# but the resource server is responsible for sending the address
# that the client should initiate the connection to
# Having the hostname bound to loopback seems to confuse it
# and it sends a loopback address
sed -i '/127.0.1.1/d' /etc/hosts

cat >> /etc/hosts << EOF
192.168.50.10 icat
192.168.50.11 ires1
192.168.50.12 ires2
EOF
