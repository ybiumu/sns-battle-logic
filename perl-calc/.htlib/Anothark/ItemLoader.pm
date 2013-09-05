package Anothark::ItemLoader;
#
# ˆ¤
#
$|=1;
use strict;


use ObjMethod;
use Anothark::Item;
use Anothark::Item::DropItem;
use base qw( ObjMethod );
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
        warn "Find record for $item_id";
        $item  = $drop_rate ? new Anothark::Item::DropItem( $sth->fetchrow_hashref(), $drop_rate) : new Anothark::Item( $sth->fetchrow_hashref());
        $item->setFieldNames( $sth->{"NAME"}  );
    }
    else
    {
        warn "No record for $item_id";
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
        warn "Find record for $item_id";
        $item  = new Anothark::Item( $sth->fetchrow_hashref());
        $item->setFieldNames( $sth->{"NAME"}  );
    }
    else
    {
        warn "No record for $item_id";
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





1;
