# --------------------------------------------------------
# NFS Server and Client config for Aegir Server Pack
#
# --------------------------------------------------------

class aegir::nfs {
	# Not sure if I need this empty class just to have the sub-classes
}


class aegir::nfs::server {
	include aegir::nfs::redhat
	include aegir::params

 	# Firewall open port
	firewall { '40 allow nfs:2049':
    	state     => ['NEW'],
    	dport     => '2049',
    	proto     => 'tcp',
    	action    => 'accept',
  	}

	# NFS Exports
 	file_line { 'exports':
    	ensure  => present,
    	path    => '/etc/exports',
    	line    => $aegir::params::nfs_export,
    	notify  => Service["nfs"],
    }

}


class aegir::nfs::client {
	include aegir::params

	# Mount the platforms directory
  mount { "/var/aegir/platforms":
        device  => $aegir::params::nfs_mount,
        fstype  => "nfs",
        ensure  => "mounted",
        options => "defaults",
        atboot  => true,
    }
}


class aegir::nfs::redhat {
	# These are the packages needed by the NFS server

	package { "portmap":
		ensure => latest,
	}

	package { "nfs-utils":
		ensure => latest,
	}

	service { "portmap":
		ensure => running,
		enable => true,
		require => Package["portmap"],
	}

	service { "nfslock":
		ensure => running,
		enable => true,
		require => [
			Package["nfs-utils"],
			Service["portmap"],
		],
	}

	service { "nfs":
		ensure => running,
		enable => true,
		require => Service["nfslock"],
	}
}

