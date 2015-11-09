# $Id$
# $URL$
#

$ErrorDocument = "401 /401.shtml";

push @RewriteRule, ['^/gene[/_](.+)$', '/cryptodb/showRecord.do?name=GeneRecordClasses.GeneRecordClass&id=$1', '[N]'];

1;
