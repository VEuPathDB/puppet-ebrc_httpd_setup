# Website release stages added as environment variables to 
# /etc/sysconfig/httpd (sourced by SysV init scripts or 
# as systemd EnvironmentFile on RedHat systems.
# https://wiki.apidb.org/index.php/WebsiteReleaseStages
class ebrc_httpd_setup::website_release_stages {

  if $facts['os']['family'] != 'redhat' {
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

  file { "/etc/sysconfig/httpd":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("ebrc_httpd_setup/website-release-stages.env.erb"),
  }

  # override the default schedule (daily at midnight) with the setting from hiera
  systemd::dropin_file { 'website-release-stages.conf':
    unit           => 'httpd.service',
    content        => template("ebrc_httpd_setup/website-release-stages.conf.erb"),
    require        => Package['httpd'],
    notify_service => true,
  }


}