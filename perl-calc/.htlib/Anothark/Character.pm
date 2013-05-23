package Anothark::Character;
$|=1;
use strict;

use ObjMethod;
use base qw( ObjMethod );


use Anothark::ValueObject;
use Anothark::Skill;

use Anothark::Battle::BaseValue;
use Anothark::Battle::StatusValue;
use Anothark::Battle::TargetValue;

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
    $class->setHp( new Anothark::ValueObject() );
    $class->setStamina( new Anothark::ValueObject());
    $class->setConcentration( new Anothark::ValueObject());

    $class->setAtack( new Anothark::ValueObject());
    $class->setDefence( new Anothark::ValueObject());
    $class->setMagic( new Anothark::ValueObject());

    $class->setKehai( new Anothark::ValueObject());
    $class->setLuck( new Anothark::ValueObject());
    $class->setAgility( new Anothark::ValueObject());
    $class->setChikaku( new Anothark::ValueObject());
    $class->setKikyou( new Anothark::ValueObject());
    $class->setCharm( new Anothark::ValueObject());


    $class->setCmd([
        [],
        new Anothark::Skill( 'ÊßİÁ' ),
        new Anothark::Skill( 'ÊßİÁ' ),
        new Anothark::Skill( 'ÊßİÁ' ),
        new Anothark::Skill( 'ÊßİÁ' ),
        new Anothark::Skill( 'ÊßİÁ' ),
    ]);

    $class->getHp()->setBothValue( 100 );
    $class->getStamina()->setBothValue( 100 );
    $class->getAgility()->setBothValue( 100 );
}

my $hp = undef;
my $stamina = undef;
my $atack = undef;
my $magic = undef;
my $defence = undef;
my $concentration = undef;

my $side = undef;
my $id = undef;
my $name = undef;
my $msg = undef;


my $face_type = undef;
my $hair_type = undef;

my $agility = undef;
my $luck = undef;
my $kehai = undef;
my $chikaku = undef;
my $kikyou = undef;
my $charm = undef;

my $cmd = undef;

my $node_name = undef;
my $node_id = undef;

sub setMagic
{
    my $class = shift;
    return $class->setAttribute( 'magic', shift );
}

sub getMagic
{
    return $_[0]->getAttribute( 'magic' );
}

sub setConcentration
{
    my $class = shift;
    return $class->setAttribute( 'concentration', shift );
}

sub getConcentration
{
    return $_[0]->getAttribute( 'concentration' );
}

sub setKikyou
{
    my $class = shift;
    return $class->setAttribute( 'kikyou', shift );
}

sub getKikyou
{
    return $_[0]->getAttribute( 'kikyou' );
}

sub setChikaku
{
    my $class = shift;
    return $class->setAttribute( 'chikaku', shift );
}

sub getChikaku
{
    return $_[0]->getAttribute( 'chikaku' );
}

sub setKehai
{
    my $class = shift;
    return $class->setAttribute( 'kehai', shift );
}

sub getKehai
{
    return $_[0]->getAttribute( 'kehai' );
}


sub setLuck
{
    my $class = shift;
    return $class->setAttribute( 'luck', shift );
}

sub getLuck
{
    return $_[0]->getAttribute( 'luck' );
}


sub setNodeId
{
    my $class = shift;
    return $class->setAttribute( 'node_id', shift );
}

sub getNodeId
{
    return $_[0]->getAttribute( 'node_id' );
}

sub setNodeName
{
    my $class = shift;
    return $class->setAttribute( 'node_name', shift );
}

sub getNodeName
{
    return $_[0]->getAttribute( 'node_name' );
}


sub setHairType
{
    my $class = shift;
    return $class->setAttribute( 'hair_type', shift );
}

sub getHairType
{
    return $_[0]->getAttribute( 'hair_type' );
}


sub setFaceType
{
    my $class = shift;
    return $class->setAttribute( 'face_type', shift );
}

sub getFaceType
{
    return $_[0]->getAttribute( 'face_type' );
}


sub setMsg
{
    my $class = shift;
    return $class->setAttribute( 'msg', shift );
}

sub getMsg
{
    return $_[0]->getAttribute( 'msg' );
}

sub setName
{
    my $class = shift;
    return $class->setAttribute( 'name', shift );
}

sub getName
{
    return $_[0]->getAttribute( 'name' );
}


sub setId
{
    my $class = shift;
    return $class->setAttribute( 'id', shift );
}

sub getId
{
    return $_[0]->getAttribute( 'id' );
}


sub setSide
{
    my $class = shift;
    my $side_str = shift;
    if ( $side_str =~ /^[ep]$/ )
    {
        return $class->setAttribute( 'side', $side_str );
    }
    else
    {
        return $class->getSide();
    }
}

sub getSide
{
    return $_[0]->getAttribute( 'side' );
}


sub setHp
{
    my $class = shift;
    return $class->setAttribute( 'hp', shift );
}

sub getHp
{
    return $_[0]->getAttribute( 'hp' );
}

sub setStamina
{
    my $class = shift;
    return $class->setAttribute( 'stamina', shift );
}

sub getStamina
{
    return $_[0]->getAttribute( 'stamina' );
}



sub setAgility
{
    my $class = shift;
    return $class->setAttribute( 'agility', shift );
}

sub getAgility
{
    return $_[0]->getAttribute( 'agility' );
}


sub setDefence
{
    my $class = shift;
    return $class->setAttribute( 'defence', shift );
}

sub getDefence
{
    return $_[0]->getAttribute( 'defence' );
}

sub setAtack
{
    my $class = shift;
    return $class->setAttribute( 'atack', shift );
}

sub getAtack
{
    return $_[0]->getAttribute( 'atack' );
}


sub setCharm
{
    my $class = shift;
    return $class->setAttribute( 'charm', shift );
}

sub getCharm
{
    return $_[0]->getAttribute( 'charm' );
}






sub setCmd
{
    my $class = shift;
    return $class->setAttribute( 'cmd', shift );
}

sub getCmd
{
    return $_[0]->getAttribute( 'cmd' );
}


sub getTotalAgility
{
    my $class = shift;
    my $turn   = shift;
    my $agi = $class->getCurrentAgility($turn);
#    $class->getAgility;
    return $agi + (0,1,2,3,4,5,6,7,8,9)[int(rand(10))];
}
sub getCurrentAgility
{
    my $class = shift;
    my $turn = shift;
    my $speed = $class->getAgility()->getCurrentValue();
    my $stamina = $class->getStamina()->getCurrentValue();

    my $rate = (1 - (($stamina - 50) - 10*($turn - 1))/-100);
    my $real_speed = $speed * ($rate > 1 ? 1 : $rate);
    return $real_speed;
}
1;
