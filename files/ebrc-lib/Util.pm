# $Id$
# $URL$

sub getTomcatProps {
    my ($workerprop) = @_;
    my $TC_PROPS = {};

    open (PROP, $workerprop);
    while (<PROP>) {
        chomp;
        next unless m/^\s*instance\.(\w+)\.(\w+)\s*=\s*(\w+)/;
        $TC_PROPS->{$1}->{$2} = $3;
    }

   return $TC_PROPS;
}


1;
