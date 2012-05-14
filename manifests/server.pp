#	Class: puppet::server
#
#	Provides: A puppet server
#
#	Limitations
#		Tested on Ubuntu 12.04 and Redhat 6.
#
#	ensure -
#		installed - make sure everything is installed
#		removed   - remove the installation
#
#	enable - 
#		true      - running
#		false     - disabled 
#
#	webserver - 
#		web_brick - no additional modules required
#		passenger - apache module required
#		mongrel   - mongrel module required
#
#	tagmail - 
#		enable - requires smtp server
#		disable - no additional modules required
#
#	storeconfigs -
#		disable - no additional modules required
#		mysql   - mysql module required
#		sqllite - no additional modules required
class puppet::server (
	$ensure    = 'installed',
	$enable    = 'enabled',
	$webserver = 'web_brick',
	$tagmail   = 'disable',
	$storeconfigs = 'disable',
) {
	case $operatingsystem {
		ubuntu,debian: { include puppet::server::deb }
		RedHat,centos: { include puppet::server::rpm }
		default: { include puppet::server::base }
	}
}

class puppet::server::base inherits puppet::server {
	if $webserver == 'passenger' {
		package{'passenger':
			ensure => latest,
		}
	}

	package { 'puppetmaster': 
		ensure => latest,
	}
	
	if $webserver == 'web_brick' {
		service { 'puppetmaster': 
			enable => $enable,
			ensure  => 'running',
			require => Package['puppetmaster'],
		}
	}

	if defined(Puppet::File['/etc/puppet/puppet.conf'])
	{
		File['/etc/puppet/puppet.conf'] {
			source => ['puppet:///modules/puppet/etc/puppet/puppet.conf.combined'],
			notify +> Service ['puppetmaster'],
			require +> Package ['puppetmaster'],
		}
	} else {
		file { '/etc/puppet/puppet.conf':
			source => ['puppet:///modules/puppet/etc/puppet/puppet.conf.server'],

			notify => Service['puppetmaster'],
			require => Package['puppetmaster'],
		}
	}
}

class puppet::server::deb inherits puppet::server::base {
	Service['puppetmaster'] { hasstatus => 'true',
	}

	file { '/etc/default/puppetmaster':
		source => ['puppet:///modules/puppet/etc/default/puppetmaster'],
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}

class puppet::server::rpm inherits puppet::server::base {
	Package['puppet'] { name => 'puppet-server',
	}

	file { '/etc/sysconfig/puppetmaster':
		source => ['puppet:///modules/puppet/etc/sysconfig/puppetmaster'],
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}
