package Anothark::Character::Npc;
#
# ˆ¤
#

$|=1;
use strict;

use Anothark::Character;
use base qw( Anothark::Character );

sub new
{
    my $class = shift;
    my $default = shift || {};
    my $npc_id  = shift || 0;
    my $self = $class->SUPER::new($default);
    $self->debug( "Call Npc");
    bless $self, $class;
    return $self;
}


sub init
{
    my $class = shift;
    $class->SUPER::init();
    $class->setTemplate("npc");
}

sub isNpc
{
    return 1;
}


my $npc_id = undef;
my $npc_name = undef;
my $img_code = undef;

sub setNpcId
{
    my $class = shift;
    return $class->setAttribute( 'npc_id', shift );
}

sub getNpcId
{
    return $_[0]->getAttribute( 'npc_id' );
}

sub setNpcName
{
    my $class = shift;
    return $class->setAttribute( 'npc_name', shift );
}

sub getNpcName
{
    return $_[0]->getAttribute( 'npc_name' );
}

sub setImgCode
{
    my $class = shift;
    return $class->setAttribute( 'img_code', shift );
}

sub getImgCode
{
    return $_[0]->getAttribute( 'img_code' );
}


1;

