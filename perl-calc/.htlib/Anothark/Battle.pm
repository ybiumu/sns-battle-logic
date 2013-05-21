package Anothark::Battle;
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
#    $class->setPs(0);
#    $class->setSr(0);
#    $class->setMainExpr(0);
#    $class->setSubExpr(0);
#    $class->setExprType(0);
#    $class->setRange(1.0);
#    $class->setRand(0);
}

sub setCharacter
{
    my $class = shift;
}

sub doBattle
{
    my $class = shift;
}


sub getBattleText
{
    my $class = shift;
}

sub getResultText
{
    my $class = shift;
    return "YouWin!<br /><center>************</center><br />";
}

