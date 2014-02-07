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

sub init
{
#    $class->warning( "Call child init");
    my $class = shift;
    $class->SUPER::init();


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


1;

