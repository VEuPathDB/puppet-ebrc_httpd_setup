# Setup Apache HTTPD server with minimal modules needed to
# support EuPathDB's Perl-driven virtual host configurations.
#
# Use hiera for module configurations
#    apache::mod::prefork::maxrequestsperchild: 1001
#    apache::mod::deflate::types: []
#    apache::mod::remoteip::header: X-Forwarded-For
# as a few examples.
#
class ebrc_httpd_setup::server {

  contain '::apache'
  apache::listen { '443':}
  apache::listen { '80':}

  # Apache modules: include builtin classes to reduce 
  # duplicate definition errors, otherwise declare
  # with apache::mod class.
  contain '::apache::mod::authnz_ldap'
  contain '::apache::mod::headers'
  contain '::apache::mod::perl'
  contain '::apache::mod::php'
  contain '::apache::mod::proxy_html'
  contain '::apache::mod::proxy_http'
  contain '::apache::mod::proxy'
  contain '::apache::mod::proxy'
  contain '::apache::mod::remoteip'
  contain '::apache::mod::ssl'
  contain '::apache::mod::fcgid'
  contain '::apache::mod::status'

  contain '::apache_ext::mod::jk'
  contain '::apache_ext::mod::line_edit'
  contain '::apache_ext::mod::macro'
  contain '::apache_ext::mod::proxy_wstunnel' # Shiny Server

  contain '::apache_ext::php::ldap'

  contain '::mod_auth_tkt'

}
