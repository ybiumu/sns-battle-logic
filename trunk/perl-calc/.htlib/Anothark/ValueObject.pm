package Anothark::ValueObject;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

my $max_value = undef;
my $current_value = undef;
sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->init();

    return $self;
}

sub init
{
    my $class = shift;
    $class->setMaxValue(0);
    $class->setCurrentValue(0);
}

sub setBothValue
{
    my $class = shift;
    return $class->setCurrentValue( $class->setMaxValue( shift ) );
}


sub setMaxValue
{
    my $class = shift;
    return $class->setAttribute( 'max_value', shift );
}

sub getMaxValue
{
    return $_[0]->getAttribute( 'max_value' );
}



sub setCurrentValue
{
    my $class = shift;
    return $class->setAttribute( 'current_value', shift );
}

sub getCurrentValue
{
    return $_[0]->getAttribute( 'current_value' );
}

# Synonim
sub current
{
    return $_[0]->getCurrentValue();
}

sub max
{
    return $_[0]->getMaxValue();
}

1;
