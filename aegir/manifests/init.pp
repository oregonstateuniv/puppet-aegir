# --------------------------------------------------------
# Base class for all aegir servers
# Not all of this is needed for MySQL or NFS server, but
# it doesn't hurt. The NFS server does need the aegir user.
#
# --------------------------------------------------------
class aegir {
	include stdlib
	include aegir::params

	# Shorten up our parameter variables
	$aegir_user         = $aegir::params::aegir_user
	$aegir_root         = $aegir::params::aegir_root
	$aegir_web_group    = $aegir::params::aegir_web_group
	$aegir_version      = $aegir::params::aegir_version
	$drush_version      = $aegir::params::drush_version

	# Install Pear and Drush
	include pear
	pear::package { 'PEAR': }
	pear::package { 'Console_Table': }
	pear::package { 'drush':
		version     => $drush_version,
		repository  => 'pear.drush.org',
		require => Pear::Package['PEAR', 'Console_Table'],
	}

	# Setup the Aegir user and directory
	user {$aegir_user:
		ensure    => present,
		home      => $aegir_root,
		groups    => $aegir_web_group,
		shell     => '/bin/bash',
	}

	# Make sure aegir directories are in place
	file { [ $aegir_root, "${aegir_root}/.drush", "${aegir_root}/.ssh" ]:
		owner   => $aegir_user,
		group   => $aegir_user,
		ensure  => directory,
		require => User["${aegir_user}"],
	}

	# Copy in .bashrc for aegir_user
	file { "${aegir_root}/.bashrc":
		owner   => $aegir_user,
		group   => $aegir_user,
		ensure  => file,
		content => template('aegir/bashrc'),
		mode    => 0440,
		require => File[$aegir_root],
	}

	# Copy in SSH keys for aegir user
	file { "${aegir_root}/.ssh/id_dsa":
		owner   => $aegir_user,
		group   => $aegir_user,
		ensure  => file,
		content => template('aegir/id_dsa'),
		mode    => 0400,
		require => File["${aegir_root}/.ssh"],
	}

	file { "${aegir_root}/.ssh/id_dsa.pub":
		owner   => $aegir_user,
		group   => $aegir_user,
		ensure  => file,
		content => template('aegir/id_dsa.pub'),
		mode    => 0440,
		require => File["${aegir_root}/.ssh/id_dsa"],
	}

	file { "${aegir_root}/.ssh/authorized_keys":
		owner   => $aegir_user,
		group   => $aegir_user,
		ensure  => file,
		content => template('aegir/authorized_keys'),
		mode    => 0440,
		require => File["${aegir_root}/.ssh/id_dsa.pub"],
	}

	# Add aegir user to sudoers
	file { '/etc/sudoers.d/aegir':
		ensure    => file,
		content   => template('aegir/aegir.sudo'),
		mode      => 0440,
		require   => Package['sudo'],
	}

	# Put the aegir alias in root's .bashrc
	file_line { 'aegir-alias':
		ensure  => present,
		path    => '/root/.bashrc',
		line    => "alias aegir='su -s /bin/bash - aegir'",
	}

	# Make sure Cron is running
		service { "crond":
		ensure => "running",
	}

}
