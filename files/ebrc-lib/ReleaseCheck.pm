# If the dereferenced symlink for the site is the same as a 'w' site,
# then display a human readable message to go see the live site.
#
# Example, in this case
#   /var/www/b1.tritrypdb.org -> TriTrypDB/tritrypdb1.0/
#   /var/www/w1.tritrypdb.org -> TriTrypDB/tritrypdb1.0/
# Display a message.
#
# /.well-known/acme-challenge is always open for Let's Encrypt
# certbot.
#

# skip if this is a 'w' vhost config.
return if ( $VH::ServerName =~ /^w\d+\./ );

my $wDir = '/var/www';
my ($domain) = $VH::ServerName =~ m/^.+\.([^\.]+\.[^\.]+)/;
my $thisSiteDir = readlink($wDir . '/' . $VH::ServerName);

# get the 'w' symlinks for relevent domain
opendir(DIR, $wDir) || die "can't opendir $wDir: $!";
  my @wl = grep { /^w\d+\.$domain/ && -l "$wDir/$_" } readdir(DIR);
closedir DIR;
# dereference symlinks
my @w = map { readlink($wDir . '/' . $_) } @wl;

if ($thisSiteDir && (grep { /$thisSiteDir/ } @w)) {
  push @RedirectMatch, ['404', '^/(?!.well-known/acme-challenge).*$'];
  # the nobounce query_string informs the live site not to
  # bounce back to beta (see live site configuation)
  push @ErrorDocument, qq(404 "This site has been officially released. \
                     Please visit the public site at \
                     <a href='http://$domain/?nobounce'>http://$domain/</a>");
}


1;
