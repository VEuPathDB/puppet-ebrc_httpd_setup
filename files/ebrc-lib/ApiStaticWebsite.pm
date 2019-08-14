#!/usr/bin/perl

# Common configuration for a non-Tomcat website.
# This module is 'required' by 
# individual virtual host configurations.
# This file should be server neutral - usable on any machine. 

use Apache2::Module;
use Apache2::PerlSections;

BEGIN {
    require 'conf/lib/ServerNameInit.pm';
}

return 1 unless ($VH::ServerName);

my $s = Apache2::PerlSections->server();

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

#---------------------------------------------------------------------#
#          SSLEngine                                                  #
#---------------------------------------------------------------------#

if ($s->port() == '443') {
  $SSLEngine = 'on';
  $SSLHonorCipherOrder = 'on';
  $SSLCompression = 'off';
  # See below for note on SSLProtocol and SSLCipherSuite

  # $SSLCertificate variables set here can not be directly overridden in
  # the virtual host configuration, so if you must override them use the
  # following variables in <Perl> sections of the virtual host config.
  # Certificate directives must be overridden as a complete set
  #   <Perl>
  #     $VH::SSLCertificateFile = '/path/cert.pem';
  #     $VH::SSLCertificateKeyFile = '/path/key.pem';
  #     (optional) $VH::SSLCertificateChainFile = '/path/chain.pem';
  #   </Perl>
  # These must be defined before this module is called.
  #
  $VH::wildcard_cert_base = "/etc/acme/apidb.org";
  if ($VH::SSLCertificateFile) {
    $SSLCertificateFile = $VH::SSLCertificateFile;
    $SSLCertificateKeyFile = $VH::SSLCertificateKeyFile;
    $SSLCertificateChainFile = $VH::SSLCertificateChainFile if ($VH::SSLCertificateChainFile);
  } elsif (-f "${VH::wildcard_cert_base}/cert.pem" ) {
    $SSLCertificateFile = "${VH::wildcard_cert_base}/cert.pem";
    $SSLCertificateKeyFile = "${VH::wildcard_cert_base}/cert.key";
    $SSLCertificateChainFile = "${VH::wildcard_cert_base}/chain.pem";
  } else {
    $SSLCertificateFile = "/etc/pki/tls/certs/localhost.crt";
    $SSLCertificateKeyFile =  "/etc/pki/tls/private/localhost.key";
  }

  # We do not set SSLProtocol or SSLCipherSuite here. That's set
  # in /etc/httpd/conf.d/ssl.conf.
  # As of httpd 2.4.6, there's a bug such that SSLProtocol is inherited
  # from the first vhost and can not be overridden in subsequent vhosts
  # (https://bz.apache.org/bugzilla/show_bug.cgi?id=55707). SSLCipherSuite
  # can be set per vhost but I can only get that to work by setting static
  # "SSLCipherSuite ECDHE-ECDSA-..." directives; I have been unable to get
  # that to work reliably in PerlSections. "$SSLCipherSuite = ... " sort
  # of works but is prone to failure if the suite string is more than 190
  # characters. Neither $s->add_config() not 'push @PerlConfig' syntaxes
  # work for me, I believe also due to the character length limitation
  # that causes silent failures.

} # if port 443


return 1;
