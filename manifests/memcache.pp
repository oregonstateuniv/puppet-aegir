# Make sure memcached is
#  - Installed
#  - Configured
#  - Running
#  - Open firewall port
#
# ---------------------------------

class aegir::memcached {

 package { 'memcached':
    ensure  => installed,
  }

 file { '/etc/memcached.conf':
    ensure  => present,
    content => template('memcached/memcached.conf'),
  }

  service { 'memcached':
    ensure    => running,
    enable    => true,
  }

  firewall { '70 allow memcache:11211':
    state     => ['NEW'],
    dport     => '11211',
    proto     => 'tcp',
    action    => 'accept',
  }

}
