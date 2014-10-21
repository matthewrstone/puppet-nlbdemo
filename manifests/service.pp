define nlbdemo::service ( $ensure = present ) {
  $features = ['NLB','RSAT-NLB']
  case $ensure {
    present : { windowsfeature { $features : } }
    absent  : { windowsfeature { $features : ensure => absent } }
    default : { fail('Must specify ensure status...') }
  }
}
