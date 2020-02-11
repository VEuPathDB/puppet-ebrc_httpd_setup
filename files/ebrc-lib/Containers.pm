# this function sets proxypass config for local containerized services
#
# It takes an argument for 'stage' which is dev,qa,prod and sets the values
# accordingly. 
#
# It is used by callers like this:
#
# <Perl>
#   require 'conf/lib/Containers.pm';
#   set_container_proxies('dev');
# </Perl>
#
# Note that the first call of this function wins - subsequent calls do not
# change the proxies
#


sub set_container_proxies {

  my $stage = shift;
  chomp($stage);

#---------------------------------------------------------------------#
#        define urls per stage                                        #
#---------------------------------------------------------------------#
  
  if ($stage eq "dev") {
      $VH::site_search_proxy_url = "https://site-search.local.apidb.org:8443";
      $VH::mapveu_proxy_url      = "https://mapveu.local.apidb.org:8443";
  }

  if ($stage eq "qa") {
      $VH::site_search_proxy_url = "https://site-search-qa.local.apidb.org:8443";
      $VH::mapveu_proxy_url      = "https://mapveu-qa.local.apidb.org:8443";
  }

#---------------------------------------------------------------------#
#        set for all proxies                                          #
#---------------------------------------------------------------------#
  
  $SSLProxyEngine = 'on';
  $ProxyPreserveHost = 'off';

#---------------------------------------------------------------------#
#        SiteSearch proxy                                             #
#---------------------------------------------------------------------#
  
  push @ProxyPass,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;


#---------------------------------------------------------------------#
#        MapVEu proxy                                                 #
#---------------------------------------------------------------------#
  
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
