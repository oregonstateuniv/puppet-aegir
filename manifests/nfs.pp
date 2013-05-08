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

