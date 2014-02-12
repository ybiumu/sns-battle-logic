package Anothark::TextFilter;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );

our @PATTARN = (
    '0[1-9]\d{8,9}',
    '.+@[^\.]+\.[^\.]+',
);

my $status = undef;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    return $self;
}


sub optimize
{
    my $class = shift;
    my $text  = shift;
    $text =~ s/&/&amp;/go;
    $text =~ s/\"/&quot;/go;
    $text =~ s/>/&gt;/go;
    $text =~ s/</&lt;/go;
    return $text;

}

sub match
{
    my $class = shift;
    my $string = shift;
    if ( grep {$string =~ /$_/ } @PATTARN )
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

sub setStatus
{
    my $class = shift;
    return $class->setAttribute( 'status', shift );
}

sub getStatus
{
    return $_[0]->getAttribute( 'status' );
}



1;
