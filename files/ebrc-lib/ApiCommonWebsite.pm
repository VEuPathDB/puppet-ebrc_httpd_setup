#!/usr/bin/perl

# $Id$
# $URL$
#
# Common configuration for any WDK-based project website. 
# This module is 'required' by 
# individual virtual host configurations.
# This file should be server neutral - usable on any machine. 

use Apache2::Module;

BEGIN {
    require 'conf/lib/ServerNameInit.pm';
}

return 1 unless ($VH::ServerName);

($VH::Webapp, $VH::Site) = fileparse(readlink('/var/www/'. $VH::ServerName));
 $VH::Site =~ s/\/$//;
($VH::WebappNoVer) = $VH::Webapp =~ m/(^[a-zA-Z_]+)/;

if (defined $VH::DISABLED) {
    $Redirect = '503 /';
    $VH::DISABLED =~ s/\$([\w:]+)/${$1}/eg;
    push @ErrorDocument, "503 '$VH::DISABLED'";
    return 1;
}


#---------------------------------------------------------------------#
#        PASSWORD PROTECTION AND OTHER ACCESS CONTROLS                #
#---------------------------------------------------------------------#
        
require 'conf/lib/QaAuth.pm';

$Location{'/WEB-INF/'} = {
  Deny    => 'from all',
  Satisfy => 'all',
};


#---------------------------------------------------------------------#
#          SAFARI SEMICOLON/AUTH WORKAROUND                           #
#---------------------------------------------------------------------#
# Safari does not send Authorization header for request URIs that contain
# a semicolon - such as Struts <c:url> modified urls that contain 
# ;jsessionid. Encoding ';' as '%3B' works around this.
## should investigate using the lower overhead mod_line_edit instead
#push @ExtFilterDefine, q(encode_semicolon 
#                         mode=output 
#                         intype=text/html 
#                         cmd="/bin/sed s/;jsessionid=/%3Bjsessionid=/g"
#                        );

push @SetEnv, [[ 'LineEdit' => 'text/html' ]];
push @LERewriteRule, q(;jsessionid= %3Bjsessionid=);

$Location{"/$VH::Webapp"} = {
    #SetOutputFilter => 'encode_semicolon',  
    SetOutputFilter => 'line-editor',
};

#---------------------------------------------------------------------#
#          Update @INC (for mod_perl)                                 #
#---------------------------------------------------------------------#
use lib "$SVR::server_root/conf/lib";
use lib "/var/www/$VH::ServerName/cgi-lib";
use lib "/var/www/$VH::ServerName/gus_home/lib/perl";


#---------------------------------------------------------------------#
#          Update ENV (for cgi)                                       #
#---------------------------------------------------------------------#
push @SetEnv, [ 
    [ 'GUS_HOME' => "/var/www/$VH::ServerName/gus_home" ], 
    [ 'PERL5LIB' => "/var/www/$VH::ServerName/cgi-lib:/var/www/$VH::ServerName/cgi-lib/gb2:/var/www/$VH::ServerName/gus_home/lib/perl" ], 
    [ 'PROJECT_ID'=> $VH::Site ], 
];

#---------------------------------------------------------------------#
#          Update ENV (for mod_fcgid (fast cgi))                      #
#---------------------------------------------------------------------#

if (Apache2::Module::loaded('mod_fcgid.c')) {
  push @FcgidInitialEnv,
    "ORACLE_HOME	/u01/app/oracle/product/11.2.0.3/db_1",
    "PERL5LIB /var/www/$VH::ServerName/cgi-lib:/var/www/$VH::ServerName/cgi-lib/gb2:/var/www/$VH::ServerName/gus_home/lib/perl",
    "GBROWSE_CONF /var/www/$VH::ServerName/gus_home/lib/gbrowse/",
    "GUS_HOME /var/www/$VH::ServerName/gus_home",
    "PROJECT_ID $VH::Site",
  ;
  $FcgidMinProcessesPerClass  =  0;
  $FcgidMaxProcessesPerClass  =  5;
  $FcgidIdleTimeout           =  60;
  $FcgidProcessLifeTime       =  ($FcgidIdleTimeout * 2);
};

#---------------------------------------------------------------------#
#         Misc                                                        #
#---------------------------------------------------------------------#
$DocumentRoot   = "/var/www/$VH::ServerName/html";
$DirectoryIndex = "home.jsp index.html index.shtml index.jsp index.php";    
$ServerAdmin    = 'mheiges@uga.edu';
push @ErrorDocument, 
                     "401 'The page or file can not be viewed without the correct username/password.'",
                     "404 /404.shtml", 
                     "500 /500.shtml",
                     "503 /500.shtml",
;

# Sequence Retreival Tool (contigSrt) is known to need lots of time.
# Keep the hard limit higher than soft limit, otherwise processes get SIGKILL'd
# instead of a trappable SIGXCPU.
$RLimitCPU = "43200 46800";
# gbrowse is known to sometimes need up to 2 GB.
$RLimitMEM = "2147483648 2147483648";  

push @Include, [ qw(conf/lib/MimeTypes.conf) ];

#---------------------------------------------------------------------#
#          Rewrite Rules                                              #
#---------------------------------------------------------------------#
$RewriteEngine = on;

push @RewriteRule, 
    [ '^/$',  "/$VH::Webapp/", '[R]' ],
    [ '^/siteinfo/xml$', "/siteinfo/index-xml.php", '[P,L,QSA]'],
    [ '^/siteinfo/xml/(.*)', "/siteinfo/index-xml.php/\$1", '[P,L,QSA]'],
    [ '^/gene/(.+)',  "/$VH::Webapp/showRecord.do?name=GeneRecordClasses.GeneRecordClass&primary_key=\$1", '[R,L]' ],
;

# provide uniformly named access to static files (js, css, etc) served by Tomcat
$ProxyPreserveHost = "On";
push @ProxyPass,
    [ "/webservices http://$VH::ServerName/$VH::Webapp/webservices" ],
    [ "/a http://$VH::ServerName/$VH::Webapp" ],
;
push @ProxyPassReverse,
    [ "/webservices http://$VH::ServerName/$VH::Webapp/webservices" ],
    [ "/a http://$VH::ServerName/$VH::Webapp" ],
;

push @Alias, ['/favicon.ico' => "/var/www/$VH::ServerName/html/assets/images/$VH::Site/favicon.ico"];

#---------------------------------------------------------------------#
#          Tomcat Connector                                           #
#---------------------------------------------------------------------#
@JkMount = (
    [ "/$VH::Webapp/*" => "$VH::Site" ],
    [ "/$VH::Webapp"   => "$VH::Site" ],
    [ "/axis/*"        => "$VH::Site" ],
    [ "/axis"          => "$VH::Site" ],
);

push @JkEnvVar, qw(SERVER_ADDR HTTP_ACCEPT_ENCODING);

# convert non-versioned webapp paths to versioned paths
# e.g. http://dev1.apidb.org/apidb/ -> http://dev1.apidb.org/apidb2.1/
# This allows hard-coded live site urls to work in the dev site.
if ($VH::WebappNoVer ne $VH::Webapp) {

  # WSF (Jersey client) needs a 307 status when POSTing so it does not convert second
  # request to GET, which it does with a standard 302 status.
  push @PerlConfig, qq| RewriteCond %{REQUEST_METHOD} POST |;
  push @PerlConfig, qq| RewriteRule ^/+$VH::WebappNoVer/(.*)\$ /$VH::Webapp/\$1 [R=307,QSA,NE] |;
  # For GET and HEAD, use 302. In particular, the HtmlUnit WebClient does not follow 307 
  # redirects for HEAD requests.
  push @PerlConfig, qq| RewriteRule ^/+$VH::WebappNoVer/(.*)\$ /$VH::Webapp/\$1 [R=302,QSA,NE] |;

  # For the record, this is one way to do a RewriteRule when you don't need an associated RewriteCond.
  #push @RewriteRule, 
  #    [ "^/+$VH::WebappNoVer/(.*)\$", "/$VH::Webapp/\$1", '[R,QSA,NE]'],
  #;

}

# env vars for /dashboard
push @SetEnv, [
    [ 'TOMCAT_INSTANCE' => $VH::Site ],
    [ 'CONTEXT_PATH' => "/$VH::Webapp" ],
];

#---------------------------------------------------------------------#
#          Website Release Stage                                      #
#---------------------------------------------------------------------#

push @RewriteRule, 
    [ "(.*)/set_website_release_stage_([^/]+)\$", "/\$1", "[R,L,CO=website_release_stage:\$2:%{HTTP_HOST}]"],
;

push @SetEnvIfNoCase, [
    [
        q(COOKIE),
        q(website_release_stage=([^;]+)),
        q(WEBSITE_RELEASE_STAGE=$1)
    ],
];

# Set default stage if not set earlier.
# WEBSITE_RELEASE_STAGE_* integer values are defined in /etc/sysconfig/httpd 
push @SetEnvIf, [
    [
        q(WEBSITE_RELEASE_STAGE),
        q(^$),
        q(WEBSITE_RELEASE_STAGE=${WEBSITE_RELEASE_STAGE_DEVELOPMENT})
    ],
];

push @JkEnvVar, qw(WEBSITE_RELEASE_STAGE);

#---------------------------------------------------------------------#
#          / (DocumentRoot)                                           #
#---------------------------------------------------------------------#
$Directory{$DocumentRoot} = {
    Options        => [qw( Includes FollowSymLinks )],
    AllowOverride  => [qw( Limit AuthConfig Options FileInfo )],
    DirectoryIndex => [qw(index.html index.shtml index.php)],
 };


#---------------------------------------------------------------------#
#          /cgi-bin                                                   #
#---------------------------------------------------------------------#
push @ScriptAlias, 
    ['/cgi-bin/'  => "/var/www/$VH::ServerName/cgi-bin/"],
    ['/bin/'      => "/var/www/$VH::ServerName/cgi-bin/"],
;
$Directory{"/var/www/$VH::ServerName/cgi-bin"} = {
    AllowOverride   => 'None',
    Options         => [qw(ExecCGI Includes)],
    SetOutputFilter => 'Includes',
    Order           => 'allow,deny',
    Allow           => 'from all',
};

#---------------------------------------------------------------------#
#          /fcgi-bin (fast cgi                                        #
#---------------------------------------------------------------------#

if (Apache2::Module::loaded('mod_fcgid.c')) {
  push @ScriptAlias, 
      ['/fcgi-bin/' => "/var/www/$VH::ServerName/cgi-bin/"],
  ;
  
  $Location{"/fcgi-bin"} = {
      SetHandler      => 'fcgid-script',
      Options         => [qw(ExecCGI Includes)],
      SetOutputFilter => 'Includes',
      Order           => 'allow,deny',
      Allow           => 'from all',
  };
};

#---------------------------------------------------------------------#
#      /common/downloads (allow Indexes) - define before /common      #
#---------------------------------------------------------------------#
push @Alias, 
    ['/common/downloads' => "/var/www/Common/apiSiteFilesMirror/downloadSite/$VH::Site"],
;
$Directory{"/var/www/Common/apiSiteFilesMirror/downloadSite/$VH::Site"} = {
    Options => [qw( Indexes FollowSymLinks Includes MultiViews )],
    IndexOptions => [qw(
        SuppressHTMLPreamble
        FancyIndexing 
        FoldersFirst 
        IgnoreCase
        DescriptionWidth=*        
     )],
     ReadmeName => '/include/fancyIndexFooter.shtml',
     HeaderName => '/include/fancyIndexHeader.shtml',
     
     Include => [ qw(conf/lib/DirectoryFileDescriptions.conf) ],
     IndexIgnore => [qw(.??* *~ *# )],
     AllowOverride => 'Indexes',
     Order => 'allow,deny',
     Allow => 'from all',

};

#---------------------------------------------------------------------#
#      /common/community (allow Indexes) - define before /common      #
#---------------------------------------------------------------------#
push @Alias, 
    ['/common/community' => "/var/www/Common/communityFilesMirror"],
;
$Directory{"/var/www/Common/communityFilesMirror"} = {
    Options => [qw( Indexes FollowSymLinks Includes MultiViews )],
    IndexOptions => [qw(
        SuppressHTMLPreamble
        FancyIndexing 
        FoldersFirst 
        IgnoreCase
        DescriptionWidth=*        
     )],
     ReadmeName => '/include/fancyIndexFooter.shtml',
     HeaderName => '/include/fancyCommunityIndexHeader.shtml',
     
     Include => [ qw(conf/lib/DirectoryFileDescriptions.conf) ],
     IndexIgnore => [qw(.??* *~ *# )],
     AllowOverride => 'None',
     Order => 'allow,deny',
     Allow => 'from all',

};


#---------------------------------------------------------------------#
#          /common                                                    #
#---------------------------------------------------------------------#
push @Alias, 
    ['/common' => "/var/www/Common/apiSiteFilesMirror/auxiliary/$VH::Site"],
;
$Directory{"/var/www/Common/apiSiteFilesMirror/auxiliary/$VH::Site"} = {
    AllowOverride   => 'None',
    Options         => [qw(FollowSymLinks Includes)],
    Order => 'allow,deny',
    Allow => 'from all',
};


#---------------------------------------------------------------------#
#          /common/cgi-bin                                            #
#---------------------------------------------------------------------#
push @ScriptAlias, 
    ['/common-bin' => "/var/www/$VH::Site/Common/cgi-bin"],
;
$Directory{"/var/www/$VH::Site/Common/cgi-bin"} = {
    AllowOverride   => 'None',
    Options         => [qw(ExecCGI Includes)],
    SetOutputFilter => 'Includes',
    Order => 'allow,deny',
    Allow => 'from all',
};


#---------------------------------------------------------------------#
#           RSS feeds                                                 #
#---------------------------------------------------------------------#
push @RewriteRule,   
    [ '/news.rss'              ,    "/$VH::Webapp/showXmlDataContent.do?name=XmlQuestions.NewsRss"         ,    '[PT]'   ],                      
    [ '/events.rss'            ,    "/$VH::Webapp/communityEventsRss.jsp"                                  ,    '[PT]'   ],                      
    [ '/ebrcpresentations.rss'            ,    "/$VH::Webapp/presentationsRss.jsp"                                  ,    '[PT]'   ],                      
    [ '/publications.rss'      ,    "/$VH::Webapp/showXmlDataContent.do?name=XmlQuestions.PublicationsRss" ,    '[PT]'   ],                      
    [ '/releases.rss'          ,    "/$VH::Webapp/showXmlDataContent.do?name=XmlQuestions.ReleasesRss"     ,    '[PT]'   ],                      
    [ '/ebrcnews.rss'          ,    "/$VH::Webapp/aggregateNewsRss.jsp"                    ,    '[PT]'   ], 
    [ '/ebrcevents.rss'        ,    "/$VH::Webapp/communityEventsRss.jsp"                  ,    '[PT]'   ], 
    [ '/ebrcpublications.rss'  ,    "/$VH::Webapp/showXmlDataContent.do?name=XmlQuestions.PublicationsRss",    '[PT]'   ], 
    [ '/ebrcreleases.rss'      ,    "/$VH::Webapp/aggregateReleasesRss.jsp"                ,    '[PT]'   ], 
;

#---------------------------------------------------------------------#
#          /news redirect                                             #
#---------------------------------------------------------------------#
push @RewriteRule, 
    [ '^/news', "/$VH::Webapp/showXmlDataContent.do?name=XmlQuestions.News", '[R]'],
;

#---------------------------------------------------------------------#
#          /icons                                                     #
#---------------------------------------------------------------------#
push @Alias, 
    ['/icons' => "/var/www/icons"],
;
$Directory{"/var/www/icons"} = {
    AllowOverride   => 'None',
    Options         => [qw(MultiViews Indexes)],
    Order => 'allow,deny',
    Allow => 'from all',
};

#---------------------------------------------------------------------#
#          /siteinfo                                                  #
#---------------------------------------------------------------------#

# see QaAuth.pm for /siteinfo

#---------------------------------------------------------------------#
#          /dashboard                                                 #
#---------------------------------------------------------------------#
push @Alias,
    ['/dashboard' => "/var/www/$VH::ServerName/dashboard"]
;
$Directory{"/var/www/$VH::ServerName/dashboard"} = {
    AllowOverride => [qw(AuthConfig FileInfo Indexes Limit Options=All,MultiViews)],
    Options => '+MultiViews',
};

#---------------------------------------------------------------------#
#          Logging                                                    #
#---------------------------------------------------------------------#
mkdir ('/var/log/httpd/' . $ServerName) if (!-e '/var/log/httpd/' . $ServerName);

push @SetEnvIf, [
    [
        q(Remote_Addr),
        q("128\.192\.75\.75"),
        q(self)
    ],
];

$ErrorLog = "/var/log/httpd/$VH::ServerName/error_log";

my $log_dir = "/var/log/httpd/$VH::ServerName";

# Set LogFormat string to use if mod_log_firstbyte is installed.
# (http://code.google.com/p/mod-log-firstbyte/)
my $mod_log_firstbyte = (-e '/etc/httpd/modules/mod_log_firstbyte.so') ? ' %F' : '';

push @LogFormat, [
  [  # combined format plus Response Time, plus mod_first_byte time if module is installed
     qq(\"%h %l %u %t \\"%r\\" %>s %b \\"%{Referer}i\\" \\"%{User-Agent}i\\" %D${mod_log_firstbyte}\"),
     q(combined+rt)
  ],
];

push @CustomLog, [ 
    [ 
        qq($log_dir/access_log), 
        q(combined+rt), 
        q(env=!self)
    ],
    [ 
        qq($log_dir/self_access_log), 
        q(combined+rt),  
        q(env=self)
    ],
];


1;

__END__    
