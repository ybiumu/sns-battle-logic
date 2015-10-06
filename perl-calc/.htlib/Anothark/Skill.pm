package Anothark::Skill;
#
# ˆ¤
#
$|=1;
use strict;

use constant RAND_ALIAS => { 0 => 0, 1 => 5, 2 => 10, 3 => 25, 4 => 50, 5 => 100};

use LoggingObjMethod;
use base qw( LoggingObjMethod );
sub new
{
    my $class   = shift;
    my $name    = shift || "ÊßÝÁ";
    my $options = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setName($name);
    $self->setChildren([]);
    $self->setSkillRate(5);
    $self->setRandomType(2);
    $self->setBaseType(1);
    $self->setBaseElement(2);
    $self->setRangeType(1);
    $self->setEffectType(0);
    $self->setEffectTargetType(3);
    $self->setPowerSource(1);
    $self->setTargetType(1);
    $self->setParentSkillId(0);
    $self->setIsSkill(1);
    $self->setNoSkillType(0);

    $self->setActionType(0);



    $self->setup_options($options);

    return $self;
}
sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->debug("Call skill init");
}

sub setup_options
{
    my $class = shift;
    my $options = shift;
    if( ref( $options ) eq "HASH" )
    {
        foreach my $key ( keys %{$options})
        {
            $class->{$key} = $options->{$key};
#            $class->warning( sprintf("[LIB] %s: %s",$key, $options->{$key}));
        }
    }
}


# action_type
# 0: active
# 1: passive
# 2: prepare
# 3: special


#my $element_name =
#{
#    0 => "ŠÑ’Ê",
#    1 => "ŽaŒ‚",
#    2 => "ÕŒ‚",
#    3 => "•ª‰ð",
#    4 => "Á‹Ž",
#    -1 => "¸_",
#    11 => "‰Š”M",
#    12 => "—â‹C",
#    13 => "³“dŽ¥",
#    14 => "•‰“dŽ¥",
#};


my $range_str = {
    1 => "short"  ,
    2 => "middle" ,
    3 => "long",
    4 => "self"
};

my $element_name =
{
    0  => 'ŠÑ',
    1  => 'Ža',
    2  => 'Õ',
    3  => '•ª',
    4  => 'Á',
    -1 => '¸',
    11 => '‰Š',
    12 => '—â',
    13 => '³',
    14 => '•‰',
};

my $type_name = {
    1 => {
        1  => 'Œ•',
        2  => '’Æ',
        3  => 'Žèb',
        4  => '‘„',
        5  => '•Ú',
        6  => '‹|',
        7  => 'e',
        11 => '‰Š',
        12 => '—â',
        13 => 'Œõ',
        14 => 'ˆÅ',
        15 => 'ŠyŠí',
        20 => '‚',
        21 => '–h‹ï'
    },
    2 => {
        1  => 'Œ•@',
        2  => '’Æ@',
        3  => 'Žèb',
        4  => '‘„@',
        5  => '•Ú@',
        6  => '‹|@',
        7  => 'e@',
        11 => '‰Š@',
        12 => '—â@',
        13 => 'Œõ@',
        14 => 'ˆÅ@',
        15 => 'ŠyŠí',
        20 => '‚@',
        21 => '–h‹ï'
    },
};

sub typeId2typeName
{
    return $type_name->{1}->{$_[0]};
}

sub typeId2typeName2
{
    return $type_name->{2}->{$_[0]};
}
my $available_value = {
#0:UŒ‚,1:‰ñ•œ,2:•t—^,3:ã©,4:Žôæf,5:ƒVƒŠ[ƒY,6:ƒ‰ƒ“ƒ_ƒ€
    'effect_type'        => [0,1,2,3,4,5,6],
    'learn_type_id'      => [0,1,2],
# 1:Œ•,2:’Æ,3:Žèb,4:‘„,5:•Ú,6:‹|,7:e,11:‰Š,12:—â,13:Œõ,14:ˆÅ,15:ŠyŠí,20:‚
    'type_id'            => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'sub_type_id'        => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'skill_type'         => [1,2,3,4],
    'power_source'       => [0,1,2,3,4,5],
#0:field,1:atc,2:magic,3:hp,4:agi,5:sence,6:def,7:connect,8:aura,9:luck,10:odd,11:charm,12:stamina
    'effect_target_type' => [0,1,2,3,4,5,6,7,8,9,10,11,12],
    'concent_type'       => [0,1,2,3,4],
    'random_type'        => [0,1,2,3,4,5,6],
    'formula_type'       => [0,1],
    'base_type'          => [1,2,3,4],
    'base_element'       => [0,1,2,3,4,-1,11,12,13,14],
    'sub_base_type'      => [0,1,2,3,4],
    'sub_base_element'   => [0,1,2,3,4,-1,11,12,13,14],
    'length_type'         => [1,2,3], #1: ‹ßÚ, 2: ’†, 3: ‰“
    'range_type'          => [1,2,3], #1: ’P‘Ì, 2: “¯”z’u, 3: ‘S‘Ì
    'target_type'         => [1,2,3,4], #1: “G,2: –¡•û,3: ‘S‘Ì,4: Ž©g 
    'position_limit_type' => [0,1,2],
    'flying_limit_type'   => [0,1,2],
    'phaseout_limit_type' => [0,1,2],
};


my $iv_map = {
    0 => "raw_data",
    1 => "atack",
    2 => "magic",
    3 => "hp",
    4 => "agl",
    5 => "chikaku",
    6 => "def",
    7 => "rp",
    8 => "kehai",
    9 => "luck",
    10 => "kikyou",
    11 => "chrm",
    12 => "stamina",
    13 => "reg_0",
    14 => "reg_1",
    15 => "reg_2",
    16 => "reg_3",
    17 => "reg_4",
    18 => "reg_-1",
    19 => "reg_11",
    20 => "reg_12",
    21 => "reg_13",
    22 => "reg_14",
};


my $name_map = {
    0 => "—Íê",
    1 => "UŒ‚",
    2 => "–‚—Í",
    3 => "‘Ì—Í",
    4 => "•q·",
    5 => "’mŠo",
    6 => "–hŒä",
    7 => "W’†",
    8 => "‹C”z",
    9 => "‰^‹C",
    10 => "Šï‹¸",
    11 => "–£—Í",
    12 => "Ž‹v",
    13 => "ŠÑ’Ê‘Ï«",
    14 => "ŽaŒ‚‘Ï«",
    15 => "ÕŒ‚‘Ï«",
    16 => "•ª‰ð‘Ï«",
    17 => "Á‹Ž‘Ï«",
    18 => "¸_‘Ï«",
    19 => "‰Š”M‘Ï«",
    20 => "—â‹C‘Ï«",
    21 => "Œõ‘Ï«",
    22 => "ˆÅ‘Ï«",
};

my $is_skill = undef;
my $no_skill_type = [1,2,3]; #1: move, 2: concent, 3: item

my $skill_id = undef;
my $parent_skill_id = undef;
my $sequence_id = undef;
my $type_id = undef;
my $enable_level = undef;
my $sub_type_id = undef;
my $sub_enable_level = undef;
my $skill_name = undef;
my $skill_rate = undef;
my $skill_type = undef;
my $power_source = undef;
my $concent_type = undef;
my $base_type = undef;
my $base_element = undef;
my $length_type = undef;
my $range_type = undef;
my $target_type = undef;
my $flying_limit_type = undef;
my $position_limit_type = undef;
my $phaseout_limit_type = undef;
my $effect_type = undef;
my $effect_target_type = undef;
my $random_type = undef;
my $learn_type_id = undef;
my $skill_descr = undef;
my $sub_base_type = undef;
my $sub_base_element = undef;
my $formula_type = undef;
my $children = undef;

my $field_names = undef;
my $skill_loader = undef;



my $action_type = undef;
sub setActionType
{
    my $class = shift;
    return $class->setAttribute( 'action_type', shift );
}

sub getActionType
{
    return $_[0]->getAttribute( 'action_type' );
}


sub setFieldNames
{
    my $class = shift;
    return $class->setAttribute( 'field_names', shift );
}

sub getFieldNames
{
    return $_[0]->getAttribute( 'field_names' );
}


sub setLearnTypeId
{
    my $class = shift;
    return $class->setAttribute( 'learn_type_id', shift );
}

sub getLearnTypeId
{
    return $_[0]->getAttribute( 'learn_type_id' );
}

sub setSkillDescr
{
    my $class = shift;
    return $class->setAttribute( 'skill_descr', shift );
}

sub getSkillDescr
{
    return $_[0]->getAttribute( 'skill_descr' );
}

sub setSubBaseType
{
    my $class = shift;
    return $class->setAttribute( 'sub_base_type', shift );
}

sub getSubBaseType
{
    return $_[0]->getAttribute( 'sub_base_type' );
}

sub setSubBaseElement
{
    my $class = shift;
    return $class->setAttribute( 'sub_base_element', shift );
}

sub getSubBaseElement
{
    return $_[0]->getAttribute( 'sub_base_element' );
}

sub setFormulaType
{
    my $class = shift;
    return $class->setAttribute( 'formula_type', shift );
}

sub getFormulaType
{
    return $_[0]->getAttribute( 'formula_type' );
}


sub setName
{
    my $class = shift;
    return $class->setAttribute( 'skill_name', shift );
}

sub getName
{
    return $_[0]->getAttribute( 'skill_name' );
}



my $element = undef;
sub setElement
{
    my $class = shift;
    return $class->setAttribute( 'element', shift );
}

sub getElement
{
    return $_[0]->getAttribute( 'element' );
}




sub setSkillId
{
    my $class = shift;
    return $class->setAttribute( 'skill_id', shift );
}

sub getSkillId
{
    return $_[0]->getAttribute( 'skill_id' );
}

sub setParentSkillId
{
    my $class = shift;
    return $class->setAttribute( 'parent_skill_id', shift );
}

sub getParentSkillId
{
    return $_[0]->getAttribute( 'parent_skill_id' );
}

sub setSequenceId
{
    my $class = shift;
    return $class->setAttribute( 'sequence_id', shift );
}

sub getSequenceId
{
    return $_[0]->getAttribute( 'sequence_id' );
}

sub setTypeId
{
    my $class = shift;
    return $class->setAttribute( 'type_id', shift );
}

sub getTypeId
{
    return $_[0]->getAttribute( 'type_id' );
}

sub setEnableLevel
{
    my $class = shift;
    return $class->setAttribute( 'enable_level', shift );
}

sub getEnableLevel
{
    return $_[0]->getAttribute( 'enable_level' );
}

sub setSubTypeId
{
    my $class = shift;
    return $class->setAttribute( 'sub_type_id', shift );
}

sub getSubTypeId
{
    return $_[0]->getAttribute( 'sub_type_id' );
}

sub setSubEnableLevel
{
    my $class = shift;
    return $class->setAttribute( 'sub_enable_level', shift );
}

sub getSubEnableLevel
{
    return $_[0]->getAttribute( 'sub_enable_level' );
}

sub setSkillName
{
    my $class = shift;
    return $class->setAttribute( 'skill_name', shift );
}

sub getSkillName
{
    return $_[0]->getAttribute( 'skill_name' );
}

sub setSkillRate
{
    my $class = shift;
    return $class->setAttribute( 'skill_rate', shift );
}

sub getSkillRate
{
    return $_[0]->getAttribute( 'skill_rate' );
}

sub setSkillType
{
    my $class = shift;
    return $class->setAttribute( 'skill_type', shift );
}

sub getSkillType
{
    return $_[0]->getAttribute( 'skill_type' );
}

sub setPowerSource
{
    my $class = shift;
    return $class->setAttribute( 'power_source', shift );
}

sub getPowerSource
{
    return $_[0]->getAttribute( 'power_source' );
}


sub getPowerSourceByKey
{
    return $iv_map->{$_[0]->getPowerSource()};
}

sub getEffectTargetLabel
{
    return $name_map->{$_[0]->getEffectTargetType()};
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

sub setBaseType
{
    my $class = shift;
    return $class->setAttribute( 'base_type', shift );
}

sub getBaseType
{
    return $_[0]->getAttribute( 'base_type' );
}

sub setBaseElement
{
    my $class = shift;
    return $class->setAttribute( 'base_element', shift );
}

sub getBaseElement
{
    return $_[0]->getAttribute( 'base_element' );
}



sub getBaseElementName
{
    return $element_name->{$_[0]->getBaseElement()};
}

sub setLengthType
{
    my $class = shift;
    return $class->setAttribute( 'length_type', shift );
}

sub getLengthType
{
    return $_[0]->getAttribute( 'length_type' );
}

sub setRangeType
{
    my $class = shift;
    return $class->setAttribute( 'range_type', shift );
}

sub getRangeType
{
    return $_[0]->getAttribute( 'range_type' );
}

sub getRangeTypeStr
{
    return $range_str->{$_[0]->getRangeType()};
}

sub setTargetType
{
    my $class = shift;
    return $class->setAttribute( 'target_type', shift );
}

sub getTargetType
{
    return $_[0]->getAttribute( 'target_type' );
}

sub setFlyingLimitType
{
    my $class = shift;
    return $class->setAttribute( 'flying_limit_type', shift );
}

sub getFlyingLimitType
{
    return $_[0]->getAttribute( 'flying_limit_type' );
}

sub setPositionLimitType
{
    my $class = shift;
    return $class->setAttribute( 'position_limit_type', shift );
}

sub getPositionLimitType
{
    return $_[0]->getAttribute( 'position_limit_type' );
}

sub setPhaseoutLimitType
{
    my $class = shift;
    return $class->setAttribute( 'phaseout_limit_type', shift );
}

sub getPhaseoutLimitType
{
    return $_[0]->getAttribute( 'phaseout_limit_type' );
}

sub setEffectType
{
    my $class = shift;
    return $class->setAttribute( 'effect_type', shift );
}

sub getEffectType
{
    return $_[0]->getAttribute( 'effect_type' );
}

sub setRandomType
{
    my $class = shift;
    return $class->setAttribute( 'random_type', shift );
}

sub getRandomType
{
    return $_[0]->getAttribute( 'random_type' );
}

sub getRandomAlias
{
    return RAND_ALIAS->{$_[0]->getRandomType()};
}


sub setEffectTargetType
{
    my $class = shift;
    return $class->setAttribute( 'effect_target_type', shift );
}

sub getEffectTargetType
{
    return $_[0]->getAttribute( 'effect_target_type' );
}


sub getEffectTargetTypeByKey
{
    return $iv_map->{$_[0]->getEffectTargetType()};
}



sub setSkillLoader
{
    my $class = shift;
    return $class->setAttribute( 'skill_loader', shift );
}

sub getSkillLoader
{
    return $_[0]->getAttribute( 'skill_loader' );
}


#sub checkChild
#{
#    my $class = shift;
#    my $sql =
#}
#


sub setChildren
{
    my $class = shift;
    return $class->setAttribute( 'children', shift );
}

sub getChildren
{
    return $_[0]->getAttribute( 'children' );
}

sub appendChild
{
    push(@{$_[0]->getChildren()},$_[1]);
}


sub setIsSkill
{
    my $class = shift;
    return $class->setAttribute( 'is_skill', shift );
}

sub getIsSkill
{
    return $_[0]->getAttribute( 'is_skill' );
}

sub isSkill
{
    return $_[0]->getIsSkill();
}


sub setNoSkillType
{
    my $class = shift;
    return $class->setAttribute( 'no_skill_type', shift );
}

sub getNoSkillType
{
    return $_[0]->getAttribute( 'no_skill_type' );
}


my $regist_type = undef;
my $expr_type = undef;
sub setExprType
{
    my $class = shift;
    return $class->setAttribute( 'expr_type', shift );
}

sub getExprType
{
    return $_[0]->getAttribute( 'expr_type' );
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


my $seed_rate_value = undef;
sub setSeedRateValue
{
    my $class = shift;
    return $class->setAttribute( 'seed_rate_value', shift );
}

sub getSeedRateValue
{
    return $_[0]->getAttribute( 'seed_rate_value' );
}


sub checkSeedRate
{
    my $class = shift;
    my $char  = shift;

    my $result = sprintf("%040s",$class->getSeedRateValue() + $char->getSeedTypeValue()->cv());
    $class->warning( sprintf("SEED_RESULT: %s/%s/%s\n", $result, $class->getSeedRateValue(),$char->getSeedTypeValue()->cv() ) );
    if ( $result =~ /6/ )
    {
        return 1;
    }
    elsif( $result =~ /7/ )
    {
        return 2;
    }
    else
    {
        return 0;
    }
}


my $effect_status_value = undef;
sub setEffectStatusValue
{
    my $class = shift;
    return $class->setAttribute( 'effect_status_value', shift );
}

sub getEffectStatusValue
{
    return $_[0]->getAttribute( 'effect_status_value' );
}


my $chain_status_value = undef;
sub setChainStatusValue
{
    my $class = shift;
    return $class->setAttribute( 'chain_status_value', shift );
}

sub getChainStatusValue
{
    return $_[0]->getAttribute( 'chain_status_value' );
}


sub isChain
{
    my $class = shift;
    my $target = shift;
    $class->debug("[isChain]");
    return $target->getStatus()->checkChainStatusByStr( $class->getChainStatusValue() );
#    return 1; # Exhibision;
}


1;
