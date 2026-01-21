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
      $VH::orthosearch_proxy_url = "https://orthosearch-dev.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-dev.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-dev.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-dev.local.apidb.org:8443";
      $VH::cellxgene_proxy_url   = "https://cellxgene-dev.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-dev.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-dev.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-dev.local.apidb.org:8443";
  }

  if ($stage eq "qa") {
      $VH::site_search_proxy_url = "https://sitesearch-qa.local.apidb.org:8443";
      $VH::orthosearch_proxy_url = "https://orthosearch-qa.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-qa.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-qa.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-qa.local.apidb.org:8443";
      $VH::cellxgene_proxy_url   = "https://cellxgene-qa.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-qa.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-qa.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-qa.local.apidb.org:8443";
  }

  if ($stage eq "prod") {
      $VH::site_search_proxy_url = "https://sitesearch-prod.local.apidb.org:8443";
      $VH::orthosearch_proxy_url = "https://orthosearch-prod.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-prod.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-prod.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-prod.local.apidb.org:8443";
      $VH::cellxgene_proxy_url   = "https://cellxgene-prod.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-prod.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-prod.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-prod.local.apidb.org:8443";
  }

  if ($stage eq "feat") {
      $VH::site_search_proxy_url = "https://sitesearch-feat.local.apidb.org:8443";
      $VH::orthosearch_proxy_url = "https://orthosearch-feat.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-feat.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-feat.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-feat.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-feat.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-feat.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-feat.local.apidb.org:8443";
  }

  if ($stage eq "alpha") {
      $VH::site_search_proxy_url = "https://sitesearch-alpha.local.apidb.org:8443";
      $VH::orthosearch_proxy_url = "https://orthosearch-alpha.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-alpha.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-alpha.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-alpha.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-alpha.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-alpha.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-alpha.local.apidb.org:8443";
  }

  if ($stage eq "beta") {
      $VH::site_search_proxy_url = "https://sitesearch-beta.local.apidb.org:8443";
      $VH::orthosearch_proxy_url = "https://orthosearch-beta.local.apidb.org:8443";
      $VH::edasearch_proxy_url   = "https://edasearch-beta.local.apidb.org:8443";
      $VH::mblast_proxy_url      = "https://mblast-beta.local.apidb.org:8443";
      $VH::cellxgene_proxy_url   = "https://cellxgene-beta.local.apidb.org:8443";
      $VH::eda_proxy_url         = "https://eda-beta.local.apidb.org:8443";
      $VH::seqret_proxy_url      = "https://sequenceretrieval-beta.local.apidb.org:8443";
      $VH::vdi_proxy_url         = "https://vdi-beta.local.apidb.org:8443";
      $VH::jbrowse2_proxy_url    = "https://jbrowse2-beta.local.apidb.org:8443";
  }

#---------------------------------------------------------------------#
#        set for all proxies                                          #
#---------------------------------------------------------------------#
  
  $SSLProxyEngine = 'on';

}

#---------------------------------------------------------------------#
#        SiteSearch proxy                                             #
#---------------------------------------------------------------------#

sub set_edasearch_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/site-search"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/site-search ${VH::edasearch_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/site-search ${VH::edasearch_proxy_url}" ],
  ;

}

sub set_orthosearch_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/site-search"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/site-search ${VH::orthosearch_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/site-search ${VH::orthosearch_proxy_url}" ],
  ;

}

sub set_sitesearch_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/site-search"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/site-search ${VH::site_search_proxy_url}" ],
  ;

}

#---------------------------------------------------------------------#
#        Multi-blast Service (mblast) proxy                           #
#---------------------------------------------------------------------#

sub set_mblast_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/multi-blast"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/multi-blast ${VH::mblast_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/multi-blast ${VH::mblast_proxy_url}" ],
  ;

}
#
#---------------------------------------------------------------------#
#        cellxgene gateway Service (cellxgene) proxy                  #
#---------------------------------------------------------------------#

sub set_cellxgene_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/cellxgene"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/cellxgene ${VH::cellxgene_proxy_url}" ],
  ;
  push @ProxyPassReverse,
      [ "/cellxgene ${VH::cellxgene_proxy_url}" ],
  ;

}
#---------------------------------------------------------------------#
#        Exploratory Data Analysis Service (eda) proxy                #
#---------------------------------------------------------------------#

sub set_eda_proxy {

  my $stage = shift;
  set_proxy_urls($stage);

  $Location{"/eda"} = {
     ProxyPreserveHost => 'off',
  };

  push @ProxyPass,
      [ "/eda ${VH::eda_proxy_url} timeout=120" ],
  ;
  push @ProxyPassReverse,
      [ "/eda ${VH::eda_proxy_url} timeout=120" ],
  ;
  push @ProxyPassReverseCookiePath,
      [ "/ /eda"],
  ;

}

#---------------------------------------------------------------------#
#        Sequence Retrieval Service (seqret) proxy                    #
#---------------------------------------------------------------------#

sub set_seqret_proxy {

    my $stage = shift;
    set_proxy_urls($stage);

    $Location{"/sequence-retrieval"} = {
       ProxyPreserveHost => 'off',
    };

    push @ProxyPass,
        [ "/sequence-retrieval ${VH::seqret_proxy_url}" ],
    ;
    push @ProxyPassReverse,
        [ "/sequence-retrieval ${VH::seqret_proxy_url}" ],
    ;

}

#---------------------------------------------------------------------#
#        VEuPathDB Dataset Installer Service (VDI) proxy              #
#---------------------------------------------------------------------#

sub set_vdi_proxy {

    my $stage = shift;
    set_proxy_urls($stage);

    $Location{"/vdi"} = {
       ProxyPreserveHost => 'off',
    };

    push @ProxyPass,
        [ "/vdi ${VH::vdi_proxy_url}" ],
    ;
    push @ProxyPassReverse,
        [ "/vdi ${VH::vdi_proxy_url}" ],
    ;

}

#---------------------------------------------------------------------#
#        VEuPathDB jbrowse2 proxy                                     #
#---------------------------------------------------------------------#

sub set_jbrowse2_proxy {

    my $stage = shift;
    set_proxy_urls($stage);

    $Location{"/jbrowse2"} = {
       ProxyPreserveHost => 'off',
    };

    push @ProxyPass,
        [ "/jbrowse2 ${VH::jbrowse2_proxy_url}" ],
    ;
    push @ProxyPassReverse,
        [ "/jbrowse2 ${VH::jbrowse2_proxy_url}" ],
    ;

}


1;
