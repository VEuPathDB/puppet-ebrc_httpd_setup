# these functions set proxypass config for local containerized services.  There
# is a function for each service, as these services may not be applied to every
# site.
#
# They take an argument for 'stage' which is dev,qa,prod and call
# set_proxy_urls, which sets the values accordingly.  Those values are then
# used individually by service specific functions to set proxies as required by
# that service
#
# It is used by callers like this:
#
# <Perl>
#   require 'conf/lib/Containers.pm';
#   set_sitesearch_proxy('dev');
#   set_mapveu_proxy('dev');
# </Perl>
#
# Note that the first call of these functions wins - subsequent calls do not
# change the proxies
#


sub set_proxy_urls {

  my $stage = shift;
  chomp($stage);

#---------------------------------------------------------------------#
#        define urls per stage                                        #
#---------------------------------------------------------------------#
  
  if ($stage eq "dev") {
      $VH::site_search_proxy_url = "https://sitesearch-dev.local.apidb.org:8443";
      $VH::mapveu_proxy_url      = "https://mapveu-dev.local.apidb.org:8443";
  }

  if ($stage eq "qa") {
      $VH::site_search_proxy_url = "https://sitesearch-qa.local.apidb.org:8443";
      $VH::mapveu_proxy_url      = "https://mapveu-qa.local.apidb.org:8443";
  }

#---------------------------------------------------------------------#
#        set for all proxies                                          #
#---------------------------------------------------------------------#
  
  $SSLProxyEngine = 'on';
  $ProxyPreserveHost = 'off';

}

#---------------------------------------------------------------------#
#        SiteSearch proxy                                             #
#---------------------------------------------------------------------#
  
sub set_sitesearch_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  push @ProxyPass,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;

}

#---------------------------------------------------------------------#
#        MapVEu proxy                                                 #
#---------------------------------------------------------------------#
  
sub set_mapveu_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  # if there is a directory named 'popbio-map' in html, we assume this vhost is
  # being used to develop the map, and only proxy the solr backends 

  if (-d '/var/www/'.$VH::ServerName.'/html/popbio-map') {
    push @ProxyPass,
        [ "/popbio-map/web/esolr ${VH::mapveu_proxy_url}/web/esolr" ],
    ;
    push @ProxyPassReverse,
        [ "/popbio-map/web/esolr ${VH::mapveu_proxy_url}/web/esolr" ],
    ;
    push @ProxyPass,
        [ "/popbio-map/web/asolr ${VH::mapveu_proxy_url}/web/asolr" ],
    ;
    push @ProxyPassReverse,
        [ "/popbio-map/web/asolr ${VH::mapveu_proxy_url}/web/asolr" ],
    ;
  }
  # otherwise, proxy the whole thing
  else {
    push @ProxyPass,
        [ "/popbio-map ${VH::mapveu_proxy_url}" ],
    ;
    push @ProxyPassReverse,
        [ "/popbio-map ${VH::mapveu_proxy_url}" ],
    ;
  }


}

1;
