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

