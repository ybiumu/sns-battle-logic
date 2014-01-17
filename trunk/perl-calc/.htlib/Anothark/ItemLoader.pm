package Anothark::ItemLoader;
#
# ˆ¤
#
$|=1;
use strict;


use LoggingObjMethod;
use Anothark::Item;
use Anothark::Item::DropItem;
use Anothark::Item::ShopItem;
use base qw( LoggingObjMethod );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setDbHandler($db_handle);
    return $self;
}


my $db_handler = undef;

sub loadItem
{
    my $class = shift;
    my $item_id = shift;
    my $drop_rate = shift || 0;

    my $item = {};

    my $sql = "SELECT * FROM t_item_master WHERE item_master_id = ?";
    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($item_id));
    if ( $sth->rows > 0 )
    {
        $class->warning( "Find record for $item_id" );
        $item  = $drop_rate ? new Anothark::Item::DropItem( $sth->fetchrow_hashref(), $drop_rate) : new Anothark::Item( $sth->fetchrow_hashref());
        $item->setFieldNames( $sth->{"NAME"}  );
    }
    else
    {
        $class->warning( "No record for $item_id" );
        $item = $drop_rate ? new Anothark::Item::DropItem() : new Anothark::Item();
    }
    $sth->finish();

    return $item; 
}


sub loadUserItem
{
    my $class = shift;
    my $user_id = shift;
    my $item_id = shift;

    my $item = {};

#    my $sql = "SELECT * FROM t_item_master WHERE item_master_id = ?";
    my $sql = " SELECT m.* FROM t_user_item AS ui JOIN t_item_master AS m USING( item_master_id ) WHERE ui.user_id = ? AND ui.item_id = ? ";
    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($user_id,$item_id));
    if ( $sth->rows > 0 )
    {
        $class->warning( "Find record for $item_id" );
        $item  = new Anothark::Item( $sth->fetchrow_hashref());
        $item->setFieldNames( $sth->{"NAME"}  );
    }
    else
    {
        $class->warning( "No record for $item_id");
        $item = new Anothark::Item();
    }
    $sth->finish();

    return $item; 
}

sub getItemList
{
    my $class = shift;
    my $offset = shift || 0;

    my $sql = "SELECT item_master_id,item_label FROM t_item_master LIMIT ?,20";
    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($offset));

    my $item_list = [];

    if ( $sth->rows > 0 )
    {
        $item_list = $sth->fetchall_hashref(("item_master_id"));
    }
    $sth->finish();
    return $item_list;
}

sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
    return $_[0]->getAttribute( 'db_handler' );
}




my $get_shop_item_sql = "
SELECT
    shop_element_id,
    item_master_id,
    price,
    item_label,
    item_descr,
    item_type_id
FROM
    t_shop_element
    JOIN
    t_item_master USING(item_master_id)
WHERE
    shop_id = ?
;
";

sub getShopItems
{
    my $class = shift;
    my $shop_id = shift;


    my $shop_item = {};

    my $sth  = $class->getDbHandler()->prepare($get_shop_item_sql);
    my $stat = $sth->execute(($shop_id));
    if ( $sth->rows > 0 )
    {
        $class->warning( "Find record for $shop_id" );
        $shop_item  = { map { my $si = new Anothark::Item::ShopItem( $_ ); $si->setFieldNames( $sth->{"NAME"}  );$si->getShopElementId() => $si } @{$sth->fetchall_arrayref( +{} )} } ;
    }
    else
    {
        $class->warning( "No record for $shop_id");
        $shop_item = new Anothark::Item::ShopItem();
    }
    $sth->finish();

    return $shop_item; 
}

1;
