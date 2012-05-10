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
#   none
# Sample Usage:
#   include puppet
#
class puppet {
   case $operatingsystem {
      ubuntu, debian: { include puppet::deb }
      centos, RedHat: { include puppet::rpm }
      default: { include puppet::base }
   }
}

class puppet::base {
   # The puppet installation
   package {'puppet':
     ensure => present
   }
   
   # The puppet service
   service {'puppet':
      enable  => true,
      ensure  => running,
      require => Package['puppet']
   }
   
   # Set defaults for configuration files
   File { 
      owner => 'root',
      group => 'root',
      notify => Service['puppet'],
      require => Package['puppet']
      
   }
   
   # The configuration files for puppet
   file {'/etc/puppet/puppet.conf':
         source => ['puppet:///modules/puppet/etc/puppet/puppet.conf']
   }
   
   # Needed for puppet kick
   file {
      '/etc/puppet/namespaceauth.conf':
         source => ['puppet:///modules/puppet/etc/puppet/namespaceauth.conf'];
      '/etc/puppet/auth.conf':
         source => ['puppet:///modules/puppet/etc/puppet/auth.conf'];
   }
	
}

class puppet::deb inherits puppet::base {
   # This file makes puppet start by default on debian systems
   file {'/etc/default/puppet':
      source  => ['puppet:///modules/puppet/etc/default/puppet']
   }
}

class puppet::rpm inherits puppet::base {
   # This file makes puppet start by default on redhat systems.
   file {'/etc/sysconfig/puppet':
      source  => ['puppet:///modules/puppet/etc/sysconfig/puppet']
   }
}

