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

1;

