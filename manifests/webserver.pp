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

