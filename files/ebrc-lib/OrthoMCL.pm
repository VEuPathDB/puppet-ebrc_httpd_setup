# Short-form URLs
# https://redmine.apidb.org/issues/14291
push @PerlConfig, qq| RewriteRule ^/group/(.+)  /orthomcl/showRecord.do?name=GroupRecordClasses.GroupRecordClass&group_name=\$1 [R,L] |;
push @PerlConfig, qq| RewriteRule ^/sequence/(.+)\\\|(.+)  /orthomcl/showRecord.do?name=SequenceRecordClasses.SequenceRecordClass&full_id=\$1\|\$2 [R,L] |;

# old Perl-based site legacy
# https://redmine.apidb.org/issues/14290
push @PerlConfig, qq| RewriteCond %{QUERY_STRING} rm=sequenceList&groupac=(.+) |;
push @PerlConfig, qq| RewriteRule ^/cgi-bin/OrthoMclWeb.cgi /group/%1 [R,L] |;
push @PerlConfig, qq| RewriteCond %{QUERY_STRING} rm=sequence&accession=(.+)&taxon=(.+) |;
push @PerlConfig, qq| RewriteRule ^/cgi-bin/OrthoMclWeb.cgi /sequence/%2\|%1 [R,L] |;

push @PerlConfig, qq| RewriteRule ^/cgi-bin/OrthoMclWeb.cgi / [R,L] |;


1;
