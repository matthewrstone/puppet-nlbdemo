# Windows NLB Network Load Balancer
## Puppet Module for Windows Server 2012
### Proof of Concept
#### early early early early alpha

## Description

This is a module to enable the Network Load Balancing features native to Windows Server.  The module will install required features and management tools, create the cluster (if required), join new members and configure the port scope.

## Components

### nlbdemo Class

This is the primary class, but really does nothing at this point other than setting up a webserver for demo purposes.  No need to call it.

### nlb::service Defined Type

Used to install the Network Load Balancer windows feature and management tools.

### nlb::member Defined Type

Turns your server into a load balancer member / creates the cluster if it does not exist.

### nlb::ports Defined Type

Configures what ports should be on the load balancer.

### nlb_member_ip Custom Fact

The way that Puppet grabs the IP address fact for Windows becomes a problem when working with NLB.  The primary IP of the cluster becomes the value of the `ipaddress` fact, which can obviously cause some issues.  I created a custom fact for `nlb_member_ip` that, while isn't an exact science yet, helps get around this issue.

The fact will grab the WMI-Object for the network adapter and look into the IP Addresses property.  Using a few filters in Powershell to remove the Cluster Primary IP and a local IPv6 address from the list, in the most simple cases you should be left with the original IP of the server.

## Installation Notes

### Deployment order

Follow the usage instructions below for each node.  Currently the additional nodes need to see something at the primary cluster IP in order to add themselves to the cluster, otherwise they will try to build the cluster.  This...can cause issues, so it is highly recommend to run this on the first box, ensure the first node has converged, then proceed to add the additional boxes.

### VirtualBox

I am testing this in Vagrant with Virtualbox, which requires you to set the networking to promiscuous mode.  If you are running multiple Windows servers in Virtualbox you will also need to forward ports for WinRM and RDP.  Here is my sample config/vms.yaml and config/roles.yaml for use with the Oscar plugin to build the environment:

**config/vms.yaml:**

	---
	vms:
	- name: master
	  box: puppetmaster
	  roles:
  	  - pe-puppet-master
	  - name: nlbbox1
  	  box: windows-server-2012-r2-full
  	  roles:
  	  - pe-puppet-agent
  	  forwarded_ports:
  	  - { guest: 5985, host: 15985 }
	  - { guest: 3389, host: 13389 }
	- name: nlbbox2
  	  box: windows-server-2012-r2-full
  	  roles:
  	  - pe-puppet-agent
  	  forwarded_ports:
  	  - { guest: 5985, host: 25985 }
	  - { guest: 3389, host: 23389 }
	- name: nlbbox3
  	  box: windows-server-2012-r2-full
  	  roles:
  	  - pe-puppet-agent
  	  forwarded_ports:
  	  - { guest: 5985, host: 35985 }
	  - { guest: 3389, host: 33389 }
		
**config/roles.yaml:**

	---
	roles:
  	  pe-puppet-master:
        private_networks:
    	  - {ip: '0.0.0.0', auto_network: true}
    	provider:
    	  type: virtualbox
          customize:
            - [modifyvm, !ruby/sym id, '--memory', 1024]
    	provisioners:
      	  - {type: hosts}
          - {type: pe_bootstrap, role: !ruby/sym master}

  	  pe-puppet-agent:
        private_networks:
          - {ip: '0.0.0.0', auto_network: true}
    	provisioners:
      	  - {type: hosts}
	      - {type: pe_bootstrap}
    	provider:
      	  type: virtualbox
      	  customize:
        	- [modifyvm, !ruby/sym id, '--nicpromisc3', allow-all] 


## Usage

Put this in your manifest:

		nlbdemo::service { $hostname : }
		nlbdemo::member { $hostname :
    	  member_ip  => $::nlb_member_ip, 			# the original ip (hopefully)
    	  member_nic => 'Ethernet 2',				# the NIC you are putting on the cluster
    	  nlb_name   => 'www.puppetonwindows.com',  # The name of the cluster
    	  nlb_ip     => '10.20.1.50',				# the primary IP of the cluster
    	  nlb_subnet => '255.255.255.0',			# The subnet of the cluster
    	  nlb_mode   => 'Multicast',				# Mode - Unicast / Multicast
  		}

## Dependencies

- puppetlabs-powershell
- puppetlabs-registry
- opentable-windowsfeature