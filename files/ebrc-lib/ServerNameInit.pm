# Establish the ServerName for a virtual host.
# For hypothetical 'blah.servername.org', this module expects the following:
#  - this module be included in blah.servername.org.conf
#  - /var/www/blah.servername.org is a symbolic link
#
# If these expectations are not met, the module moves the 
# blah.servername.org.conf to $SVR::server_root/conf/disabled_sites/
#
# Otherwise, sets a global package variable $VH::ServerName
#
# ApiDB BRC 2008
# EuPathDB BRC 2017

use Apache2::ServerUtil;
use Sys::Hostname;
use File::Basename;

# Handle legacy, pre 10/2017, vhost configurations vs. newer ones using
# mod_macro templating. Configs using mod_macro define $VH::ConfigFile
# because $0 is not the invoking script/confg in the macro context.
# Legacy, non-macro vhost configs don't set $VH::ConfigFile, so set
# it here.
if (!defined($VH::ConfigFile)) {
  $VH::ConfigFile = $0;
}
$ServerName   = fileparse($VH::ConfigFile, '.conf');
$SVR::server_root = Apache2::ServerUtil::server_root();
$SVR::hostname = Sys::Hostname::hostname();

$Apache2::PerlSections::Save = 1;

# handle if missing symlink by
# - logging error
# - moving the conf file to conf/disabled_sites
#
# this kinda works but Apache still fails to continue if symlink is missing
# requiring a second attempt to reload/start
unless (-l '/var/www/'.$ServerName) {
    use Apache2::Log;
    my $s = Apache2::ServerUtil->server;
    if (-e '/var/www/'.$ServerName) {
        $s->log_error("$ServerName failure: '/var/www/$ServerName' is not a symbolic link.")
    } else {
        $s->log_error("$ServerName failure: Symbolic link '/var/www/$ServerName' not found.")
    }
    $s->log_error("Moving $VH::ConfigFile to '$SVR::server_root/conf/disabled_sites/'");
    system("mv '$VH::ConfigFile' '$SVR::server_root/conf/disabled_sites/'");
    return 1;
}

$VH::ServerName = $ServerName;

1;
