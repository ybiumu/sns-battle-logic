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
    my $stack = shift;
#    $class->debug("[STACKED] ", join (",", map { sprintf("[%s]=[%s]", $_, $stack->{$_}) } keys %{$stack} ) );
    push(@{$class->getMemory()},$stack);

}

sub isRemain
{
#    $_[0]->debug("[CALL IS_REMAIN]: " . scalar(@{$_[0]->getMemory()}));
    return scalar(@{$_[0]->getMemory()})
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


sub moveOne
{
    my $class = shift;
    return shift(@{$class->getMemory()});
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
    return reverse @{$stack_list};
}


sub moveAll
{
    my $class = shift;
    my $stack_list =  $class->getMemory();
#    $class->debug("LENGTH1: " . scalar(@{$stack_list}));
    $class->clearStack();
#    $class->debug("LENGTH2: " . scalar(@{$stack_list}));
    return @{$stack_list};
}

sub filter
{
    my $class = shift;
    my $filter_key = shift;
    my $new_object = new Anothark::StackObject();
    $new_object->stackArray( grep { $_->{name} eq $filter_key } @{$class->getMemory()} );
    my @remain = grep { $_->{name} ne $filter_key } @{$class->getMemory()};
    $class->clearStack();
    $class->stackArray(@remain);
    return $new_object;
}

sub filterByFunction
{
    my $class = shift;
    my $filter_function = shift;
    my $new_object = new Anothark::StackObject();
    $new_object->stackArray( grep { &{$filter_function}($_) } @{$class->getMemory()} );
    my @remain = grep { not &{$filter_function}($_) } @{$class->getMemory()};
    $class->clearStack();
    $class->stackArray(@remain);
    return $new_object;
}


sub existsByFunction
{
    my $class = shift;
    my $filter_function = shift;
    my $new_object = new Anothark::StackObject();
    return scalar grep { &{$filter_function}($_) } @{$class->getMemory()};
}

1;
