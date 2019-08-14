# Manages the EuPathDB overlay to Apache HTTPD server per the specifications
# described at https://wiki.apidb.org/index.php/UGAWebserverConfiguration
class ebrc_httpd_setup (
  String           $conf_lib_path            = '',
  String           $oracle_home              = lookup('oracle_home', String),
  Optional[String] $dashboard_security_token = undef,
) {

  include '::apache'
  include '::epel'
  include '::ebrc_yum_repo'

  if $conf_lib_path == '' {
    $lib_path = "${::apache::conf_dir}/lib"
  }

  if $::osfamily != 'redhat' {
    fail('OS not supported. Expect an RedHat family.')
  }

  contain '::ebrc_httpd_setup::server'
  contain '::ebrc_httpd_setup::config'

  Class['::epel']
  -> Class['::ebrc_yum_repo']
  -> Class['::ebrc_httpd_setup::server']
  -> Class['::ebrc_httpd_setup::config']

  file { $lib_path:
    ensure => directory,
    mode   => '0755',
    owner  => 'root',
    group  => $::apache::group,
  }

  file { '/etc/httpd/conf.d/ebrc-dashboard.conf':
    mode    => '0600', # contains secrets!
    owner   => 'root',
    content => template('ebrc_httpd_setup/ebrc-dashboard.conf.erb'),
    notify  => Service['httpd'],
  }

  file { '/etc/httpd/conf.d/oracle.conf':
    mode    => '0644',
    owner   => 'root',
    content => template('ebrc_httpd_setup/oracle.conf.erb'),
    notify  => Service['httpd'],
  }

  file { "${::apache::docroot}/index.html":
    mode    => '0644',
    owner   => 'root',
    content => template('ebrc_httpd_setup/index.html.erb'),
  }

}
