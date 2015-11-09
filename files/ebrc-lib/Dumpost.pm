# Configure mod_dumpost module
#   https://github.com/danghvu/mod_dumpost
# Requires that mod_dumpost be installed.
#
# Usage: call configureDumpost() with an optional list of HTTP Headers 
# to include in the log.
#    <Perl>
#       require 'conf/lib/Dumpost.pm';
#       configureDumpost(['Cookie', 'Content-Type']);
#    </Perl>
#

use File::Spec::Functions qw(catfile);

sub configureDumpost {
  my ($addheaders) = @_;
  
  $DumpPostHeaderAdd = $addheaders;
  $DumpPostLogFile = catfile Apache2::ServerUtil::server_root, 'logs', $VH::ServerName, 'dumpost_log';
  
  # the log file must pre-exist and be owned by the 'run as' user. Otherwise DumpPostLogFile is
  # ignored and and STDERR (error_log) is used.
  open my $fh, '>>', $DumpPostLogFile; close $fh; 
  chown Apache2::ServerUtil->user_id  , Apache2::ServerUtil->group_id ,  $DumpPostLogFile;
}

1;
