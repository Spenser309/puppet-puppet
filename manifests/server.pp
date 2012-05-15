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
	$ensure       = 'installed',
	$enable       = 'enabled',
	$webserver    = 'webrick',
	$tagmail      = 'disable',
	$storeconfigs = 'disable',
	$queue        = 'disable',
	$backup       = 'disable',
) {
	case $operatingsystem {
		'ubuntu','debian': { include puppet::server::deb }
		'RedHat','centos': { include puppet::server::rpm }
		default: { include puppet::server::base }
	}
}

class puppet::server::base inherits puppet::server {
	case $webserver {
		'passenger': { include passenger }
		'mongrel' : { include mongrel }
	}

	package { 'puppetmaster': 
		ensure => latest,
	}
	
	if $webserver == 'webrick' {
		service { 'puppetmaster': 
			ensure  => 'running',
			require => [Package['puppetmaster'],
			            File['/etc/puppet/puppet.conf']],
		}
	}
	
	# If a puppet client is running on the same machine
	if defined(Puppet::File['/etc/puppet/puppet.conf'])
	{
		File['/etc/puppet/puppet.conf'] {
			content => template('puppet/etc/puppet/puppet.conf.common.erb',
			                   'puppet/etc/puppet/puppet.conf.agent.erb',
			                   'puppet/etc/puppet/puppet.conf.master.erb'),
			notify +> Service ['puppetmaster'],
			require +> Package ['puppetmaster'],
		}
	} else {
		file { '/etc/puppet/puppet.conf':
			content => template('puppet/etc/puppet/puppet.conf.common.erb',
			                    'puppet/etc/puppet/puppet.conf.master.erb'),
			notify => Service['puppetmaster'],
			require => Package['puppetmaster'],
		}
	}
}

class puppet::server::deb inherits puppet::server::base {
	if $webserver == 'webbrick' {
		Service['puppetmaster'] {
			hasstatus => true,
			require +> File['/etc/default/puppetmaster'],
		}
	}

	file { '/etc/default/puppetmaster':
		content => template('puppet/etc/default/puppetmaster.erb'),
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}

class puppet::server::rpm inherits puppet::server::base {
	Package['puppet'] { 
		name => 'puppet-server',
	}

	file { '/etc/sysconfig/puppetmaster':
		source => ['puppet:///modules/puppet/etc/sysconfig/puppetmaster'],
		notify => Service['puppetmaster'],
		require => Package['puppetmaster'],
	}
}
