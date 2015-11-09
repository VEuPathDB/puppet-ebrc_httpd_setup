# manage library files (default /etc/httpd/conf/lib/).
# These are primarily for the Perl-driven vhost configuration.
define ebrc_httpd_setup::libfile (
  $ensure   = 'present',
  $lib_path = $::ebrc_httpd_setup::lib_path,
) {

  file { $name:
    ensure  => $ensure,
    path    => "${::apache::conf_dir}/lib/${name}",
    source  => "puppet:///modules/ebrc_httpd_setup/ebrc-lib/${name}",
    owner   => 'root',
    group   => $::apache::group,
    mode    => '0644',
    notify  => Class['apache::service'],
    require => [
      Class['apache'],
      File[$lib_path]
    ]
  }

}