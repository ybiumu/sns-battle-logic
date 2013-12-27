package Anothark::Item::ShopItem;
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


#    if( ref( $options ) eq "HASH" )
#    {
#        foreach my $key ( keys %{$options})
#        {
#            $class->warning( "$key : $options->{$key}");
#            $self->{$key} = $options->{$key};
#        }
#    }


    return $self;
}

my $price = undef;
my $shop_element_id = undef;


sub setPrice
{
    my $class = shift;
    return $class->setAttribute( 'price', shift );
}

sub getPrice
{
    return $_[0]->getAttribute( 'price' );
}

sub setShopElementId
{
    my $class = shift;
    return $class->setAttribute( 'shop_element_id', shift );
}

sub getShopElementId
{
    return $_[0]->getAttribute( 'shop_element_id' );
}


1;
