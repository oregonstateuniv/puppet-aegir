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
