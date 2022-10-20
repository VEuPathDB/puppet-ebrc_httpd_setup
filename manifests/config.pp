# Install configuration files and Perl modules for Perl-driven virtual host
# configuration.
class ebrc_httpd_setup::config (
  $lib_dir            = '/etc/httpd/conf/lib',
  $enable_sites_dir   = '/etc/httpd/conf/enabled_sites',
  $disabled_sites_dir = '/etc/httpd/conf/disabled_sites',
  $compiled_dir       = '/etc/httpd/conf/compiled',
) {

  $manage_enabled_sites = lookup ({
      'name' => 'ebrc_httpd_setup::manage_enabled_sites',
      'default_value' => true})

  include '::apache'
  contain '::ebrc_httpd_setup::website_release_stages'

  File {
    require => Class['::apache'],
    notify  => Class['apache::service'],
  }

  file { [
    $disabled_sites_dir,
    $compiled_dir,
  ]:
    ensure => directory,
    mode   => '0755',
  }

  if($manage_enabled_sites) {
    file { $enable_sites_dir:
      ensure => directory,
      mode   => '0755',
    }
  }

  Apache::Custom_config {
    priority => false,
    require => [
      File[$enable_sites_dir],
      File[$disabled_sites_dir],
      File[$compiled_dir],
    ]
  }

  apache::custom_config { 'z-ebrc-misc':
    source  => 'puppet:///modules/ebrc_httpd_setup/ebrc-misc.conf',
  }

  apache::custom_config { 'z-ebrc':
    source  => 'puppet:///modules/ebrc_httpd_setup/ebrc.conf',
  }

  ########################################################################
  # PerlSection Perl modules, ToBe moved into an RPM?
  ########################################################################

  ebrc_httpd_setup::libfile { 'ApiDB.generic.conf.template': }
  ebrc_httpd_setup::libfile { 'ApiDB.generic.static.conf.template': }
  ebrc_httpd_setup::libfile { 'ApiDB.pm': }
  ebrc_httpd_setup::libfile { 'ApiStaticWebsite.pm': }
  ebrc_httpd_setup::libfile { 'Containers.pm': }
  ebrc_httpd_setup::libfile { 'CryptoDB.pm': }
  ebrc_httpd_setup::libfile { 'DashboardStaticAuth.conf': }
  ebrc_httpd_setup::libfile { 'DirectoryFileDescriptions.conf': }
  ebrc_httpd_setup::libfile { 'DownloadDir.conf': }
  ebrc_httpd_setup::libfile { 'Dumpost.pm': }
  ebrc_httpd_setup::libfile { 'EuPathDB.pm': }
  ebrc_httpd_setup::libfile { 'Gbrowse.pm': }
  ebrc_httpd_setup::libfile { 'GbrowsePreload.pm': }
  ebrc_httpd_setup::libfile { 'MimeTypes.conf': }
  ebrc_httpd_setup::libfile { 'OrthoMCL.pm': }
  ebrc_httpd_setup::libfile { 'Postscript.pm': }
  ebrc_httpd_setup::libfile { 'Publish.pm': }
  ebrc_httpd_setup::libfile { 'ReleaseCheck.pm': }
  ebrc_httpd_setup::libfile { 'ServerNameInit.pm': }
  ebrc_httpd_setup::libfile { 'ServerStatus.conf': }
  ebrc_httpd_setup::libfile { 'Util.pm': }

  ebrc_httpd_setup::libtmpl { 'QaAuth.pm': }
  ebrc_httpd_setup::libtmpl { 'ApiCommonWebsite.pm': }

  ########################################################################
  # End PerlSection Perl modules, ToBe moved into an RPM?
  ########################################################################

}
