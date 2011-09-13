package Ellark::Battle::StatusValue;
$|=1;
use strict;

use ObjMethod;
use base qw( ObjMethod );

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
    $class->setMainRegist(0);
    $class->setSubRegist(0);
    $class->setRegistType(0);
    $class->setSeedRateType(0);
    $class->setStatMatchNum(0);
    $class->setStone(0);
    $class->setSleep(0);
    $class->setSerialRegist(0);
}



sub calc
{
    my $class = shift;
    return sprintf("%.3f", $class->getRegistRate() * $class->getSeedRate() * $class->getStatRate() * $class->getStoneRate() * $class->getSleepRate());
}


sub setSerialRegist
{
    my $class  = shift;
    return $class->setAttribute( 'serial_regist', shift );
}


sub getSerialRegist
{
    return $_[0]->getAttribute( 'serial_regist' );
}




sub getRegistRate
{
    my $class  = shift;
    my $regist = 0;
    if ( $class->getRegistType() == 1 )
    {
        $regist = ( $class->getMainRegist() + $class->getSubRegist() ) / 2;
    }
    else
    {
        $regist = $class->getMainRegist();
    }
    $class->setSerialRegist($regist);
    return (100-$regist)/100;
}


sub getSeedRate
{
    my $class = shift;
    my $type  = $class->getSeedRateType();

    if ( $type == 1 )
    {
        return 1.5;
    }
    elsif ( $type == -1 )
    {
        return 0.5;
    }
    else
    {
        return 1;
    }
}

sub getStatRate
{
    my $class = shift;
    return 1.5 ** $class->getStatMatchNum();
}

sub getStoneRate
{
    my $class = shift;
    return  0.5**$class->isStone();
}

sub getSleepRate
{
    my $class = shift;
    return  1.5**$class->isSleep();
}


sub setSeedRateType
{
    my $class = shift;
    return $class->setAttribute( 'seed_rate_type', shift );
}

sub getSeedRateType
{
    return $_[0]->getAttribute( 'seed_rate_type' );
}






sub setMainRegist
{
    my $class = shift;
    return $class->setAttribute( 'main_regist', shift );
}

sub getMainRegist
{
    return $_[0]->getAttribute( 'main_regist' );
}


sub setSubRegist
{
    my $class = shift;
    return $class->setAttribute( 'sub_regist', shift );
}

sub getSubRegist
{
    return $_[0]->getAttribute( 'sub_regist' );
}



sub setRegistType
{
    my $class = shift;
    return $class->setAttribute( 'regist_type', shift );
}

sub getRegistType
{
    return $_[0]->getAttribute( 'regist_type' );
}



sub setStatMatchNum
{
    my $class = shift;
    return $class->setAttribute( 'stat_match_num', shift );
}

sub getStatMatchNum
{
    return $_[0]->getAttribute( 'stat_match_num' );
}




sub setStone
{
    my $class = shift;
    return $class->setAttribute( 'stone', shift );
}

sub isStone
{
    return $_[0]->getAttribute( 'stone' );
}

sub setSleep
{
    my $class = shift;
    return $class->setAttribute( 'sleep', shift );
}

sub isSleep
{
    return $_[0]->getAttribute( 'sleep' );
}

1;
