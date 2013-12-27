package Anothark::Shop;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use base qw( LoggingObjMethod );


sub new
{
    my $class = shift;
    my $options = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;

    if( ref( $options ) eq "HASH" )
    {
        foreach my $key ( keys %{$options})
        {
            $self->debug( "$key : $options->{$key}");
            $self->{$key} = $options->{$key};
        }
    }


    return $self;
}


my $shop_name = undef;
my $shop_descr = undef;
my $shop_image = undef;
my $shop_id = undef;
my $node_id = undef;

my $items = undef;

my $field_names = undef;

sub setShopName
{
    my $class = shift;
    return $class->setAttribute( 'shop_name', shift );
}

sub getShopName
{
    return $_[0]->getAttribute( 'shop_name' );
}


sub setShopDescr
{
    my $class = shift;
    return $class->setAttribute( 'shop_descr', shift );
}

sub getShopDescr
{
    return $_[0]->getAttribute( 'shop_descr' );
}





sub setShopImage
{
    my $class = shift;
    return $class->setAttribute( 'shop_image', shift );
}

sub getShopImage
{
    return $_[0]->getAttribute( 'shop_image' );
}


sub setShopId
{
    my $class = shift;
    return $class->setAttribute( 'shop_id', shift );
}

sub getShopId
{
    return $_[0]->getAttribute( 'shop_id' );
}

sub setNodeId
{
    my $class = shift;
    return $class->setAttribute( 'node_id', shift );
}

sub getNodeId
{
    return $_[0]->getAttribute( 'node_id' );
}




sub setFieldNames
{
    my $class = shift;
    return $class->setAttribute( 'field_names', shift );
}

sub getFieldNames
{
    return $_[0]->getAttribute( 'field_names' );
}



sub setItems
{
    my $class = shift;
    return $class->setAttribute( 'items', shift );
}

sub getItems
{
    return $_[0]->getAttribute( 'items' );
}


1;
