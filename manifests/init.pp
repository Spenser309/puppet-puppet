# Class: puppet
#
# This class sets up the puppet server and client instances
#
# Parameters:
#   none 
#
# Actions:
#   Installs the puppet server or client
#
# Requires:
#	none
# Sample Usage:
#	include puppet
#
class puppet {
	case $operatingsystem {
		ubuntu: { include puppet::ubuntu },
		debian: { include puppet::ubuntu },
		RedHat: { inlcude puppet::redhat },
		centos: { include puppet::redhat },
		default: { include puppet::base }
	}
}

class puppet::base {
	package {'puppet': ensure => installed }	

	service {'puppet':
		enable    => true,
		ensure    => running,
	}
	
	file { '/etc/puppet/puppet.conf':
		source => ['puppet:///files/etc/puppet/puppet.conf', 
                           'puppet:///modules/puppet/etc/puppet/puppet.conf'],
		owner => 'root',
		group => 'root',
		mode => '640',
		notify => Service['puppet'],
		require => Package['puppet'],
	}
}

class puppet::ubuntu inherits puppet::base {
	file { '/etc/default/puppet':
		source  => ['puppet:///files/etc/default/puppet',
		            'puppet:///modules/puppet/etc/default/puppet.conf'],
		owner   => 'root',
		group   => 'root',
		mode    => '640',
		notify  => Service['puppet'],
		require => Package['puppet'],
	}
}

class puppet::redhat inherits puppet::base {
	file { '/etc/sysconfig/puppet':
		source  => ['puppet:///files/etc/sysconfig/puppet',
		            'puppet:///modules/puppet/etc/sysconfig/puppet'],	
		owner   => 'root',
		group   => 'root',
		mode    => '0640',
		notify  => Service['puppet'],
		require => Package['puppet'],
	}
}

