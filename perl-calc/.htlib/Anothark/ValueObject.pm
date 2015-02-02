package Anothark::ValueObject;
#
# ˆ¤
#
$|=1;
use strict;


use LoggingObjMethod;
use base qw( LoggingObjMethod );

my $max_value = undef;
my $current_value = undef;
my $stack_values = undef;
sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
#    $self->init();

    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setMaxValue(0);
    $class->setStackValues(0);
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


sub addMax
{
    my $class = shift;
    return $class->setMaxValue( $class->getMaxValue() + shift );
}

sub setCurrentValue
{
    my $class = shift;
    my $value = shift;
    $class->addStackValues( $value );
    return $class->setAttribute( 'current_value', $value );
}

sub setCurrentValueWithoutStack
{
    my $class = shift;
    my $value = shift;
    return $class->setAttribute( 'current_value', $value );
}



sub addCurrent
{
    my $class = shift;
    return $class->setCurrentValue( $class->getCurrentValue() + shift );
}

sub getCurrentValue
{
    return $_[0]->getAttribute( 'current_value' );
}


sub setStackValues
{
    my $class = shift;
    return $class->setAttribute( 'stack_values', shift );
}

sub getStackValues
{
    return $_[0]->getAttribute( 'stack_values' );
}

sub addStackValues
{
    my $class = shift;
    return $class->setStackValues( $class->getStackValues() + shift );
}
sub addBoth
{
    my $class = shift;
    my $value = shift;
    $class->addMax($value);
    $class->addCurrent($value);
}

# Synonim
sub current
{
    return $_[0]->getCurrentValue();
}

sub cv
{
    return $_[0]->current();
}

sub max
{
    return $_[0]->getMaxValue();
}

sub mv
{
    return $_[0]->max();
}

1;
