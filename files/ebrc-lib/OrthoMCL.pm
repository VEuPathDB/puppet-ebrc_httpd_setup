## ortho specific configuration.
## These would be needed in all lifecycles (dev,prod,beta etc.) so we add them there instead of the vhost files.

#---------------------------------------------------------------------#
#      /common/downloads (allow Indexes) - define before /common      #
#---------------------------------------------------------------------#
# THIS IS REMOVED FROM ALL OTHER SITES AS DOWNLOADS ARE MOVED BEHIND LOGIN AND SERVED BY TOMCAT NOW.
# Ortho has not yet implemented that feature plus we don't require subscriptions for ortho.
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
     IndexIgnore   => [qw(.??* *~ *# )],
     AllowOverride => 'Indexes',
     Require       => 'all granted',
     AddType       => 'application/octet-stream .txt',
};
