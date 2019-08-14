# Make temporary dir for gbrowse images; writable by Apache process
# and the group of the parent gbrowse dir.
#
# This can take a long time when there is a large cache
# so we fork() to avoid holding up the whole server.
#

my $gbrowseHtml = "/var/www/$VH::ServerName/html/gbrowse";

my $uid = Apache2::ServerUtil->user_id;
my $gid = (stat($gbrowseHtml))[5];

$SIG{CHLD} = 'IGNORE';
my $pid=fork();
if ($pid == 0) {

  close STDIN;
  close STDOUT;

  my $oldfh = select STDERR;
  local $| = 1;
  select $oldfh;
  
  if (-e $gbrowseHtml) {
    mkdir "$gbrowseHtml/tmp";
    qx(/usr/bin/find $gbrowseHtml/tmp -type d -exec /bin/chmod 2775 '{}' \\;);
    #qx(/usr/bin/find $gbrowseHtml/tmp -type f -exec /bin/chmod 0664 '{}' \\;);
    qx(/usr/bin/find $gbrowseHtml/tmp -type d -exec /bin/chown -R $uid:$gid '{}' \\;);
  }

  CORE::exit(0); # plain exit() is overloaded, need CORE's
}

1;
