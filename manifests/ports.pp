define nlbdemo::ports (
  $start_port,
  $protocol,
  $affinity,
  $member_nic,
  $end_port = $start_port,
  $nlb_name = $nlb_name,
){
  exec {"Manage ${start_port} for ${nlb_name}" :
    command  => "Add-NlbClusterPortRule -InterfaceName '${member_nic}' -StartPort ${start_port} -EndPort ${end_port} -Protocol ${protocol} -Affinity ${affinity} | Out-Null",
    unless   => "If (!(Get-NlbClusterPortRule -Port ${start_port} -ErrorAction SilentlyContinue)) { exit 1 }",
    provider => powershell,
  }
}
