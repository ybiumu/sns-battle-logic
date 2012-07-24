package CGISecure;
$|=1;
use strict;
use Secure;

sub new
{
    my $class = shift;
    my $self = { cgi => shift };
    bless $self, $class;
    return $self;
}



sub param
{
    my $class = shift;
    my $key   = shift;
    return Secure::sanitize($class->{cgi}->param($key));
}

sub param_def
{
    my $class = shift;
    my $key   = shift;
    my $def   = shift;
    my $value =  $class->param($key);
    return ( defined $value ? $value : $def) ;
}

1;
