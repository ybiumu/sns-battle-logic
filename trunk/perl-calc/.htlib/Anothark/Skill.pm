package Anothark::Skill;
#
# ˆ¤
#
$|=1;
use strict;

use constant RAND_ALIAS => { 0 => 0, 1 => 5, 2 => 10, 3 => 25, 4 => 50, 5 => 100};

use ObjMethod;
use base qw( ObjMethod );
sub new
{
    my $class = shift;
    my $name = shift || "ÊßÝÁ";
    my $options = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setName($name);
    $self->setSkillRate(5);
    $self->setRandomType(2);
    $self->setBaseType(1);
    $self->setBaseElement(2);
    $self->setRangeType(1);
    $self->setEffectType(0);
    $self->setTargetType(1);


    if( ref( $options ) eq "HASH" )
    {
        foreach my $key ( %{$options})
        {
            $self->{$key} = $options->{$key};
        }
    }


    return $self;
}

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
    3 => "long" 
};

my $element_name =
{
    0 => "ŠÑ",
    1 => "Ža",
    2 => "Õ",
    3 => "•ª",
    4 => "Á",
    -1 => "¸",
    11 => "‰Š",
    12 => "—â",
    13 => "³",
    14 => "•‰",
};

my $available_value = {
    'effect_type'      => [0,1,2,3,4,5,6],
    'learn_type_id'    => [0,1,2],
    'type_id'          => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'sub_type_id'      => [ 0, 1, 2, 3, 4, 5, 6, 7, 11, 12, 13, 14, 15, 20 ],
    'skill_type'       => [1,2,3,4],
    'power_source'     => [0,1,2],
    'concent_type'     => [0,1,2,3,4],
    'random_type'      => [0,1,2,3,4,5,6],
    'formula_type'     => [0,1],
    'base_type'        => [1,2,3,4],
    'base_element'     => [0,1,2,3,4,-1,11,12,13,14],
    'sub_base_type'    => [0,1,2,3,4],
    'sub_base_element' => [0,1,2,3,4,-1,11,12,13,14],
    'length_type'         => [1,2,3],
    'range_type'          => [1,2,3],
    'target_type'         => [1,2,3],
    'position_limit_type' => [0,1,2],
    'flying_limit_type'   => [0,1,2],
    'phaseout_limit_type' => [0,1,2],
};

my $name = undef;
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
my $random_type = undef;

sub setName
{
    my $class = shift;
    return $class->setAttribute( 'name', shift );
}

sub getName
{
    return $_[0]->getAttribute( 'name' );
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




1;
