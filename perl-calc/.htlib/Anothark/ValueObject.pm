package Anothark::ValueObject;
#
# ˆ¤
#
$|=1;
use strict;
use LoggingObjMethod;
use base qw( LoggingObjMethod );



=pod

*** Member

* MaxValue
* InitValue
* CurrentValue
* StackValues

*** Actions
- add
- rewind

=cut



my $max_value = undef;
my $current_value = undef;
my $stack_values = undef;
my $total_stack_values = undef;
my $init_value = undef;


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
    $class->setCurrentValue(0);
    $class->setStackValues(0);
    $class->setTotalStackValues(0);
    $class->setInitValue(0);
}

# Use only init timing.
sub setBothValue
{
    my $class = shift;
    return $class->initCurrentValue( $class->setMaxValue( shift ) );
}


##############
# MaxValue
##############
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

##############
# CurrentValue
##############
sub initCurrentValue
{
    my $class = shift;
    my $value = shift;
    return $class->setAttribute( 'current_value', $value );
}

sub setCurrentValue
{
    my $class = shift;
    my $value = shift;
    $class->addStackValues( $value - $class->getCurrentValue() );
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
    my $value = shift;
    return $class->setCurrentValue( $class->getCurrentValue() + $value );
}

sub getCurrentValue
{
    return $_[0]->getAttribute( 'current_value' );
}

#
# "¡‰ñ‚Ì"•Ï‰»‚Ì—ÝÏ’l
# I—¹ˆ—Žž‚Étotal_stack_values‚É’Ç‰Á
#
#
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


#
#
# ‹CŠÇ“à‘S‚Ä‚Ì•Ï‰»‚Ì—ÝÏ’l
# a_* ‚ÉŠi”[
#
sub setTotalStackValues
{
    my $class = shift;
    return $class->setAttribute( 'total_stack_values', shift );
}

sub getTotalStackValues
{
    return $_[0]->getAttribute( 'total_stack_values' );
}

sub addTotalStackValues
{
    my $class = shift;
    return $class->setTotlaStackValues( $class->getTotalStackValues() + shift );
}

sub fixTotalStackValues
{
    my $class = shift;
    return $class->addTotalStackValues( $class->getStackValues() );
}


sub mergeTotalStackValues
{
    my $class = shift;
    $class->initCurrentValue( $class->getCurrentValue() + $class->getTotalStackValues() );
}


##################
#
# member
# InitValue
#
##################
sub setInitValue
{
    my $class = shift;
    return $class->setAttribute( 'init_value', shift );
}

sub getInitValue
{
    return $_[0]->getAttribute( 'init_value' );
}





sub addBoth
{
    my $class = shift;
    my $value = shift;
    $class->addMax($value);
    $class->addCurrent($value);
}

# action method
# •t—^
sub add
{
    $_[0]->addBoth($_[1]);
}

# ‰ñ•œ
sub rewind
{
    $_[0]->addCurrent($_[1]);
}

# Œ³‚É–ß‚·
sub clear
{
    $_[0]->setCurrent( $_[0]->getInitValue() );
    $_[0]->setStackValues(0);
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

sub stack
{
    return $_[0]->getStackValues();
}


sub getInit
{
    return $_[0]->getInitValue();
}
1;
