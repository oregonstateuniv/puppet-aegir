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

# ----------------------------------------------
# Class aegir::params
#
# Defines some variables for installing aegir
# Will work on redhat/centos or debian/ubuntu
#
# ---------------------------------------------

class aegir::params {

	$aegir_user         = 'aegir'
	$aegir_root         = '/var/aegir'
	$aegir_version      = '6.x-1.9'
	$aegir_db_host      = 'localhost'
	$aegir_db_user      = 'aegir_root'
	$aegir_db_password  = ''
	$mysql_root_pwd     = ''
	$drush_version      = '4.6.0'

	# Used for server packs
	$nfs_export		  = '/srv/web/platforms your-local-subnet/24(rw,no_subtree_check)'
	$nfs_mount		  = 'your-nfs-server-ip:/srv/web/platforms'

	# Varnish backends
	$backend1 = 'aegir pack server 1 ip'
	$backend2 = 'aegir pack server 2 ip'
	$subnet   = 'your-local-subnet'

	# Define the appopriate packages and parameters for redhat and debian
	case $::osfamily {
		'redhat': {
			  $php_packages       = ['php-mysql', 'php-pdo', 'php-tidy',
						 'php-gd', 'php-process','php-xml',
						 'php-pecl-memcached', 'php-mbstring' ]
			  $aegir_web_group    = 'apache'
			  $php_ini_file       = '/etc/php.ini'
			  $my_cnf_file        = '/etc/my.cnf'
			  $apache_command     = '/etc/init.d/httpd'
			  $apache_service     = 'httpd'
		}
		'debian': {
			  $php_packages       = ['php5', 'php5-cli', 'php5-gd', 'php5-mysql']
			  $aegir_web_group    = 'www-data'
			  $php_ini_file       = '/etc/php5/apache/php.ini'
			  $my_cnf_file        = '/etc/mysql/my.cnf'
			  $apache_command     = '/etc/init.d/apache2'
			  $apache_service     = 'apache2'
		}
		default:  {
			  fail("Class['aegir::params']: Unsupported operatingsystem: $operatingsystem")
		}
	}
}

