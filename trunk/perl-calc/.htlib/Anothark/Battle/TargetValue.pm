package Anothark::Battle::TargetValue;
$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );

use constant CONCENT_TYPE => {
    normal  => 0,
    gun     => 1,
    high_c  => 2,
    high_c2 => 3,
    high_c3 => 4,
};

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    return $self;
}

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setConcent(0);
    $class->setPlaceVal(0);
    $class->setPlaceVector(1);
    $class->setChain(1);
}


sub calc
{
    my $class = shift;
    return sprintf("%.3f", $class->getConcentRate() * $class->getPlacePower() * $class->getChainRate() );
}



sub setConcentType
{
    my $class = shift;
    return $class->setAttribute( 'concent_type', shift );
}

sub getConcentType
{
    return $_[0]->getAttribute( 'concent_type' );
}


sub getConcentRate
{
    my $class = shift;
    my $concent = 0;
    my $base_concent = 0;
    my $concent_type = $class->getConcentType();
    if ( $concent_type eq CONCENT_TYPE->{high_c})
    {
        $base_concent = $class->getConcent();
        if ( $base_concent <= 100 )
        {
            $concent = ($base_concent**2+(300*$base_concent)+20000) / 20000 ;
        }
        else
        {
            $concent = ($base_concent*3+(200*1.5))/ 200 ;
        }
    }
    elsif ( $concent_type eq CONCENT_TYPE->{gun} )
    {
        $base_concent = ($class->getConcent() < 100 ? $class->getConcent() : 100);
        $concent = ($base_concent**2+(350*$base_concent)+30000) / 30000 ;
    }
    else
    {
        $base_concent = ($class->getConcent() < 100 ? $class->getConcent() : 100);
#        $concent = (int($base_concent/5)*5+200) / 200 ;
        $concent = ($base_concent+200) / 200 ;
    }
    return $concent ;
}

sub getPlacePower
{
    my $class = shift;
    return ( 1 + (int($class->getPlaceVal() - 0.5)/100)*$class->getPlaceVector() );
}

sub getChainRate
{
    my $class = shift;
    return ($class->getChain()+1)/2;
}


sub setPlaceVector
{
    my $class = shift;
    return $class->setAttribute( 'place_vector', shift );
}

sub getPlaceVector
{
    return $_[0]->getAttribute( 'place_vector' );
}



sub setConcent
{
    my $class = shift;
    return $class->setAttribute( 'concent', shift );
}

sub getConcent
{
    return $_[0]->getAttribute( 'concent' );
}

sub setChain
{
    my $class = shift;
    return $class->setAttribute( 'chain', shift );
}

sub getChain
{
    return $_[0]->getAttribute( 'chain' );
}


sub setPlaceVal
{
    my $class = shift;
    return $class->setAttribute( 'place_val', shift );
}

sub getPlaceVal
{
    return $_[0]->getAttribute( 'place_val' );
}



1;
