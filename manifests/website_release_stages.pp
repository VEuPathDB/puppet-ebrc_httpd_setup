# Website release stages added as environment variables to 
# /etc/sysconfig/httpd (sourced by SysV init scripts or 
# as systemd EnvironmentFile on RedHat systems.
# https://wiki.apidb.org/index.php/WebsiteReleaseStages
class ebrc_httpd_setup::website_release_stages {

  if $::osfamily != 'redhat' {
    fail('OS not supported. Expect an RedHat family.')
  }

  # Warning: these values need to be in sync with any settings in use by
  # applications. For example, the WDK sets stage values in
  # WebsiteReleaseConstants.java . So do not go all willy-nilly on them.
  $stage = {
    development => 10,
    integrate   => 20,
    feature     => 30,
    alpha       => 40,
    qa          => 50,
    beta        => 60,
    www         => 70,
  }

  # env vars must 'export' in /etc/sysconfig/httpd when using SysVinit
  # scripts but 'export' is invalid syntax for systemd (rhel >=7)
  if versioncmp($::operatingsystemmajrelease, '7') >= 0 {
    $export = ''
  } else {
    $export = 'export '
  }

  File_line {
    ensure => present,
    path    => '/etc/sysconfig/httpd',
    require => Package['httpd'],
    notify  => Class['apache::service'],
  }

  file_line { 'WEBSITE_RELEASE_STAGE_DEVELOPMENT':
    line => "${export}WEBSITE_RELEASE_STAGE_DEVELOPMENT=${stage['development']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_INTEGRATE':
    line => "${export}WEBSITE_RELEASE_STAGE_INTEGRATE=${stage['integrate']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_FEATURE':
    line => "${export}WEBSITE_RELEASE_STAGE_FEATURE=${stage['feature']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_ALPHA':
    line => "${export}WEBSITE_RELEASE_STAGE_ALPHA=${stage['alpha']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_QA':
    line => "${export}WEBSITE_RELEASE_STAGE_QA=${stage['qa']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_BETA':
    line => "${export}WEBSITE_RELEASE_STAGE_BETA=${stage['beta']}",
  }
  file_line { 'WEBSITE_RELEASE_STAGE_WWW':
    line => "${export}WEBSITE_RELEASE_STAGE_WWW=${stage['www']}",
  }


}