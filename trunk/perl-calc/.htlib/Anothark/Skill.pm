package Anothark::Skill;
#
# ��
#
$|=1;
use strict;

use constant RAND_ALIAS => { 0 => 0, 1 => 5, 2 => 10, 3 => 25, 4 => 50, 5 => 100};

use ObjMethod;
use base qw( ObjMethod );
sub new
{
    my $class   = shift;
    my $name    = shift || "����";
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



    $self->setup_options($options);

    return $self;
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
#            warn sprintf("[LIB] %s: %s",$key, $options->{$key});
        }
    }
}





#my $element_name =
#{
#    0 => "�ђ�",
#    1 => "�a��",
#    2 => "�Ռ�",
#    3 => "����",
#    4 => "����",
#    -1 => "���_",
#    11 => "���M",
#    12 => "��C",
#    13 => "���d��",
#    14 => "���d��",
#};


my $range_str = {
    1 => "short"  ,
    2 => "middle" ,
    3 => "long" 
};

my $element_name =
{
    0  => '��',
    1  => '�a',
    2  => '��',
    3  => '��',
    4  => '��',
    -1 => '��',
    11 => '��',
    12 => '��',
    13 => '��',
    14 => '��',
};

my $type_name = {
    1  => '��',
    2  => '��',
    3  => '��b',
    4  => '��',
    5  => '��',
    6  => '�|',
    7  => '�e',
    11 => '��',
    12 => '��',
    13 => '��',
    14 => '��',
    15 => '�y��',
    20 => '��'
};

sub typeId2typeName
{
    return $type_name->{$_[0]};
}
my $available_value = {
#0:�U��,1:��,2:�t�^,3:�,4:���f,5:�V���[�Y,6:�����_��
    'effect_type'        => [0,1,2,3,4,5,6],
    'learn_type_id'      => [0,1,2],
# 1:��,2:��,3:��b,4:��,5:��,6:�|,7:�e,11:��,12:��,13:��,14:��,15:�y��,20:��
    'type_id'            => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'sub_type_id'        => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'skill_type'         => [1,2,3,4],
    'power_source'       => [0,1,2,3,4,5],
#a0:field,1:atc,2:magic,3:hp,4:agi,5:sence
    'effect_target_type' => [0,1,2,3,4,5],
    'concent_type'       => [0,1,2,3,4],
    'random_type'        => [0,1,2,3,4,5,6],
    'formula_type'       => [0,1],
    'base_type'          => [1,2,3,4],
    'base_element'       => [0,1,2,3,4,-1,11,12,13,14],
    'sub_base_type'      => [0,1,2,3,4],
    'sub_base_element'   => [0,1,2,3,4,-1,11,12,13,14],
    'length_type'         => [1,2,3],
    'range_type'          => [1,2,3],
    'target_type'         => [1,2,3],
    'position_limit_type' => [0,1,2],
    'flying_limit_type'   => [0,1,2],
    'phaseout_limit_type' => [0,1,2],
};


my $iv_map = {
    0 => "raw_data",
    1 => "atack",
    2 => "magic",
    3 => "hp",
    4 => "agility",
    5 => "chikaku",
};


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

1;