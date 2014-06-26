package Anothark::Character::Player;

#
# ��
#

$|=1;
use strict;

use Anothark::Character;
use Anothark::Character::StatusIO;
use base qw( Anothark::Character );


use Anothark::ValueObject;
use Anothark::Skill;

sub new
{
    my $class = shift;
    my $default = shift || {};
    my $self = $class->SUPER::new($default);
    $self->debug( "Call Player");
    bless $self, $class;


#    $self->init();
    return $self;
}

#my $user_id = undef;
my $status_io = undef;
my $element_total_count = undef;

my $owner_id = undef;

sub init
{
#    $class->warning( "Call child init");
    my $class = shift;
    $class->SUPER::init();
    $class->setTemplate("player");


}

sub isPlayer
{
    return 1;
}

sub getUserId
{
    return $_[0]->getId();
}

sub setUserId
{
    my $class = shift;
    return $class->setId(shift);
}

#sub setUserId
#{
#    my $class = shift;
#    return $class->setAttribute( 'user_id', shift );
#}
#
#sub getUserId
#{
#    return $_[0]->getAttribute( 'user_id' );
#}
#

sub setStatusIo
{
    my $class = shift;
    $class->setAttribute( 'status_io', shift )->setUserId( $class->getUserId() );
    return $class->getStatusIo();
}

sub getStatusIo
{
    return $_[0]->getAttribute( 'status_io' );
}


sub countupElementCount
{
    my $class = shift;
    my $element_type = shift;
    if( $element_type )
    {
        $class->getUseElementCount()->{$element_type}++;
        $class->setElementTotalCount($class->getElementTotalCount()+1);
        return $class->getUseElementCount()->{$element_type};
    }
    else
    {
    }
}


sub setElementTotalCount
{
    my $class = shift;
    return $class->setAttribute( 'element_total_count', shift );
}

sub getElementTotalCount
{
    return $_[0]->getAttribute( 'element_total_count' );
}


sub setOwnerId
{
    my $class = shift;
    return $class->setAttribute( 'owner_id', shift );
}

sub getOwnerId
{
    return $_[0]->getAttribute( 'owner_id' ) || $_[0]->getUserId();
}


# BattleSetting �� SkillLoader�������Ɏ��
# ���ׂĂ�Character��BattleSetting�����E�E�E���A
# BattleSetting��Loader�����˂Ă���ȏ�_���B
# Loader�Ƃ̑��֊֌W�������Ƃ��܂���肽��
# �Ⴄ���A���ׂĂ�Character�����̂�Cmd���B
# BattleSetting��Loader�őR��
sub setSkills
{
    my $class = shift;
    my $bs   = shift;
    my $sl   = shift;

    $bs->setUserId( $class->getUserId());
    my $settings = $bs->getBattleSettings();

    if ( $settings )
    {
        $bs->notice("FOUND ! [" . $class->getUserId() .  "]");
        foreach my $set ( @{$settings} )
        {
            if ( $set->{position} > 0 )
            {
                if ($set->{setting_id} == 2 )
                {
                    # �X�L��
                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( $set->{info} );
                }
                elsif ( $set->{setting_id} == 3 )
                {
                    # �W���H
                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 31 );
                    $class->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
                    $class->getCmd()->[$set->{position}]->setIsSkill(0);
                }
                elsif ( $set->{setting_id} == 4 )
                {
                    # �ړ��H
                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 40 + ( $set->{info} > 0 ? $set->{info} : 2 ) );
                    $class->getCmd()->[$set->{position}]->setNoSkillType($set->{setting_id});
                    $class->getCmd()->[$set->{position}]->setIsSkill(0);
                }
                elsif ( $set->{setting_id} == 1 && $class->getEquipSkillId() )
                {
                    # �U���ŕ���ɃX�L�����ݒ肳��Ă���
                    $class->error( "[ATACK SKILL ID] (" .$class->getEquipSkillId() . ")" );
                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( $class->getEquipSkillId() );
                }
                else
                {
                    # �����Ȃ���΃p���`
                    $class->getCmd()->[$set->{position}] = $sl->loadSkill( 1001 );
                }
            }
        }
    }
    else
    {
        $bs->warning("No settings found ! [" . $class->getUserId() .  "]");
    }
}

1;

