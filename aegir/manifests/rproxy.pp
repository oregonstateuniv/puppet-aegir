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
