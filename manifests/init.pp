# Manages the EuPathDB overlay to Apache HTTPD server per the specifications
# described at https://wiki.apidb.org/index.php/UGAWebserverConfiguration
class ebrc_httpd_setup (
  $lib_path = "${::apache::conf_dir}/lib",
) {

  if $::osfamily != 'redhat' {
    fail('OS not supported. Expect an RedHat family.')
  }

  contain '::ebrc_httpd_setup::server'
  contain '::ebrc_httpd_setup::config'

  Class['::ebrc_httpd_setup::server'] ->
  Class['::ebrc_httpd_setup::config']

  file { $lib_path:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => $::apache::group,
  }

}
