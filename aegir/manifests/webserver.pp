# --------------------------------------------------------
# Puppet class for Aegir Apache web server
#
# --------------------------------------------------------

class aegir::webserver {
	include stdlib
	include aegir::params

	# Install Apache
	class { 'apache': }
	class { 'apache::mod::php': }

	# Firewall open port 80
	firewall { '80 allow httpd:80':
		state     => ['NEW'],
		dport     => '80',
		proto     => 'tcp',
		action    => 'accept',
	}

	# PHP packages we need
	package { $aegir::params::php_packages :
		ensure    => 'installed',
		require   => Package['php'],
	}

	# php.ini needs a timezone
	file_line { 'php.ini':
		ensure    => present,
		path      => $aegir::params::php_ini_file,
		line      => 'date.timezone = America/Los_Angeles',
		require   => Package['php'],
	}

	# Create the apache config symlink
	file { '/etc/httpd/conf.d/aegir.conf':
		ensure    => link,
		target    => '/var/aegir/config/apache.conf',
	}
}

