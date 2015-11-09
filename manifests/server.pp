# Setup Apache HTTPD server with minimal modules needed to
# support EuPathDB's Perl-driven virtual host configurations.
class ebrc_httpd_setup::server {

  contain '::apache'

  # Apache modules: include builtin classes to reduce 
  # duplicate definition errors, otherwise declare
  # with apache::mod class.
  contain '::apache::mod::headers'
  contain '::apache::mod::perl'
  contain '::apache::mod::proxy'
  contain '::apache::mod::php'
  
  contain '::apache_ext::mod::auth_tkt'
  contain '::apache_ext::mod::jk'
  contain '::apache_ext::mod::line_edit'

  contain '::apache_ext::php::ldap'
}