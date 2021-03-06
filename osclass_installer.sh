#!/bin/bash
# Script to deploy Osclass at Terminal.com

INSTALL_PATH="/var/www"

# Includes
wget https://raw.githubusercontent.com/terminalcloud/apps/master/terlib.sh
source terlib.sh || (echo "cannot get the includes"; exit -1)

install(){
	# Basics
	pkg_update
	system_cleanup
	basics_install

	# Procedure: 
	php5_install
	mysql_install
	mysql_setup osclass osclass terminal
	cd $INSTALL_PATH
	mkdir -p $INSTALL_PATH/osclass
	cd $INSTALL_PATH/osclass
	wget http://static.osclass.org/download/osclass.3.4.2.zip
	unzip osclass.3.4.2.zip && rm osclass.3.4.2.zip 
	chown -R www-data:www-data $INSTALL_PATH/osclass
	apache_install
	apache_default_vhost osclass.conf $INSTALL_PATH/osclass
	echo "date.timezone = America/Los_Angeles" >> /etc/php5/apache2/php.ini
	service apache2 restart 
}

show(){
	# Get the startup script
	wget -q -N https://raw.githubusercontent.com/terminalcloud/apps/master/others/osclass_hooks.sh
	mkdir -p /CL/hooks/
	mv osclass_hooks.sh /CL/hooks/startup.sh
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