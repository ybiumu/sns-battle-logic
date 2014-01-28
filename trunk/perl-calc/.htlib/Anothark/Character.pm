package Anothark::Character;

#
# ˆ¤
#

$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );


use Anothark::ValueObject;
use Anothark::Skill;
use Anothark::Skill::Exhibition;

use Anothark::StatusManager;

use Anothark::Battle::BaseValue;
use Anothark::Battle::StatusValue;
use Anothark::Battle::TargetValue;

sub new
{
    my $class = shift;
    my $default = shift || {};
    my $self = $class->SUPER::new( $default );
    bless $self, $class;


#$class->warning( "new init");
#    $self->init();
#$class->warning( "new init done");
    return $self;
}

#
#
# Charactor - StatusMamanger - Status/Any
#
#

sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->warning( "Call init");
    $class->setUseElementCount({});
    $class->setStatus( new Anothark::StatusManager() );
    $class->setRawData( new Anothark::ValueObject() );
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

    $class->setPosition( new Anothark::ValueObject());
    $class->setRel(0);
    $class->setVel(0);

    if ( exists $class->{without_skill})
    {
        $class->setCmd([
            [],
            ]);
    }
    else
    {
        $class->setCmd([
            [],
            new Anothark::Skill::Exhibition("zoom_punch"),
            new Anothark::Skill::Exhibition("zoom_punch"),
            new Anothark::Skill::Exhibition("lost_memorys"),
            new Anothark::Skill::Exhibition("zoom_punch"),
            new Anothark::Skill::Exhibition("zoom_punch"),
#        new Anothark::Skill( '½Þ°ÑÊßÝÁ'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
#        new Anothark::Skill( '½Þ°ÑÊßÝÁ'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
#        new Anothark::Skill( '½Þ°ÑÊßÝÁ'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
#        new Anothark::Skill( '½Þ°ÑÊßÝÁ'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
#        new Anothark::Skill( '½Þ°ÑÊßÝÁ'   , { power_source => 0, skill_rate => 20 ,length_type => 2,random_type => 2} ),
        ]);
    }

    $class->getRawData()->setBothValue(1);

    $class->getHp()->setBothValue( 100 );
    $class->getStamina()->setBothValue( 100 );
    $class->getAgility()->setBothValue( 100 );

    $class->getChikaku()->setBothValue( 100 );
    $class->getKikyou()->setBothValue( 100 );
    $class->getCharm()->setBothValue( 100 );
    $class->getKehai()->setBothValue( 100 );

    $class->getDefence()->setBothValue( 0 );

    $class->getPosition()->setBothValue( "f" );
}

my $raw_data = undef;

my $hp = undef;
my $stamina = undef;
my $atack = undef;
my $magic = undef;
my $def = undef;
my $rp = undef;

my $side = undef;
my $id = undef;
my $name = undef;
my $msg = undef;

my $use_elelment_count = undef;

my $face_type = undef;
my $hair_type = undef;

my $agl = undef;
my $luck = undef;
my $kehai = undef;
my $chikaku = undef;
my $kikyou = undef;
my $chrm = undef;

my $cmd = undef;

my $node_name = undef;
my $node_id = undef;
my $is_gm = undef;


my $position = undef;
my $vel = undef;
my $rel = undef;
my $status = undef;

my $point_map = {
    e => { b => 3, f => 2, },
    p => { b => 0, f => 1, },
};

my $point_str = {
    f => "‘O‰q",
    b => "Œã‰q",
};

sub setIsGm
{
    my $class = shift;
    return $class->setAttribute( 'is_gm', shift );
}

sub getIsGm
{
    return $_[0]->getAttribute( 'is_gm' );
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
    return $class->setAttribute( 'rp', shift );
}

sub getConcentration
{
    return $_[0]->getAttribute( 'rp' );
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

sub gKky
{
    return $_[0]->getKikyou();
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

sub gCkk
{
    return $_[0]->getChikaku();
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


sub getReverseSide
{
    return ($_[0]->getSide() eq "p" ? "e" : "p");
}


sub setPosition
{
    my $class = shift;
    return $class->setAttribute( 'position', shift );
}

sub getPosition
{
    return $_[0]->getAttribute( 'position' );
}


sub gPos
{
    return $_[0]->getPosition();
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
    return $class->setAttribute( 'agl', shift );
}

sub getAgility
{
    return $_[0]->getAttribute( 'agl' );
}


sub setDefence
{
    my $class = shift;
    return $class->setAttribute( 'def', shift );
}

sub getDefence
{
    return $_[0]->getAttribute( 'def' );
}

sub gDef
{
    return $_[0]->getDefence();
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
    return $class->setAttribute( 'chrm', shift );
}

sub getCharm
{
    return $_[0]->getAttribute( 'chrm' );
}


sub setVel
{
    my $class = shift;
    return $class->setAttribute( 'vel', shift );
}

sub getVel
{
    return $_[0]->getAttribute( 'vel' );
}

sub setRel
{
    my $class = shift;
    return $class->setAttribute( 'rel', shift );
}

sub getRel
{
    return $_[0]->getAttribute( 'rel' );
}




#my $type_experiment = undef;
sub setTypeExperiment
{
    my $class = shift;
    return $class->setAttribute( 'type_experiment', shift );
}

sub getTypeExperiment
{
    return $_[0]->getAttribute( 'type_experiment' );
}

my $type_level = undef;
sub setTypeLevel
{
    my $class = shift;
    return $class->setAttribute( 'type_level', shift );
}

sub getTypeLevel
{
#    return $_[0]->getAttribute( 'type_level' );
    return 0;
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


sub setUseElementCount
{
    my $class = shift;
    return $class->setAttribute( 'use_elelment_count', shift );
}

sub getUseElementCount
{
    return $_[0]->getAttribute( 'use_elelment_count' );
}

sub countupElementCount
{
    return 0;
}

sub setRawData
{
    my $class = shift;
    return $class->setAttribute( 'raw_data', shift );
}

sub getRawData
{
    return $_[0]->getAttribute( 'raw_data' );
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

sub getTargetingValue
{
    my $class = shift;
    my $damage = shift;
    my $p_sence = shift;
    my $p_odd  = shift;
    my $t_chrm = $class->getCharm()->current();
    my $t_hp    = $class->getHp()->current();
    my $t_kehai = $class->getKehai()->current();

    my $dv =  int( (
                    ( ( $p_odd > 100 ? $p_odd : 0 ) / 100 )
                    * ( $t_chrm / 100 )
                    - 1
              ) / 2 );
    my $tv = (
        ( ( $damage / $t_hp ) * ( 0.1 + $p_sence / 100 ) )
            + ( ( $t_kehai / 100 ) + ( $dv < 0 ? 0: $dv ) )
    );

#    $class->warning( sprintf("[%s ‚Ì À°¹Þ¯Ä’l: %s/%s/%s : %s/%s/%s : %s/%s]", $class->getName(), $t_hp, $t_chrm, $t_kehai, $damage,$p_sence, $p_odd, $dv,$tv));

    return $tv;
}

sub isPlayer
{
    return 0;
}

sub getPoint
{
    my $class = shift;
    return $point_map->{$class->getSide()}->{$class->getPosition()->cv()}
}

sub getPointStr
{
    my $class = shift;
    return $point_str->{$class->getPosition()->cv()};
}

sub isLiving
{
    my $class = shift;
#    $class->warning( sprintf("%s is living.", $class->getName()));
    return ( $class->getHp()->cv() > 0 );
}


sub isSmallerThanHalf
{
    my $class = shift;
#    $class->warning( sprintf("%s is living.", $class->getName()));
    return ( $class->getHp()->cv() < $class->getHp()->mv() / 2 );
}

sub canMove
{
    my $class = shift;
    # XXX check status manager! XXX
    return 1;
}



sub canTarget
{
    my $class = shift;
    # XXX check status manager! XXX
    return 1;
}

sub Damage
{
    my $class = shift;
    my $skill = shift;
    my $dmg   = shift;
    my $effect_target = $skill->getEffectTargetTypeByKey();

    $class->debug("Effect Target[$effect_target] DMG[$dmg]");

    my $remain = $class->getAttribute($effect_target)->cv() - ( $dmg * ($skill->getEffectType() eq 1 ? -1 : 1) );
    if ( $skill->getEffectTargetType() == 3 )
    {
        if ( $remain > 0 )
        {
            # Add damage concent
            my $cbase =  ($dmg * 10 ) / $class->getAttribute($effect_target)->cv();
            $cbase += 1 if ( int($cbase) != $cbase  );
            $class->getConcentration->addCurrent( int($cbase) );
        }
    }

    # Status Resolve
    if ( $skill->getNoSkillType() == 4)
    {
        if ( $skill->getSkillId() == 41 )
        {
            $class->getPosition->setCurrentValue("f");
        }
        else
        {
            $class->getPosition->setCurrentValue("b");
        }
    }

    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
#    my $remain = $class->getHp()->cv() - $dmg;
#    return $class->getHp->setCurrentValue( $remain > 0 ? $remain : 0 );
}


#sub GenericDamage
#{
#    my $class = shift;
#    my $effect_target = shift;
#    my $dmg   = shift;
#    my $remain = $class->getAttribute($effect_target)->cv() - $dmg;
#    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
#}

1;

