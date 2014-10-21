define nlbdemo::member (
  $member_ip,
  $member_nic,
  $nlb_name,
  $nlb_ip,
  $nlb_subnet,
  $nlb_mode,
  $member_name = $title,
) {
  # Powershell Commands
  $ps_nlb_opts   = ["-InterfaceName '${member_nic}'",
    "-ClusterName '${nlb_name}'",
    "-ClusterPrimaryIP '${nlb_ip}'",
    "-SubnetMask '${nlb_subnet}'",
    "-OperationMode '${nlb_mode}'",
    ]
  $ps_clearports = "Get-NlbClusterPortRule | Remove-NlbClusterPortRule -Force"
  $ps_addmember  = "Add-NlbClusterNode -NewNodeName '${member_name}' -NewNodeInterface '${member_nic}'"
  # stdlib Functions
  $opts = join($ps_nlb_opts,' ')

  exec { "Manage NLB ${nlb_ip}" :
    command  => "New-NlbCluster ${opts}; ${ps_clearports}",
    unless   => "if (!(Get-NlbCluster -HostName ${nlb_ip} -ErrorAction SilentlyContinue)) { exit 1 }",
    require  => Nlbdemo::Service[$member_name],
    provider => powershell,
  }

  nlbdemo::ports { "${nlb_name} 80" :
    start_port => 80,
    protocol   => 'TCP',
    affinity   => 'None',
    member_nic => $member_nic,
    require    => Exec["Manage NLB ${nlb_ip}"],
  }

  nlbdemo::ports { "${nlb_name} 443" :
    start_port => 443,
    protocol   => 'TCP',
    affinity   => 'None',
    member_nic => $member_nic,
    require    => Exec["Manage NLB ${nlb_ip}"],
  }

  exec { "Add ${member_name} to NLB" :
    command  => "Get-NlbCluster -HostName '${nlb_ip}' | ${ps_addmember}",
    unless   => "If (!(Get-NlbCluster -HostName '${member_name}' -ErrorAction SilentlyContinue)) { exit 1 }",
    require  => Exec["Manage NLB ${nlb_ip}"],
    provider => powershell,
  }
}
