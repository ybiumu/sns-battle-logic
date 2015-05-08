package Anothark::Character;

#
# 愛
#

$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );


use Anothark::ValueObject;
use Anothark::Skill;
use Anothark::Skill::Exhibition;

use Anothark::StatusManager;
use Anothark::StackObject;

use Anothark::Battle::BaseValue;
use Anothark::Battle::StatusValue;
use Anothark::Battle::TargetValue;

our $preset_keys = [
    'hp',
    'max_hp',
    'stamina',
    'magic',
    'def',
    'rp',
    'atack',
    'agl',
    'kehai',
    'chikaku',
    'luck',
    'kikyou',
    'chrm'
];

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
    $class->setTemplate("character");
    $class->setEquipSkillId(0);
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

    $class->setRegist0( new Anothark::ValueObject() );
    $class->setRegist1( new Anothark::ValueObject() );
    $class->setRegist2( new Anothark::ValueObject() );
    $class->setRegist3( new Anothark::ValueObject() );
    $class->setRegist4( new Anothark::ValueObject() );

    $class->setRegist11( new Anothark::ValueObject() );
    $class->setRegist12( new Anothark::ValueObject() );
    $class->setRegist13( new Anothark::ValueObject() );
    $class->setRegist14( new Anothark::ValueObject() );

    $class->setRegist_1( new Anothark::ValueObject() );

    $class->setSeedTypeValue( new Anothark::ValueObject() );

    $class->setRel(0);
    $class->setVel(0);


    $class->setChainStack(0);
    $class->setTrapStack( new Anothark::StackObject());
    $class->setCurseStack( new Anothark::StackObject());
    # 解決用
    $class->setStacks( new Anothark::StackObject() );

    $class->setResolveChainStack(0);
    $class->setResolveTrapStack( new Anothark::StackObject());
    $class->setResolveCurseStack( new Anothark::StackObject());
# create StackObject
#
#  trap
#  carse
#  prepare
#

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

    $class->getSeedTypeValue()->setBothValue( "0000000000000000000000000000000000000000" );

    $class->preset();

}

sub preset
{
    my $class = shift;
    $class->warning( "Call preset");
    if ( exists $class->{preset})
    {
        $class->warning( "Preset exists.");
        $class->warning( "keys [" . join("/",sort keys %{$class->{preset}}) . "].");

        foreach my $key ( sort keys %{$class->{preset}})
        {
            if ( exists $class->{$key} )
            {
                my $ref = ref $class->{$key};
                if ( $ref =~ /^Anothark::ValueObject(|::.+)$/ )
                {
                    $class->{$key}->setBothValue( $class->{preset}->{$key} );
                }
                else
                {
                    $class->{$key} = $class->{preset}->{$key};
                }
            }
            else
            {
                $class->{$key} = $class->{preset}->{$key};
            }
        }
    }
}

=pod
初期状態の保存
=cut
sub fixInit
{
    my $class = shift;
    map {
        $class->{$_}->setStackValues( 0 );
    } grep { my $ref = ref $class->{$_}; $ref =~ /^Anothark::ValueObject(|::.+)$/ } sort keys %{$class};
}

my $raw_data = undef;

my $user_name = undef;

my $hp = undef;
my $stamina = undef;
my $atack = undef;
my $magic = undef;
my $def = undef;
my $rp = undef;
my $agl = undef;
my $luck = undef;
my $kehai = undef;
my $chikaku = undef;
my $kikyou = undef;
my $chrm = undef;


my $regist_0 = undef;
my $regist_1 = undef;
my $regist_2 = undef;
my $regist_3 = undef;
my $regist_4 = undef;
my $regist_11 = undef;
my $regist_12 = undef;
my $regist_13 = undef;
my $regist_14 = undef;
my $regist__1 = undef;

my $side = undef;


my $id = undef;
my $name = undef;
my $msg = undef;

my $use_elelment_count = undef;

my $face_type = undef;
my $hair_type = undef;


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
    f => "前衛",
    b => "後衛",
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


sub setUserName
{
    my $class = shift;
    return $class->setAttribute( 'user_name', shift );
}

sub getUserName
{
    return $_[0]->getAttribute( 'user_name' );
}


sub setSide
{
    my $class = shift;
    my $side_str = shift;
    if ( $side_str =~ /^[ep]$/ )
    {
        $class->setTextSide($side_str);
        return $class->setAttribute( 'side', $side_str );
    }
    elsif( $side_str eq "n" )
    {
        $class->setTextSide($side_str);
        return $class->getSide();
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


my $text_side = undef;
sub setTextSide
{
    my $class = shift;
    return $class->setAttribute( 'text_side', shift );
}

sub getTextSide
{
    return $_[0]->getAttribute( 'text_side' );
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


sub setRegist0
{
    my $class = shift;
    return $class->setAttribute( 'regist_0', shift );
}

sub getRegist0
{
    return $_[0]->getAttribute( 'regist_0' );
}

sub setRegist1
{
    my $class = shift;
    return $class->setAttribute( 'regist_1', shift );
}

sub getRegist1
{
    return $_[0]->getAttribute( 'regist_1' );
}

sub setRegist2
{
    my $class = shift;
    return $class->setAttribute( 'regist_2', shift );
}

sub getRegist2
{
    return $_[0]->getAttribute( 'regist_2' );
}

sub setRegist3
{
    my $class = shift;
    return $class->setAttribute( 'regist_3', shift );
}

sub getRegist3
{
    return $_[0]->getAttribute( 'regist_3' );
}

sub setRegist4
{
    my $class = shift;
    return $class->setAttribute( 'regist_4', shift );
}

sub getRegist4
{
    return $_[0]->getAttribute( 'regist_4' );
}

sub setRegist11
{
    my $class = shift;
    return $class->setAttribute( 'regist_11', shift );
}

sub getRegist11
{
    return $_[0]->getAttribute( 'regist_11' );
}

sub setRegist12
{
    my $class = shift;
    return $class->setAttribute( 'regist_12', shift );
}

sub getRegist12
{
    return $_[0]->getAttribute( 'regist_12' );
}

sub setRegist13
{
    my $class = shift;
    return $class->setAttribute( 'regist_13', shift );
}

sub getRegist13
{
    return $_[0]->getAttribute( 'regist_13' );
}

sub setRegist14
{
    my $class = shift;
    return $class->setAttribute( 'regist_14', shift );
}

sub getRegist14
{
    return $_[0]->getAttribute( 'regist_14' );
}

sub setRegist_1
{
    my $class = shift;
    return $class->setAttribute( 'regist_-1', shift );
}

sub getRegist_1
{
    return $_[0]->getAttribute( 'regist_-1' );
}


sub getRegistById
{
    return $_[0]->getAttribute( 'regist_' . $_[1] );
}

sub setRegistById
{
    my $class = shift;
    my $id    = shift;
    return $class->setAttribute( 'regist_' . $id, shift );
}


my $seed_type_value = undef;

sub setSeedTypeValue
{
    my $class = shift;
    return $class->setAttribute( 'seed_type_value', shift );
}

sub getSeedTypeValue
{
    return $_[0]->getAttribute( 'seed_type_value' );
}


=pod
 End of status
=cut















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




my $experiments = undef;
sub setExperiments
{
    my $class = shift;
    return $class->setAttribute( 'experiments', shift );
}

sub getExperiments
{
    return $_[0]->getAttribute( 'experiments' );
}


#my $type_experiment = undef;
sub setTypeExperiment
{
    my $class = shift;
    return $class->setAttribute( 'type_experiment', shift );
}

sub getTypeExperiment
{
    my $class = shift;
    my $type  = shift;
    my $exps = $class->getExperiments();
    if ( ref($exps) eq "HASH" && exists $exps->{$type} )
    {
        return $exps->{$type}->{"exp"};
    }
    else
    {
        return 0;
    }
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
    my $class = shift;
    my $type  = shift;
    my $exp   = $class->getTypeExperiment($type);
    my $lv    = int sqrt(($exp * 2 - ( $exp >= 1 ? 1 : 0 )));
    return $lv;
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

#    $class->warning( sprintf("[%s の ターゲット値: %s/%s/%s : %s/%s/%s : %s/%s]", $class->getName(), $t_hp, $t_chrm, $t_kehai, $damage,$p_sence, $p_odd, $dv,$tv));

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


my $equip_skill_id = undef;

my $stacks = undef;
my $trap_stack = undef;
my $curse_stack = undef;
my $chain_stack = undef;

my $resolve_chain_stack = undef;
my $resolve_trap_stack = undef;
my $resolve_curse_stack = undef;

sub setStacks
{
    my $class = shift;
    return $class->setAttribute( 'stacks', shift );
}

sub getStacks
{
    return $_[0]->getAttribute( 'stacks' );
}



sub setResolveCurseStack
{
    my $class = shift;
    return $class->setAttribute( 'resolve_curse_stack', shift );
}

sub getResolveCurseStack
{
    return $_[0]->getAttribute( 'resolve_curse_stack' );
}

sub setResolveTrapStack
{
    my $class = shift;
    return $class->setAttribute( 'resolve_trap_stack', shift );
}

sub getResolveTrapStack
{
    return $_[0]->getAttribute( 'resolve_trap_stack' );
}

sub setResolveChainStack
{
    my $class = shift;
    return $class->setAttribute( 'resolve_chain_stack', shift );
}

sub getResolveChainStack
{
    return $_[0]->getAttribute( 'resolve_chain_stack' );
}

sub incrResolveChainStack
{
    $_[0]->{'resolve_chain_stack'} = $_[0]->{'chain_stack'} + 1;
}



sub setTrapStack
{
    my $class = shift;
    return $class->setAttribute( 'trap_stack', shift );
}

sub getTrapStack
{
    return $_[0]->getAttribute( 'trap_stack' );
}

sub setCurseStack
{
    my $class = shift;
    return $class->setAttribute( 'curse_stack', shift );
}

sub getCurseStack
{
    return $_[0]->getAttribute( 'curse_stack' );
}


sub setChainStack
{
    my $class = shift;
    return $class->setAttribute( 'chain_stack', shift );
}

sub getChainStack
{
    return $_[0]->getAttribute( 'chain_stack' );
}



sub setEquipSkillId
{
    my $class = shift;
    return $class->setAttribute( 'equip_skill_id', shift );
}

sub getEquipSkillId
{
    return $_[0]->getAttribute( 'equip_skill_id' );
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

sub Affected
{
    my $class = shift;
    my $value = shift;
    my $affected_target = shift;

    my $remain = $class->getAttribute($affected_target)->cv() + $value;

    return $class->getAttribute($affected_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
}

sub Damage
{
    my $class = shift;
    my $skill = shift;
    my $dmg   = shift;
    my $char  = shift;
    my $effect_target = $skill->getEffectTargetTypeByKey();
    my $stat  = undef;

    $class->debug("Effect Target[$effect_target] DMG[$dmg]");

    my $remain = $class->getAttribute($effect_target)->cv() - ( $dmg * (($skill->getEffectType() eq 1 || $skill->getEffectType() eq 2) ? -1 : 1) );
    # HPにダメージ 
    if ( $skill->getEffectType() eq "0"  && $skill->getEffectTargetType() == 3 )
    {
        if ( $remain > 0 )
        {
            # Add damage concent
            my $cbase =  ($dmg * 10 ) / $class->getAttribute($effect_target)->cv();
            $cbase += 1 if ( int($cbase) != $cbase  );
            $class->getConcentration->addCurrent( int($cbase) );
        }

        # ダメージが発生した時の処理
        if ( $dmg )
        {
            $class->setDamaged(1);
            # この時点でStackを移動
            # 無名キャラがダメージ発生源ではないこと
#            $class->incrResolveChainStack(); # 連携を増やす->最終的には状態異常側に。
#                                             #   -> 違う、スキル側に判定を移譲。
            if ( $skill->isChain( $class ) ) # 連携の判定
            {
                $class->incrResolveChainStack(); # 連携を増やす
            }

            if ( $char->getTemplate() ne "virtual" )
            {
                # 呪詛を解決スタックに移動
                $class->getResolveCurseStack()->stackArray(
                    map {
                        $_->getSkill()->getTargetType() eq 1 ? $_->setTo( $char ) : $_->setTo( $class ); $_; 
                    } $class->getCurseStack()->moveAll()
                );
            }
        }

        if ( $stat )
        {
            if ( $char->getTemplate() ne "virtual" )
            {
                # 罠を解決スタックに移動
                # 罠は１つずつ
                $class->getResolveTrapStack()->stackOne(
                    map {
                        $_->getSkill()->getTargetType() eq 1 ? $_->setTo( $char ) : $_->setTo( $class ); $_; 
                    } ( $class->getCurseStack()->moveOne() )
                );
            }
        }
    }
    # HP以外にダメージはDIFF計算不要・仮計算も不要
    else
    {
    }

    # Status Resolve
    if ( $skill->getNoSkillType() == 4)
    {
        if ( $skill->getSkillId() == 41 )
        {
            $class->getPosition->setCurrentValueWithoutStack("f");
        }
        else
        {
            $class->getPosition->setCurrentValueWithoutStack("b");
        }
    }

    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
#    my $remain = $class->getHp()->cv() - $dmg;
#    return $class->getHp->setCurrentValue( $remain > 0 ? $remain : 0 );
}


sub Die
{
    my $class = shift;

    $class->debug("Die character");

    # 死んだら呪詛解除
    $class->getResolveCurseStack()->clearStack();

    # 昏睡罠
    $class->getResolveTrapStack()->stackArray( $class->getTrapStack()->filter("trap_die")->moveOne() );

    $class->getStatus()->setDie();

}

#sub GenericDamage
#{
#    my $class = shift;
#    my $effect_target = shift;
#    my $dmg   = shift;
#    my $remain = $class->getAttribute($effect_target)->cv() - $dmg;
#    return $class->getAttribute($effect_target)->setCurrentValue( $remain > 0 ? $remain : 0 );
#}


my $template = undef;
sub setTemplate
{
    my $class = shift;
    return $class->setAttribute( 'template', shift );
}

sub getTemplate
{
    return $_[0]->getAttribute( 'template' );
}


my $damaged = undef;
sub setDamaged
{
    my $class = shift;
    return $class->setAttribute( 'damaged', shift );
}

sub getDamaged
{
    return $_[0]->getAttribute( 'damaged' );
}

# 呼ばれたら必ずクリア
sub damaged
{
    my $class = shift;
    my $current = $class->getDamaged();
    $class->setDamaged(0);
    return $current;
}

my $trap_stacked = undef;
sub setTrapStacked
{
    my $class = shift;
    return $class->setAttribute( 'trap_stacked', shift );
}

sub getTrapStacked
{
    return $_[0]->getAttribute( 'trap_stacked' );
}


# 呼ばれたら必ずクリア
sub traped
{
    my $class = shift;
    my $current = $class->getTrapStacked();
    $class->getTrapStacked(0);
    return $current;
}





# BattleSetting と SkillLoaderを引数に取る
# すべてのCharacterはBattleSettingをもつ・・・が、
# BattleSettingがLoaderを兼ねている以上ダメ。
# Loaderとの相関関係をもっとうまく作りたい
# 違うか、すべてのCharacterが持つのはCmdか。
# BattleSettingはLoaderで然り

# 実装は各継承先で
sub setSkills
{
    my $class = shift;
#    my $bs   = shift;
#    my $sl   = shift;
#
#    $bs->setUserId( $class->getUserId());
#    my $settings = $bs->getBattleSettings();
#
#    if ( $settings )
#    {
#        $bs->notice("FOUND ! [" . $class->getUserId() .  "]");
#        foreach my $set ( @{$settings} )
#        {
#            if ( $set->{position} > 0 )
#            {
#                if ($set->{setting_id} == 2 )
#                {
#                    # スキル
#                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( $set->{info} );
#                }
#                elsif ( $set->{setting_id} == 3 )
#                {
#                    # 集中？
#                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 31 );
#                    $class->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
#                    $class->getCmd()->[$set->{position}]->setIsSkill(0);
#                }
#                elsif ( $set->{setting_id} == 4 )
#                {
#                    # 移動？
#                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 40 + ( $set->{info} > 0 ? $set->{info} : 2 ) );
#                    $class->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
#                    $class->getCmd()->[$set->{position}]->setIsSkill(0);
#                }
#                elsif ( $set->{setting_id} == 1 && $class->getEquipSkillId() )
#                {
#                    # 攻撃で武器にスキルが設定されている
#                    $class->error( "[ATACK SKILL ID] (" .$class->getEquipSkillId() . ")" );
#                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( $class->getEquipSkillId() );
#                }
#                else
#                {
#                    # 何もなければパンチ
#                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 1001 );
#                }
#            }
#        }
#    }
#    else
#    {
#        $bs->warning("No settings found ! [" . $class->getUserId() .  "]");
#    }
}


1;

