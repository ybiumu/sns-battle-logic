package Anothark::Item::UserItem;
#
# ˆ¤
#
$|=1;
use strict;


use Anothark::Item;
use base qw( Anothark::Item );
sub new
{
    my $class    = shift;
    my $options  = shift;
    my $self = $class->SUPER::new($options);
    bless $self, $class;



    return $self;
}


my $merged_number = undef;
sub setMergedNumber
{
    my $class = shift;
    return $class->setAttribute( 'merged_number', shift );
}

sub getMergedNumber
{
    return $_[0]->getAttribute( 'merged_number' );
}

my $delete_flag = undef;
sub setDeleteFlag
{
    my $class = shift;
    return $class->setAttribute( 'delete_flag', shift );
}

sub getDeleteFlag
{
    return $_[0]->getAttribute( 'delete_flag' );
}

my $item_id = undef;
sub setItemId
{
    my $class = shift;
    return $class->setAttribute( 'item_id', shift );
}

sub getItemId
{
    return $_[0]->getAttribute( 'item_id' );
}


1;
