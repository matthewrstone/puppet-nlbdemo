class nlbdemo (
  $nlb_ip,
){
  windowsfeature { 'Web-WebServer' : }
  file { 'c:\inetpub\wwwroot\test.html' :
    ensure  => file,
    content => "I am a webserver called ${::hostname}.",
    require => Windowsfeature['Web-WebServer'],
  }
  host { 'www.puppetonwindows.com' :
    ip           => $nlb_ip,
    comment      => 'Network Load Balancer - Puppet',
  }
}
