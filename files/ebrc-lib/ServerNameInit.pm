# $Id$
# $URL$
#
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

use Apache2::ServerUtil;
use Sys::Hostname;
use File::Basename;

$ServerName   = fileparse($0, '.conf');
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
    $s->log_error("Moving $0 to '$SVR::server_root/conf/disabled_sites/'");
    system("mv '$0' '$SVR::server_root/conf/disabled_sites/'");
    return 1;
}

$VH::ServerName = $ServerName;

1;
