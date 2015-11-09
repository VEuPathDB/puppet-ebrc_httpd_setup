#  ApiDB.org site-specific configurations. Apply to all virual hosts
#  under /var/www/EuPathDB

#---------------------------------------------------------------------#
#          /workshop                                                  #
#---------------------------------------------------------------------#
push @Alias, 
    ['/workshop' => "/var/www/EuPathDB/Common/html/workshops"],
    ['/workshops' => "/var/www/EuPathDB/Common/html/workshops"],
;

#---------------------------------------------------------------------#
#          /tutorials                                                 #
#---------------------------------------------------------------------#
push @Alias,
     ['/tutorials' => '/var/www/Common/apiSiteFilesMirror/tutorials'],
;

#---------------------------------------------------------------------#
# SynView url http://www.apidb.org/apps/SynView/ is published in
# Wang et al.: SynView: a GBrowse-compatible approach to visualizing comparative
# genome data. Bioinformatics 22(18):2308-2309, 2006).
#---------------------------------------------------------------------#
push @RewriteRule,
   [ '/apps/SynView(.*)', '/common/SynView$1', '[P]'];

# UniProtKB links to portal, portal redirects to component.
# http://eupathdb.org/PlasmoDB/gene/PF11_0344 -> http://plasmodb.org/gene/PF11_0344
# (^/gene/.+ is itself a RewriteRule in the component sites)
# Established per December 12, 2009 email "Forwarding eupathdb gene pages to component sites"
push @RewriteMap, [ 'lowercase', 'int:tolower' ];
push @RewriteRule, 
    [ '^/(.+)/(gene/.+)$',  'http://${lowercase:$1}.org/$2', '[R,L,QSA,NE]' ];

1; # return 1 required
