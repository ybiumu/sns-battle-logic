package Anothark::StackObject;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );


my $memory = undef;
sub new
{
    my $class = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->clearStack();
    return $self;
}

sub clearStack
{
    return $_[0]->setMemory([]);
}

sub setMemory
{
    my $class = shift;
    return $class->setAttribute( 'memory', shift );
}

sub getMemory
{
    return $_[0]->getAttribute( 'memory' );
}


sub stackOne
{
    my $class = shift;
    push(@{$class->getMemory()},shift);

}

sub stackArray
{
    my $class = shift;
    push(@{$class->getMemory()},@_);
}

sub resolveOne
{
    my $class = shift;
    return pop(@{$class->getMemory()});
}

sub resolveRange
{
    my $class = shift;
    my $range = shift;
    my $nf    = $#{$class->getMemory()};
    return reverse splice(@{$class->getMemory()}, $nf - ($range - 1) ,$nf );
}
sub resolveAll
{
    my $class = shift;
    my $stack_list =  $class->getMemory();
    $class->clearStack();
    return @{$stack_list};
}

1;
