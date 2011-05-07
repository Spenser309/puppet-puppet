# Class: puppet::server
#
#
#
#
class puppet::server {
	case $operatingsystem {
		ubuntu: { include puppet::server::ubuntu },
		debian: { include puppet::server::ubuntu },
		RedHat: { include puppet::server::redhat },
		centos: { include puppet::server::redhat },
		default: { include puppet::server::base }
	}
}

class puppet::server::base {
	include puppet

	package { 'puppetmaster': ensure => installed }

	service { 'puppetmaster': 
		enabled => true,
		ensure  => running,
	}

	file { '/etc/puppet/fileserver.conf':
		source => ['puppet:///files/etc/puppet/fileserver.conf',
		           'puppet:///modules/puppet/etc/puppet/puppet.conf],
		owner  => 'root',
		group  => 'root',
		mode   => '640',
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
	
	file { '/etc/puppet/auth.conf':
		source => ['puppet:///files/etc/puppet/fileserver.conf',
		           'puppet:///modules/puppet/etc/puppet/fileserver.conf'],
		owner  => 'root',
		group  => 'root',
		mode   => '640',
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}

class puppet::server::ubuntu inherits puppet::server::base {
	
	file { '/etc/default/puppetmaster':
		source => ['puppet:///files/etc/default/puppetmaster',
		           'puppet:///modules/puppet/etc/default/puppetmaster'],
		owner  => 'root',
		group  => 'root',
		mode   => '640',
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}

class puppet::server::redhat inherits puppet::server::base {
	
	Package { 'puppetmaster': name => 'puppet-server' }

	file { '/etc/sysconfig/puppetmaster':
		source => ['puppet:///files/etc/sysconfig/puppetmaster',
		           'puppet:///modules/puppet/etc/sysconfig/puppetmaster'],
		owner  => 'root',
		group  => 'root',
		mode   => '640',
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}
