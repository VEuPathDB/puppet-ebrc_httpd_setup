## dataExplorer specific configuration.
## Note the filename is ClinEpiDB.pm. This is because this file is resolved by $VH::Site variable and that looks
## at /var/www/SITE_NAME. We still use the ClinEpiDB.pm tomcat instance so we need the keep the name as well.

## These would be needed in all lifecycles (dev,prod,beta etc.) so we add them there instead of the vhost files.

# redirects for analysis (RM 46574) & https://epvb.slack.com/archives/C09PEN9N3QE/p1781177669180599
push @RewriteRule, ['^/analysis/(.{7})', "/$VH::Webapp/app/workspace/analyses/\$1/import", '[R,L]'];

# https://epvb.slack.com/archives/CBDP82CSU/p1780927079724089
push @RewriteRule, ["^/$VH::Webapp/app/record/userdataset/(EDAUD_[^/]+)\$", "/$VH::Webapp/app/workspace/analyses/\$1/new/details", '[R=302,L]'];


1;