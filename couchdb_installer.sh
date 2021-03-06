#!/bin/bash
# Script to deploy CouchDB at Terminal.com

INSTALL_PATH="/var/www"

# Includes
wget https://raw.githubusercontent.com/terminalcloud/apps/master/terlib.sh
source terlib.sh || (echo "cannot get the includes"; exit -1)

install(){
  # Basics
  system_cleanup
  basics_install

  # Procedure:
  add-apt-repository ppa:couchdb/stable -y
  apt-get update
  apt-get -y install couchdb
  sed -i 's/127\.0\.0\.1/0\.0\.0\.0/g' /etc/couchdb/default.ini
}

show(){
  # Get the startup script
  wget -q -N https://raw.githubusercontent.com/terminalcloud/apps/master/others/couchdb_hooks.sh
  mkdir -p /CL/hooks/
  mv couchdb_hooks.sh /CL/hooks/startup.sh
  # Execute startup script by first to get the common files
  chmod 777 /CL/hooks/startup.sh && /CL/hooks/startup.sh
}

if [[ -z $1 ]]; then
  install && show
elif [[ $1 == "show" ]]; then
  show
else
  echo "unknown parameter specified"
fi
