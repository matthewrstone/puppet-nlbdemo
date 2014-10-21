class nlbdemo (
  $virtual_ip,
  $member_type='additional',
){
  case $member_type {
    'primary'    : { Nlbdemo::Member <<||>> }
    'additional' : { @@nlbdemo::member { $::hostname : } }
    default : { }
  }
  windowsfeature { 'NLB' : }
  windowsfeature { 'Web-WebServer' : }
  file { 'c:\inetpub\wwwroot\test.html' :
    ensure  => file,
    content => "I am a webserver called ${::hostname}.",
    require => Windowsfeature['Web-WebServer'],
  }
  host { 'www.puppetonwindows.com' :
    ip           => $virtual_ip,
    comment      => 'Network Load Balancer - Puppet',
  }
}
