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
# Puppet class to install and configure Aegir Hostmaster
#
# --------------------------------------------------------

class aegir::hostmaster {
	include stdlib
	include aegir::params

	# Shorten up our parameter variables
	$aegir_user         = $aegir::params::aegir_user
	$aegir_root         = $aegir::params::aegir_root
	$aegir_web_group    = $aegir::params::aegir_web_group
	$aegir_version      = $aegir::params::aegir_version
	$aegir_db_host      = $aegir::params::aegir_db_host
	$aegir_db_user      = $aegir::params::aegir_db_user
	$aegir_db_password  = $aegir::params::aegir_db_password
	$mysql_root_pwd     = $aegir::params::mysql_root_pwd
	$drush_version      = $aegir::params::drush_version


	# Install provision (Aegir backend)
	exec { 'provision-install':
		command     => "/usr/bin/drush dl --destination=${aegir_root}/.drush provision-${aegir_version}",
		creates     => "${aegir_root}/.drush/provision",
		user        => $aegir_user,
		group       => $aegir_user,
		logoutput   => 'on_failure',
		environment => "HOME=${aegir_root}",
		cwd         => "${aegir_root}/.drush",
		require     => [ File["${aegir_root}", "${aegir_root}/.drush"],
                                 Pear::Package['drush'] ],
	}

	# Install hostmaster (Aegir frontend)
	$a = " --script_user=${aegir_user}"
	$b = " --aegir_root=${aegir_root}"
	$c = " --web_group=${aegir_web_group}"
	$d = " --aegir_version=${aegir_version}"
	$e = " --aegir_db_host=${aegir_db_host}"
	$f = " --aegir_db_user=${aegir_db_user}"
	$g = " --aegir_db_pass=\'${aegir_db_password}\'"

	$opts = "${a}${b}${c}${d}${e}${f}${g}"

	exec {'hostmaster-install':
		command     => "/usr/bin/drush -y --debug hostmaster-install $opts > /var/aegir/install.log 2>&1",
		creates     => "${aegir_root}/hostmaster-${aegir_version}",
		user        => $aegir_user,
		group       => $aegir_user,
		logoutput   => 'on_failure',
		environment => ["HOME=${aegir_root}"],
		cwd         => $aegir_root,
		require     => Exec['provision-install'],
		notify	    => Service["${aegir::params::apache_service}"],
	}
}

