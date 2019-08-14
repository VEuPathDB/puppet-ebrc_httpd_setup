#  ApiDB.org site-specific configurations. Apply to all virual hosts
#  under /var/www/ApiDB

#---------------------------------------------------------------------#
#          /workshop                                                  #
#---------------------------------------------------------------------#
push @Alias, 
    ['/workshop' => "/var/www/$VH::ServerName/html/static/workshops"],
    ['/workshops' => "/var/www/$VH::ServerName/html/static/workshops"],

;



1; # return 1 required
