#
# Alter configurations set earlier, e.g. in
# ApiCommonWebsite.pm and QaAuth.pm, to publish the site
# for public use.
#
# Obviously, this module need to be used after the Perl
# configuration modules whose settings it overrides.

$Apache2::PerlSections::Save = 1;

# Override the allowed authorized users set in QaAuth.pm .
# This is an override, not additive. You must list all users
# who are authorized. For example,
#    <Perl>
#       require 'conf/lib/Publish.pm';
#       setAuthUsers(['plasmoqa', 'apidb']);
#    </Perl>
#
sub setAuthUsers {
  local $users = shift;
  $Location{'/'} = {
    TKTAuthToken => $users
  }; 
}

# Allow access to the site without requiring a password,
# except for administrative URLs like /dashboard.
# For example,
#    <Perl>
#       require 'conf/lib/Publish.pm';
#       removePassword();
#    </Perl>
#
sub removePassword {
  $LocationMatch{'^/(?!cgi-bin/admin|dashboard)'} = {
    Allow => 'from all'
  };
  # Release stage should always be a production level if
  # no password is required. 
  set_website_release_stage(lookupStageValue('WEBSITE_RELEASE_STAGE_WWW'));
}

# Set the WEBSITE_RELEASE_STAGE environment variable; typically to
# indicate 'production' or 'development' so applications can
# behave accordingly. This var is originally set in ApiCommonWebsite.pm
# and by default can be changed dynamically by the client.
#
# Calling this method prevents this dynamic change.
# This is desireable as it allows us to lock the stage for public sites.
#
# This release stage lock takes advantage of a quirk?/feature? in the 
# Apache configuration engine whereby variables assigned through 
# SetEnv, which set_website_release_stage() uses, are not altered by 
# SetEnvIf statements used for dynamic settings. This could change in 
# future releases of Apache HTTPD server so we may have to adjust our 
# configuration generation accordingly.
#
# Example usage
#    <Perl>
#       require 'conf/lib/Publish.pm';
#       set_website_release_stage('${WEBSITE_RELEASE_STAGE_QA}');
#    </Perl>
#
# Note this example uses Perl syntax. The '${WEBSITE_RELEASE_STAGE_QA}' 
# is passed as a literal string (so use single-quotes!) to the Apache 
# configuration engine. The Apache configuration engine expands it as 
# an environment variable. 
# The stages are defined in /etc/sysconfig/httpd .
#
sub set_website_release_stage {
  local $stage = shift;
  push @SetEnv, [[ 'WEBSITE_RELEASE_STAGE' => $stage ]];
}

# The stages are defined in /etc/sysconfig/httpd .
# but the environment variables seem to not be set at the
# time of this configuration stage. So parse the file ourselves.
sub lookupStageValue {
  my ($stage) = @_;
  if (! open (SCONF,  '/etc/sysconfig/httpd')) {
    warn 'could not open /etc/sysconfig/httpd';
    return '1001';
  }
  while (<SCONF>) {
    chomp;
    my ($key, $value) = /(?:export\s+)?(.+)=(.*)/;
    next unless defined $key;
    return $value if ($key eq $stage);
  }    
  return '1000';
}
1;
