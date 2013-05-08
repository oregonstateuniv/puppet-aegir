# Copyright (C) 2013 Oregon State University
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.
#
# To contact us, go to http://oregonstate.edu/cws/contact and fill out the contact form.
#
# Alternatively mail us at:
#
# Oregon State University
# Central Web Services
# 121 The Valley Library
# Corvallis, OR 97331

# --------------------------------------------------------
#
# Puppet class for Aegir MySQL server
#
# --------------------------------------------------------

class aegir::dbserver {
	include aegir::params

	# Shorten up our parameter variables
	$aegir_db_host      = $aegir::params::aegir_db_host
	$aegir_db_user      = $aegir::params::aegir_db_user
	$aegir_db_password  = $aegir::params::aegir_db_password
	$mysql_root_pwd     = $aegir::params::mysql_root_pwd

	# Install MySQL
	class { 'mysql': }
	class { 'mysql::server':
		config_hash => { 'root_password' => $mysql_root_pwd },
	}

	# Firewall open port 3306
	firewall { '90 allow mysqld:3306':
		state     => ['NEW'],
		dport     => '3306',
		proto     => 'tcp',
		action    => 'accept',
	}

	# Make MySQL listen on all addresses
	file_line { 'my.cnf':
		ensure    => present,
		path      => $aegir::params::my_cnf_file,
		match     => 'bind-address.+',
		line      => '#bind-address    = 127.0.0.1',
		require   => Class['mysql::server'],
	}

	# These next 2 exec commands are a bit hackish
	# They redirect thier output to a file in /root's home dir
	# just for the purpose of being able to use the 'creates'
	# parameter here, so that these execs will not be triggered again.
	# There must be a better way to do this.

	# MySQL secure installation
	exec { 'mysql-secure':
		command   => "/usr/bin/mysql -u root -p\'$mysql_root_pwd\' -e \'DELETE FROM mysql.user WHERE user = \" \"; FLUSH PRIVILEGES; \' > /root/mysql-secure ",
		creates   => "/root/mysql-secure",
		require   => Class['mysql::server'],
	}

	# Gant privileges for the aegir user
	$grant_command = "GRANT ALL PRIVILEGES ON *.* TO \'$aegir_db_user\'@'%' IDENTIFIED BY \'$aegir_db_password\' WITH GRANT OPTION"
	exec { 'mysql-aegir-user':
		command   => "/usr/bin/mysql -u root -p\'$mysql_root_pwd\' -e \"$grant_command\" > /root/mysql-grant",
		creates   => "/root/mysql-grant",
		require   => Exec['mysql-secure'],
	}

}
