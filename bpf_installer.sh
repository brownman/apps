#!/bin/bash
# Script to deploy Bottle Python Framework at Terminal.com

INSTALL_PATH="/var/www/html"

# Includes
wget https://raw.githubusercontent.com/terminalcloud/apps/master/terlib.sh
source terlib.sh || (echo "cannot get the includes"; exit -1)


install(){
	# Basics
	pkg_update
	system_cleanup
	basics_install

	# Procedure: 
	mysql_install
	python_install
	mysql_setup tododb terminal terminal
	apt-get -y install libapache2-mod-wsgi libmysqlclient-dev python-dev || yum -y install httpd-mod-wsgi libmysqlclient-dev python-dev
	apache_install
	# Vhost config
	[[ -f /etc/debian_version ]] && vpath="/etc/apache2/sites-available/" || vpath="/etc/httpd/config.d/"
	cat > $vpath/todo.conf << EOF
<VirtualHost *:80>
        WSGIScriptAlias / /var/www/html/todo.py
</VirtualHost>
EOF
	if [[ -f /etc/debian_version ]]; then
		[[ -f /etc/apache2/sites-enabled/000-default.conf ]] && rm /etc/apache2/sites-enabled/000-default.conf
		ln -s /etc/apache2/sites-available/todo.conf /etc/apache2/sites-enabled/todo.conf 
		service apache2 restart 
	else
		[[ -f /etc/httpd/conf.d/000-default.conf ]] && rm /etc/httpd/conf.d/000-default.conf
		service httpd restart
	fi

	# Apache conf
	[[ -f /etc/debian_version ]] && echo "WSGIPythonPath /var/www/html/" >> /etc/apache2/apache2.conf || echo "WSGIPythonPath /var/www/html/" >> /etc/httpd/httpd.conf
	mysql -uroot -proot -e"CREATE TABLE todo (id INTEGER PRIMARY KEY AUTO_INCREMENT, task char(100) NOT NULL, status bool NOT NULL);"
	mysql -uroot -proot -e"INSERT INTO todo (task,status) VALUES ('This is a TEST todo Description at Terminal.com',1);"
	mysql -uroot -proot -e"INSERT INTO todo (task,status) VALUES ('This is another TEST todo Description at Terminal.com',1);"
	cd $INSTALL_PATH
	pip install bottle
	pip install SQLAlchemy
	pip install mysql-python
	ln -s /etc/apache2/mods-available/wsgi.conf /etc/apache2/mods-enabled/wsgi.conf
	ln -s /etc/apache2/mods-available/wsgi.load /etc/apache2/mods-enabled/wsgi.load
	cd /var/www
	wget https://github.com/mcapielo/Todo-List-Bottle-SQLAlchemy-Bootstrap/archive/master.zip
	unzip master.zip
	mv Todo-List-Bottle-SQLAlchemy-Bootstrap-master/* html
	chown -R www-data:www-data $INSTALL_PATH/
}


show(){
	# Get the startup script
	wget -q -N https://raw.githubusercontent.com/terminalcloud/apps/master/others/bpf_hooks.sh
	mkdir -p /CL/hooks/
	mv bpf_hooks.sh /CL/hooks/startup.sh
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