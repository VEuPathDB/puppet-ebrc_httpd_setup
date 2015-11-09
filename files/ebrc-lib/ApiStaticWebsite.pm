#!/usr/bin/perl

# Common configuration for a non-Tomcat website.
# This module is 'required' by 
# individual virtual host configurations.
# This file should be server neutral - usable on any machine. 


BEGIN {
    require 'conf/lib/ServerNameInit.pm';
}

return 1 unless ($VH::ServerName);

if (defined $VH::DISABLED) {
    $Redirect = '503 /';
    $VH::DISABLED =~ s/\$([\w:]+)/${$1}/eg;
    push @ErrorDocument, "503 '$VH::DISABLED'";
    return 1;
}

#---------------------------------------------------------------------#
#         Misc                                                        #
#---------------------------------------------------------------------#
$DocumentRoot   = "/var/www/$VH::ServerName/html";
$DirectoryIndex = "index.html index.shtml index.php home.html home.shtml home.php";
$ServerAdmin    = 'help@eupathdb.org';

push @Include, [ qw(conf/lib/MimeTypes.conf) ];

#---------------------------------------------------------------------#
#          / (DocumentRoot)                                           #
#---------------------------------------------------------------------#
$Directory{$DocumentRoot} = {
    Options        => [qw( Includes FollowSymLinks )],
    AllowOverride  => [qw( Limit AuthConfig Options FileInfo )],
 };

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
#          /cgi-bin                                                   #
#---------------------------------------------------------------------#
push @ScriptAlias, 
    ['/cgi-bin/' => "/var/www/$VH::ServerName/cgi-bin/"],
;
$Directory{"/var/www/$VH::ServerName/cgi-bin"} = {
    AllowOverride   => 'None',
    Options         => [qw(ExecCGI Includes)],
    SetOutputFilter => 'Includes',
    Order => 'allow,deny',
    Allow => 'from all',
};

#---------------------------------------------------------------------#
#          Logging                                                    #
#---------------------------------------------------------------------#
mkdir ('/var/log/httpd/' . $ServerName) if (!-e '/var/log/httpd/' . $ServerName);

$ErrorLog = "/var/log/httpd/$VH::ServerName/error_log";

my $log_dir = "/var/log/httpd/$VH::ServerName";
push @CustomLog, [ 
    [ 
        qq($log_dir/access_log), 
        q(combined),  
        q(env=!self)
    ],
];


return 1;