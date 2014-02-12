package Anothark::BattleStack;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );
use Anothark::StackObject;

my $status = undef;

use constant TRAP_STACK    => "trap";
use constant COURS_STACK   => "cours";

sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->{TRAP_STACK} = new Anothark::StackObject();
    $self->{COURS_STACK} = new Anothark::StackObject();
    return $self;
}


1;
