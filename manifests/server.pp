# Class: puppet::server
#
class puppet::server {
   case $operatingsystem {
      ubuntu,debian: { include puppet::server::deb }
      RedHat,centos: { include puppet::server::rpm }
      default: { include puppet::server::base }
   }
}

class puppet::server::base {
   include puppet
   
   package { 'puppetmaster': 
     ensure => latest
   }
   
   service { 'puppetmaster': 
      enable => true,
      ensure  => running,
   }
   
   file { '/etc/puppet/fileserver.conf':
      source => ['puppet:///modules/puppet/etc/puppet/fileserver.conf'],
      notify => Service['puppetmaster'],
      require => Package['puppetmaster']
   }
}

class puppet::server::deb inherits puppet::server::base {
   Service['puppetmaster'] { hasstatus => 'true' }
   
   file { '/etc/default/puppetmaster':
      source => ['puppet:///modules/puppet/etc/default/puppetmaster'],
      notify => Service['puppetmaster'],
      require => Package['puppetmaster'],
   }
}

class puppet::server::rpm inherits puppet::server::base {
   Package['puppet'] { name => 'puppet-server' }
   
   file { '/etc/sysconfig/puppetmaster':
      source => ['puppet:///modules/puppet/etc/sysconfig/puppetmaster'],
      notify => Service['puppetmaster'],
      require => Package['puppetmaster']
   }
}
