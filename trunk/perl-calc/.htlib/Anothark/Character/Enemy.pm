package Anothark::Character::Enemy;

#
# ˆ¤
#

$|=1;
use strict;

use Anothark::Character;
use base qw( Anothark::Character );


use Anothark::ValueObject;
use Anothark::Skill;
use Anothark::Item::DropItem;

#use Anothark::Battle::BaseValue;
#use Anothark::Battle::StatusValue;
#use Anothark::Battle::TargetValue;

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->debug( "Call enemy");
    bless $self, $class;


#    $self->init();
    return $self;
}

my $drop_items = undef;

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->debug( "Call child init");
    $class->setTemplate("enemy");
    $class->setDropItems([
        new Anothark::Item::DropItem( {item_master_id => 5, item_label => '‹•‹U‚ÌŒ‡•Ð' } , 50)
    ]);

    $class->setCmd([
        [],
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
        new Anothark::Skill( '‘Ì“–‚½‚è'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
    ]);

}



sub setDropItems
{
    my $class = shift;
    return $class->setAttribute( 'drop_items', shift );
}

sub getDropItems
{
    return $_[0]->getAttribute( 'drop_items' );
}

#my $raw_data = undef;
#
#my $hp = undef;
#my $stamina = undef;
#my $atack = undef;
#my $magic = undef;
#my $defence = undef;
#my $concentration = undef;
#
#my $side = undef;
#my $id = undef;
#my $name = undef;
#my $msg = undef;
#
#
#my $face_type = undef;
#my $hair_type = undef;
#
#my $agility = undef;
#my $luck = undef;
#my $kehai = undef;
#my $chikaku = undef;
#my $kikyou = undef;
#my $charm = undef;
#
#my $cmd = undef;
#
#my $node_name = undef;
#my $node_id = undef;
#my $is_gm = undef;
#
#
#my $position = undef;
#my $vel = undef;
#my $rel = undef;
#
#my $point_map = {
#    e => { b => 3, f => 2, },
#    p => { b => 0, f => 1, },
#};
#
#my $point_str = {
#    f => "‘O‰q",
#    b => "Œã‰q",
#};
#
#sub setIsGm
#{
#    my $class = shift;
#    return $class->setAttribute( 'is_gm', shift );
#}
#
#sub getIsGm
#{
#    return $_[0]->getAttribute( 'is_gm' );
#}
#
#
#sub setMagic
#{
#    my $class = shift;
#    return $class->setAttribute( 'magic', shift );
#}
#
#sub getMagic
#{
#    return $_[0]->getAttribute( 'magic' );
#}
#
#sub setConcentration
#{
#    my $class = shift;
#    return $class->setAttribute( 'concentration', shift );
#}
#
#sub getConcentration
#{
#    return $_[0]->getAttribute( 'concentration' );
#}
#
#sub setKikyou
#{
#    my $class = shift;
#    return $class->setAttribute( 'kikyou', shift );
#}
#
#sub getKikyou
#{
#    return $_[0]->getAttribute( 'kikyou' );
#}
#
#sub gKky
#{
#    return $_[0]->getKikyou();
#}
#
#sub setChikaku
#{
#    my $class = shift;
#    return $class->setAttribute( 'chikaku', shift );
#}
#
#sub getChikaku
#{
#    return $_[0]->getAttribute( 'chikaku' );
#}
#
#sub gCkk
#{
#    return $_[0]->getChikaku();
#}
#
#sub setKehai
#{
#    my $class = shift;
#    return $class->setAttribute( 'kehai', shift );
#}
#
#sub getKehai
#{
#    return $_[0]->getAttribute( 'kehai' );
#}
#
#
#sub setLuck
#{
#    my $class = shift;
#    return $class->setAttribute( 'luck', shift );
#}
#
#sub getLuck
#{
#    return $_[0]->getAttribute( 'luck' );
#}
#
#
#sub setNodeId
#{
#    my $class = shift;
#    return $class->setAttribute( 'node_id', shift );
#}
#
#sub getNodeId
#{
#    return $_[0]->getAttribute( 'node_id' );
#}
#
#sub setNodeName
#{
#    my $class = shift;
#    return $class->setAttribute( 'node_name', shift );
#}
#
#sub getNodeName
#{
#    return $_[0]->getAttribute( 'node_name' );
#}
#
#
#sub setHairType
#{
#    my $class = shift;
#    return $class->setAttribute( 'hair_type', shift );
#}
#
#sub getHairType
#{
#    return $_[0]->getAttribute( 'hair_type' );
#}
#
#
#sub setFaceType
#{
#    my $class = shift;
#    return $class->setAttribute( 'face_type', shift );
#}
#
#sub getFaceType
#{
#    return $_[0]->getAttribute( 'face_type' );
#}
#
#
#sub setMsg
#{
#    my $class = shift;
#    return $class->setAttribute( 'msg', shift );
#}
#
#sub getMsg
#{
#    return $_[0]->getAttribute( 'msg' );
#}
#
#sub setName
#{
#    my $class = shift;
#    return $class->setAttribute( 'name', shift );
#}
#
#sub getName
#{
#    return $_[0]->getAttribute( 'name' );
#}
#
#
#sub setId
#{
#    my $class = shift;
#    return $class->setAttribute( 'id', shift );
#}
#
#sub getId
#{
#    return $_[0]->getAttribute( 'id' );
#}
#
#
#sub setSide
#{
#    my $class = shift;
#    my $side_str = shift;
#    if ( $side_str =~ /^[ep]$/ )
#    {
#        return $class->setAttribute( 'side', $side_str );
#    }
#    else
#    {
#        return $class->getSide();
#    }
#}
#
#sub getSide
#{
#    return $_[0]->getAttribute( 'side' );
#}
#
#
#sub getReverseSide
#{
#    return ($_[0]->getSide() eq "p" ? "e" : "p");
#}
#
#
#sub setPosition
#{
#    my $class = shift;
#    return $class->setAttribute( 'position', shift );
#}
#
#sub getPosition
#{
#    return $_[0]->getAttribute( 'position' );
#}
#
#
#sub gPos
#{
#    return $_[0]->getPosition();
#}
#
#
#sub setHp
#{
#    my $class = shift;
#    return $class->setAttribute( 'hp', shift );
#}
#
#sub getHp
#{
#    return $_[0]->getAttribute( 'hp' );
#}
#
#sub setStamina
#{
#    my $class = shift;
#    return $class->setAttribute( 'stamina', shift );
#}
#
#sub getStamina
#{
#    return $_[0]->getAttribute( 'stamina' );
#}
#
#
#
#sub setAgility
#{
#    my $class = shift;
#    return $class->setAttribute( 'agility', shift );
#}
#
#sub getAgility
#{
#    return $_[0]->getAttribute( 'agility' );
#}
#
#
#sub setDefence
#{
#    my $class = shift;
#    return $class->setAttribute( 'defence', shift );
#}
#
#sub getDefence
#{
#    return $_[0]->getAttribute( 'defence' );
#}
#
#sub gDef
#{
#    return $_[0]->getDefence();
#}
#
#sub setAtack
#{
#    my $class = shift;
#    return $class->setAttribute( 'atack', shift );
#}
#
#sub getAtack
#{
#    return $_[0]->getAttribute( 'atack' );
#}
#
#
#sub setCharm
#{
#    my $class = shift;
#    return $class->setAttribute( 'charm', shift );
#}
#
#sub getCharm
#{
#    return $_[0]->getAttribute( 'charm' );
#}
#
#
#sub setVel
#{
#    my $class = shift;
#    return $class->setAttribute( 'vel', shift );
#}
#
#sub getVel
#{
#    return $_[0]->getAttribute( 'vel' );
#}
#
#sub setRel
#{
#    my $class = shift;
#    return $class->setAttribute( 'rel', shift );
#}
#
#sub getRel
#{
#    return $_[0]->getAttribute( 'rel' );
#}
#
#
#
#
#
#sub setCmd
#{
#    my $class = shift;
#    return $class->setAttribute( 'cmd', shift );
#}
#
#sub getCmd
#{
#    return $_[0]->getAttribute( 'cmd' );
#}
#
#
#sub setRawData
#{
#    my $class = shift;
#    return $class->setAttribute( 'raw_data', shift );
#}
#
#sub getRawData
#{
#    return $_[0]->getAttribute( 'raw_data' );
#}
#
#
#
#sub getTotalAgility
#{
#    my $class = shift;
#    my $turn   = shift;
#    my $agi = $class->getCurrentAgility($turn);
##    $class->getAgility;
#    return $agi + (0,1,2,3,4,5,6,7,8,9)[int(rand(10))];
#}
#sub getCurrentAgility
#{
#    my $class = shift;
#    my $turn = shift;
#    my $speed = $class->getAgility()->getCurrentValue();
#    my $stamina = $class->getStamina()->getCurrentValue();
#
#    my $rate = (1 - (($stamina - 50) - 10*($turn - 1))/-100);
#    my $real_speed = $speed * ($rate > 1 ? 1 : $rate);
#    return $real_speed;
#}
#
#sub getTargetingValue
#{
#    my $class = shift;
#    my $damage = shift;
#    my $p_sence = shift;
#    my $p_odd  = shift;
#    my $t_charm = $class->getCharm()->current();
#    my $t_hp    = $class->getHp()->current();
#    my $t_kehai = $class->getKehai()->current();
#
#    my $dv =  int( (
#                    ( ( $p_odd > 100 ? $p_odd : 0 ) / 100 )
#                    * ( $t_charm / 100 )
#                    - 1
#              ) / 2 );
#    my $tv = (
#        ( ( $damage / $t_hp ) * ( 0.1 + $p_sence / 100 ) )
#            + ( ( $t_kehai / 100 ) + ( $dv < 0 ? 0: $dv ) )
#    );
#
##    $class->warning( sprintf("[%s ‚Ì À°¹Þ¯Ä’l: %s/%s/%s : %s/%s/%s : %s/%s]", $class->getName(), $t_hp, $t_charm, $t_kehai, $damage,$p_sence, $p_odd, $dv,$tv));
#
#    return $tv;
#}
#
#
#sub getPoint
#{
#    my $class = shift;
#    return $point_map->{$class->getSide()}->{$class->getPosition()->cv()}
#}
#
#sub getPointStr
#{
#    my $class = shift;
#    return $point_str->{$class->getPosition()->cv()};
#}
#
#sub isLiving
#{
#    my $class = shift;
##    $class->warning( sprintf("%s is living.", $class->getName()));
#    return ( $class->getHp()->cv() > 0 );
#}
#
#sub Damage
#{
#    my $class = shift;
#    my $skill = shift;
#    my $dmg   = shift;
#    my $effect_target = $skill->getEffectTargetTypeByKey();
#
#    my $remain = $class->getAttribute($effect_target)->cv() - ( $dmg * ($skill->getEffectType() eq 1 ? -1 : 1) );
#    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
##    my $remain = $class->getHp()->cv() - $dmg;
##    return $class->getHp->setCurrentValue( $remain > 0 ? $remain : 0 );
#}
#
#
##sub GenericDamage
##{
##    my $class = shift;
##    my $effect_target = shift;
##    my $dmg   = shift;
##    my $remain = $class->getAttribute($effect_target)->cv() - $dmg;
##    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
##}

1;

