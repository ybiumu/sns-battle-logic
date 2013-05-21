package Anothark::Battle::PetValue;
$|=1;
use strict;


use ObjMethod;
use base qw( ObjMethod );

use constant CALC_FORMAT => "%.2f";
#use constant CALC_FORMAT => "%s";
use constant RANGE_MAP => {
    short  => 1.0,
    middle => 0.9,
    long   => 0.8
};

use constant LEVELS => [0,1,2,3,4,5,6,7,8,9,10];
use constant LEVEL_MAP => {
    fast   => [ 1, 1.19, 1.36, 1.51, 1.64, 1.75, 1.84, 1.91, 1.96, 1.99, 2 ],
    normal => [ 1, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2 ],
    slow   => [ 1, 1.01, 1.04, 1.09, 1.16, 1.25, 1.36, 1.49, 1.64, 1.81, 2 ],
};

use constant RAND_ALIAS => { a => 0, b => 5, c => 10, d => 25, e => 50, f => 100};
use constant RAND_MAP => {
    0  => [0],
    5 => [
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5
          ],
    10 => [
            -10,-9,-8,-7,-6,
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9,10
          ],
    20 => [
            -20,-19,-18,-17,-16,
            -15,-14,-13,-12,-11,
            -10,-9,-8,-7,-6,
            -5, -4,-3,-2,-1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9,10,
            11,12,13,14,15,
            16,17,18,19,20
          ],
    25 => [
            -25, -24,-23, -22,-21,
            -20, -19,-18, -17,-16,
            -15, -14,-13, -12,-11,
            -10,  -9, -8,  -7,-6,
            -5,   -4, -3,  -2,-1,
            0,
            1,  2,  3,  4,  5,
            6,  7,  8,  9,  10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25,
          ],
    50 => [
            -50, -49, -48, -47, -46,
            -45, -44, -43, -42, -41,
            -40, -39, -38, -37, -36,
            -35, -34, -33, -32, -31,
            -30, -29, -28, -27, -26,
            -25, -24, -23, -22, -21,
            -20, -19, -18, -17, -16,
            -15, -14, -13, -12, -11,
            -10, -9, -8, -7, -6,
            -5, -4, -3, -2, -1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9, 10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25,
            26, 27, 28, 29, 30,
            31, 32, 33, 34, 35,
            36, 37, 38, 39, 40,
            41, 42, 43, 44, 45,
            46, 47, 48, 49, 50,
           ],
    100 => [
            -100, -99, -98, -97, -96,
            -95, -94, -93, -92, -91,
            -90, -89, -88, -87, -86,
            -85, -84, -83, -82, -81,
            -80, -79, -78, -77, -76,
            -75, -74, -73, -72, -71,
            -70, -69, -68, -67, -66,
            -65, -64, -63, -62, -61,
            -60, -59, -58, -57, -56,
            -55, -54, -53, -52, -51,
            -50, -49, -48, -47, -46,
            -45, -44, -43, -42, -41,
            -40, -39, -38, -37, -36,
            -35, -34, -33, -32, -31,
            -30, -29, -28, -27, -26,
            -25, -24, -23, -22, -21,
            -20, -19, -18, -17, -16,
            -15, -14, -13, -12, -11,
            -10, -9, -8, -7, -6,
            -5, -4, -3, -2, -1,
            0,
            1, 2, 3, 4, 5,
            6, 7, 8, 9, 10,
            11, 12, 13, 14, 15,
            16, 17, 18, 19, 20,
            21, 22, 23, 24, 25,
            26, 27, 28, 29, 30,
            31, 32, 33, 34, 35,
            36, 37, 38, 39, 40,
            41, 42, 43, 44, 45,
            46, 47, 48, 49, 50,
            51, 52, 53, 54, 55,
            56, 57, 58, 59, 60,
            61, 62, 63, 64, 65,
            66, 67, 68, 69, 70,
            71, 72, 73, 74, 75,
            76, 77, 78, 79, 80,
            81, 82, 83, 84, 85,
            86, 87, 88, 89, 90,
            91, 92, 93, 94, 95,
            96, 97, 98, 99, 100,
        ],
};


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
    $class->setPs(0);
    $class->setSr(0);
    $class->setLv(0);#new!
    $class->setLvType("normal");#new!
    $class->setTired(0);#new!
    $class->setMainExpr(0);
    $class->setSubExpr(0);
    $class->setExprType(0);
    $class->setRange(1.0);
    $class->setRand(0);
}


sub calc
{
    my $class = shift;
#    return sprintf(CALC_FORMAT, $class->getPs() / 100 * $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMap());
    return sprintf(CALC_FORMAT, $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMap());
}

sub calc_center
{
    my $class = shift;
#    return sprintf(CALC_FORMAT, $class->getPs() / 100 * $class->getSr() * $class->getExpRate() * $class->getRange() );
    return sprintf(CALC_FORMAT, $class->getSr() * $class->getExpRate() * $class->getRange() );
}

sub calc_max
{
    my $class = shift;
#    return sprintf(CALC_FORMAT, $class->getPs() / 100 * $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMax());
    return sprintf(CALC_FORMAT, $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMax());
}

sub calc_min
{
    my $class = shift;
#    return sprintf(CALC_FORMAT, $class->getPs() / 100  * $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMin());
    return sprintf(CALC_FORMAT,  $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandMin());
}

sub calc_target
{
    my $class = shift;
    my $rv    = shift;
#    my $value = sprintf(CALC_FORMAT, $class->getPs() / 100 * $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandTarget($rv) ) ;
    my $value = sprintf(CALC_FORMAT, $class->getSr() * $class->getExpRate() * $class->getRange() * $class->getRandTarget($rv) ) ;
#    warn "[result] $rv / $value";
    return $value;
}



sub setTired
{
    my $class = shift;
    return $class->setAttribute( 'tired', shift );
}

sub getTired
{
    return $_[0]->getAttribute( 'tired' );
}




sub setLv
{
    my $class = shift;
    return $class->setAttribute( 'lv', shift );
}

sub getLv
{
    return $_[0]->getAttribute( 'lv' );
}


sub setLvType
{
    my $class = shift;
    return $class->setAttribute( 'lv_type', shift );
}

sub getLvType
{
    return $_[0]->getAttribute( 'lv_type' );
}


sub getLvRate
{
    my $class = shift;
    return @{LEVEL_MAP->{$class->getLvType()}}[$class->getLv()];
}


sub getExpRate
{
    my $class = shift;
    my $exp_rate = 1;
    $exp_rate = ($class->getPs() / 100 ) * $class->getLvRate() * ( (100 - $class->getTired() ) /100 );
#    my $type = $class->getExprType();
#    if ( $type == 1 )
#    {
#        $exp_rate = sqrt(($class->getMainExpr()+100)/100);
#    }
#    elsif( $type == 2 || $type == 4 )
#    {
#        $exp_rate = sqrt( ( 2*$class->getMainExpr() + $class->getSubExpr() + 200) / 200 );
#    }
#    elsif( $type == 3 )
#    {
#        $exp_rate = sqrt( ( ($class->getMainExpr()+$class->getSubExpr())*3 + 400) / 400 );
#    }
#    warn "[EXP_RATE] $exp_rate";
#    return sprintf("%s", $exp_rate);
    return sprintf("%.2f", $exp_rate);
}

sub getRandMap
{
    my $class = shift;
    return (100 + @{RAND_MAP->{$class->getRand()}}[int(rand(($class->getRand()*2+1)))]) / 100;
}

sub getRandMax
{
    my $class = shift;
    return (100 + @{RAND_MAP->{$class->getRand()}}[-1]) / 100;
}


sub getRandMin
{
    my $class = shift;
    return (100 + @{RAND_MAP->{$class->getRand()}}[0]) / 100;
}

sub getRandTarget
{
    my $class = shift;
    my $rv    = shift;
    my $value = (100 + ( $rv )) / 100;
#    my $value =  1 + ( ( $rv ) / 100 );
#    warn "[VALUE]: $rv / $value";
    return $value;
}


sub setPs
{
    my $class = shift;
    return $class->setAttribute( 'ps', shift );
}

sub getPs
{
    return $_[0]->getAttribute( 'ps' );
}

sub setSr
{
    my $class = shift;
    return $class->setAttribute( 'sr', shift );
}

sub getSr
{
    return $_[0]->getAttribute( 'sr' );
}

sub setMainExpr
{
    my $class = shift;
    return $class->setAttribute( 'main_expr', shift );
}

sub getMainExpr
{
    return $_[0]->getAttribute( 'main_expr' );
}



sub setSubExpr
{
    my $class = shift;
    return $class->setAttribute( 'sub_expr', shift );
}

sub getSubExpr
{
    return $_[0]->getAttribute( 'sub_expr' );
}



sub setRange
{
    my $class = shift;
    return $class->setAttribute( 'range', shift );
}

sub getRange
{
    return $_[0]->getAttribute( 'range' );
}



sub setRand
{
    my $class = shift;
    return $class->setAttribute( 'rand', shift );
}

sub getRand
{
    return $_[0]->getAttribute( 'rand' );
}

sub setExprType
{
    my $class = shift;
    return $class->setAttribute( 'expr_type', shift );
}

sub getExprType
{
    return $_[0]->getAttribute( 'expr_type' );
}


1;
