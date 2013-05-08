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
# Puppet class for Aegir Varnish server
#
# --------------------------------------------------------

class aegir::rproxy {

    include aegir::params
    include aegir::rproxy::redhat

    $backend1 = $aegir::params::backend1
    $backend2 = $aegir::params::backend2
    $subnet	  = $aegir::params::subnet


    file {'/etc/varnish/default.vcl' :
        ensure	=> file,
        content => template('aegir/default.vcl'),
    }

    file {'/etc/sysconfig/varnish' :
        ensure	=> file,
        content => template('aegir/varnish'),
    }

    # Firewall open port 80
    firewall { '80 allow httpd:80':
        state     => ['NEW'],
        dport     => '80',
        proto     => 'tcp',
        action    => 'accept',
    }

    # Firewall open port 6082
    firewall { '680 allow varnishd:6082':
        state     => ['NEW'],
        dport     => '6082',
        proto     => 'tcp',
        action    => 'accept',
    }
}

class aegir::rproxy::redhat {

    package { 'varnish' :
        ensure => latest,
    }

    service { 'varnish' :
		    ensure      => running,
		    enable      => true,
        require     => Package['varnish'],
    }

    #  rpm --nosignature -i http://repo.varnish-cache.org/redhat/varnish-3.0/el5/noarch/varnish-release-3.0-1.noarch.rpm

    yumrepo { 'varnish-cache' :
        descr       => 'Varnish 3.0 for Enterprise Linux 5 - $basearch',
        baseurl     => 'http://repo.varnish-cache.org/redhat/varnish-3.0/el5/$basearch',
        enabled     => 1,
        gpgcheck    => 0,
        #gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-VARNISH',
    }
}
