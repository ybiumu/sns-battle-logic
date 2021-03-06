package Anothark::ItemManager;
#
# ��
#
$|=1;
use strict;


use Anothark::BaseLoader;
use Anothark::Item;
use Anothark::Item::DropItem;
use Anothark::Item::ShopItem;
use Anothark::Item::UserItem;
use base qw( Anothark::BaseLoader );
sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;

    return $self;
}



sub loadItem
{
    my $class = shift;
    my $item_id = shift;
    my $drop_rate = shift || 0;

    my $item = {};

    if ( not $class->loadFromCache( $item, $item_id, $drop_rate ) )
    {
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
    }

    return $item; 
}

sub loadFromCache
{
    my $class = shift;
    my $item    = shift;
    my $item_id = shift;
    my $drop_rate = shift || 0;

    return 0;

}


sub loadUserItem
{
    my $class = shift;
    my $user_id = shift;
#    my $item_id = shift;
    my @itemids = @_;

#    my $item = {};

#    my $sql = "SELECT * FROM t_item_master WHERE item_master_id = ?";
    my $sql = " SELECT m.*,ui.* FROM t_user_item AS ui JOIN t_item_master AS m USING( item_master_id ) WHERE ui.user_id = ? AND ui.item_id = ? ";
    my $sth  = $class->getDbHandler()->prepare($sql);
#    my $stat = $sth->execute(($user_id,$item_id));
    my @item_refs;
    foreach my $item_id (@itemids)
    {
        my $item = {};
        my $stat = $sth->execute(($user_id,$item_id));
        if ( $sth->rows > 0 )
        {
            $class->warning( "Find record for $item_id" );
            $item  = new Anothark::Item::UserItem( $sth->fetchrow_hashref());
            $item->setFieldNames( $sth->{"NAME"}  );
        }
        else
        {
            $class->warning( "No record for $item_id");
            $item = new Anothark::Item::UserItem();
        }
        push(@item_refs, $item);
    }
    $sth->finish();

    return wantarray ? @item_refs : $item_refs[0]; 
}

sub getItemList
{
    my $class = shift;
    my $offset = shift || 0;
    my $vector = shift || 1;

    my $sql;
    if ( $vector eq 1 )
    {
        $sql = "SELECT item_master_id,item_label FROM t_item_master WHERE item_master_id > ? ORDER BY item_master_id LIMIT 51";
    }
    else
    {
        $sql = "SELECT item_master_id,item_label FROM t_item_master WHERE item_master_id < ? ORDER BY item_master_id DESC LIMIT 51";
    }

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($offset));

    my $item_list = [];

    if ( $sth->rows > 0 )
    {
        $item_list = $sth->fetchall_hashref(("item_master_id"));
        if ( $vector eq 1 )
        {
            if ( $sth->rows > 50 )
            {
                $class->setHasNext(1);
                delete $item_list->{ (sort { $b <=> $a } keys %{$item_list})[0] };
            }
        }
        else
        {
            $class->setHasPrev(1);
            $class->setHasNext(1);
            if ( $sth->rows > 50 )
            {
                delete $item_list->{ (sort { $a <=> $b } keys %{$item_list})[0] };
            }
        }
    }
    $sth->finish();
    return $item_list;
}




my $has_next = undef;
my $has_prev = undef;

sub setHasNext
{
    my $class = shift;
    return $class->setAttribute( 'has_next', shift );
}

sub getHasNext
{
    return $_[0]->getAttribute( 'has_next' );
}

sub setHasPrev
{
    my $class = shift;
    return $class->setAttribute( 'has_prev', shift );
}

sub getHasPrev
{
    return $_[0]->getAttribute( 'has_prev' );
}

sub hasPrev
{
    return $_[0]->getHasPrev();
}

sub hasNext
{
    return $_[0]->getHasNext();
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
#        $shop_item = new Anothark::Item::ShopItem();
    }
    $sth->finish();

    return $shop_item; 
}

1;
