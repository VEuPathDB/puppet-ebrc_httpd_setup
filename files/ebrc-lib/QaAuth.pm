$Apache2::PerlSections::Save = 1;

## Cross-site login in.
use Socket qw(inet_ntoa);
# $VH::ServerName is defined in ApiCommonWebsite.pm
my $packed_ip = scalar gethostbyname( $VH::ServerName || 'localhost');
my $server_ip = '127.0.0.1';
if (defined $packed_ip) {
    $server_ip = inet_ntoa($packed_ip);
} else {
    warn "WARNING: unable to get IP address for '$VH::ServerName'. This virtual host will have authentication problems.";
}

# Basic Auth required for whole site
$LocationMatch{'^/'} = {
    AuthName     => qq('$VH::Site Restricted'),
    AuthType     => 'Basic',
    Order        => 'deny,allow',
    Deny         => 'from all',

    # sites proxied through Nginx will receive a X-Forwarded-For header.
    # If the X-Forwarded-For value is an internal server then let it through 
    # unchallenged - it's the site calling itself (e.g. a JSP page importing
    # a CGI script) or inter-project call (portal requesting from component site)
    SetEnvIf => [
        ['X-Forwarded-For', "^$server_ip\$",        "proxied_internal_host"],
        ['X-Forwarded-For', "^127\.0\.0\.",         "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.91\.49\.",       "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.75\.12\$",  "proxied_internal_host"],
#rm16889        ['X-Forwarded-For', "^128\.192\.75\.73\$",  "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.75\.111\$", "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.75\.211\$", "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.75\.16\$",  "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.99\.106\$", "proxied_internal_host"],
        ['X-Forwarded-For', "^128\.192\.99\.13\$",  "proxied_internal_host"],
    ],

    # EuPathDB servers do not require auth.
    Allow => ['from',
        '127.0.0.1'        ,  
        '128.192.99.106'   ,  # neelum.ctegd
        '128.192.99.13'    ,  # mango.ctegd
#rm16889        '128.192.75.73'    ,  # apricot.rcc (Virtual machines)
        '128.192.75.96'    ,  # myrtle.gacrc
        '128.192.75.211'   ,  # luffa.gacrc
        '128.192.75.16'    ,  # santol.gacrc
        '128.192.75.30'    ,  # exocarp.rcc
        '128.91.49.194'    ,  # oak.pcbi
        '128.91.49.190'    ,  # spruce.pcbi
        '128.91.49.191'    ,  # holly.pcbi
        'env=proxied_internal_host' ,  # self routed through reverse proxy
        $server_ip         ,  # self
    ],
   TKTAuthCookieName => 'auth_tkt',

   TKTAuthLoginURL   => 'https://eupathdb.org/auth/bin/autologin',
   TKTAuthTimeoutURL => 'https://eupathdb.org/auth/bin/autologin?timeout=1',
   TKTAuthUnauthURL  => 'https://eupathdb.org/auth/bin/autologin?unauth=1',

   TKTAuthTimeout => '2d',
   
   # if ignore ip is on, login.cgi may need to be edited to set
   # $ip_addr to '0.0.0.0' (don't rely on $at->ignore_ip to be
   # the right thing)
   TKTAuthIgnoreIP => on,
   TKTAuthDebug => 1,

   # 'require username' syntax does not synergize with mod_auth_tkt for
   # restricting per user; if a logged in user hits a page and that user 
   # is not listed in the 'require', apache returns a 401 error and
   # the browser presents a standard basic auth dialog box (mod_auth_tkt 
   # does not get involved). 
   # So, we are using TKTAuthTokens in place of 'require username'. When
   # a user logs in via mod_auth_tkt, a token is set equal to the username.
   # Failure to match a token will trigger mod_auth_tkt to redirect to 
   # TKTAuthUnauthURL. Additional Tokens can be specified in vhost configurations.
   # We also need 'require valid-user'.
   #
   TKTAuthToken => ['apidb'], # an array so vhosts can push additional tokens

   require => 'valid-user',
   Satisfy => 'any',
};

#---------------------------------------------------------------------#
#          mod_auth_tkt login pages                                   #
#  (usually only eupathdb.org needs mod_auth_tkt configuration        #
#   and that uses a static configuration file, so this is             #
#   mostly for dev/testing)                                           #
#---------------------------------------------------------------------#

# unprotect the login pages
$Location{'/auth/bin/'} = { Allow => 'from ALL' };
$Location{'/auth/'} = { Allow => 'from ALL' };

push @ScriptAlias, 
    ['/auth/bin' => "/var/www/Common/mod_auth_tkt/cgi-bin"],
;
$Directory{"/var/www/Common/mod_auth_tkt/cgi-bin"} = {
    AllowOverride   => 'None',
    Options         => [qw(ExecCGI Includes FollowSymLinks)],
    SetOutputFilter => 'Includes',
};

push @Alias, 
    ['/auth' => "/var/www/Common/mod_auth_tkt/html"],
;
$Directory{"/var/www/Common/mod_auth_tkt/html"} = {
    AllowOverride   => 'None',
    Options         => [qw(FollowSymLinks Includes)],
};

#---------------------------------------------------------------------#
#          WebServices                                                #
#---------------------------------------------------------------------#
# I don't know why webservices has its own match instead of just being
# defined by the / root match above. It might have been added to allow 
# looser access to internal development apps.

# WebServices Access without password from selected subnets
$LocationMatch{'^/[^/]+/services'} = { 
    Order        => 'deny,allow',
    Deny         => 'from all',
    Allow        => ['from',
        '128.91.'  ,    # UPenn
        '165.123.' ,    # UPenn
        '128.91.49.',  # UPenn
        '128.192.' ,    # UGA
#       '172.16.31.'  , # UGA LAN - don't do this because nginx proxy will bypass
#rm16889       '172.16.30.'   ,# UGA LAN
        'env=proxied_internal_host' ,  # self routed through reverse proxy
        $server_ip ,    # self
  ]
};

# Give access to the Unauthorized 401 custom error file.
# TODO: move error files to an error directory and open that dir.
$Location{'/401.shtml'} = { Allow => 'from ALL' };
$Location{'/robots.txt'} = { Allow => 'from ALL' };


# Auth doesn't get the client IP when site is proxied through Nginx (it
# gets the proxy's IP) but it can receive a X-Forwarded-For header. If the
# X-Forwarded-For value is for a valid client then set an environment
# variable and use that variable to determine the 'Allow from'. We have to
# repeat the client IPs in 'Allow from's to handle clients bypassing the
# proxy (e.g. accessing w1.apidb.org directly)
@SetEnvIf = [
  ['X-Forwarded-For', "^128\.192\.85\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.253\.",   "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.240\.",   "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.98\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.98\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.99\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.75\.12",  "permitted_proxied_client"],
#16889  ['X-Forwarded-For', "^128\.192\.75\.73",  "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.75\.111", "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.192\.75\.112", "permitted_proxied_client"],
  ['X-Forwarded-For', "^165\.123\.89\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.29\.",     "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.133\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^165\.123\.89\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.49\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.222\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.223\.",    "permitted_proxied_client"],
  ['X-Forwarded-For', "^128\.91\.232\.",    "permitted_proxied_client"],
];

# combining admin and dashboard as
#    $LocationMatch{'^/(admin|dashboard)'} 
# does not work for whatever reason, so making a separate Location.
# This can be removed after the migration to /dashboard is complete
$LocationMatch{'^/admin'} = {
   Options       => 'Indexes',
   Order         => 'deny,allow',
   Deny          => 'from all',
   Allow         => ['from',
      '128.192.99.'  ,
      '128.192.98.'  ,
      '128.192.75.'  ,
      '165.123.89.'  ,
      '128.91.29.'   ,
      '128.91.133.'  ,
      '165.123.89.15',
#      '172.16.31.'   , # UGA LAN - don't do this because nginx proxy will bypass
      '128.192.85.'  , # UGA VPN
      '128.192.253.' , # UGA VPN
      '128.192.240.' , # UGA VPN
      '128.91.222.'  , # lynch wired
      '128.91.223.'  , # lynch wired
      '128.91.232.'  , # lynch wireless
      'env=permitted_proxied_client',
      $server_ip ,    # self
   ],
   Satisfy => 'all',
};

1;

