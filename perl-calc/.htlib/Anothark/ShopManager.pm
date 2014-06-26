package Anothark::ShopManager;
#
# 愛
#
$|=1;
use strict;
use Encode;
use Anothark::BaseLoader;
use Anothark::ItemLoader;
use Anothark::Shop;
use Anothark::Character::StatusIO;
use base qw( LoggingObjMethod );

my $status = undef;

sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;
    return $self;
}


my $get_exists_shop_sql = "
SELECT
    DISTINCT s.node_id
FROM
    t_user_status AS s 
    JOIN t_shop_master AS p USING(node_id)
WHERE user_id = ?
";

sub getExistsShop
{
    my $class = shift;
    my $user_id = shift;
    my $sth = $class->getDbHandler()->prepare($get_exists_shop_sql);
    my $stat = $sth->execute(($user_id));
    my $result = 0;
    if ( $sth->rows > 0 )
    {
        $class->debug( "Find shop on user staying." );
        $result = 1;
    }
    else
    {
        $class->debug( "No shop find on user staying." );
    }
    $sth->finish();

    return $result; 
}


my $get_shop_list_sql = "
SELECT
    s.node_id,
    p.shop_id,
    p.shop_name,
    p.shop_descr,
    p.shop_image
FROM
    t_user AS u
    JOIN
    t_user_status AS s USING(user_id)
    JOIN t_shop_master AS p USING(node_id)
WHERE user_id = ?
    AND DATE(NOW()) BETWEEN p.open_date AND p.close_date
    AND TIME(NOW()) BETWEEN p.open_time AND p.close_time
";

sub getShopList
{
    my $class = shift;
    my $user_id = shift;

    my $shop_list = [];
    my $sth  = $class->getDbHandler()->prepare($get_shop_list_sql);
    my $stat = $sth->execute(($user_id));


    if ( $sth->rows > 0 )
    {
#        $shop_list = $sth->fetchall_hashref(("shop_id"));
        $shop_list = $sth->fetchall_arrayref( +{} );
    }
    $sth->finish();
    return $shop_list;

}

my $get_shop_descr_sql = "
SELECT
    s.node_id,
    p.shop_id,
    p.shop_name,
    p.shop_descr,
    p.shop_image
FROM
    t_user AS u
    JOIN
    t_user_status AS s USING(user_id)
    JOIN t_shop_master AS p USING(node_id)
WHERE user_id = ? AND shop_id = ?
";

sub loadShopDescr
{
    my $class = shift;
    my $user_id = shift;
    my $shop_id = shift;

    my $shop = {};

    my $sth  = $class->getDbHandler()->prepare($get_shop_descr_sql);
    my $stat = $sth->execute(($user_id,$shop_id));
    if ( $sth->rows > 0 )
    {
        $class->warning( "Find record for $shop_id" );
        $shop  = new Anothark::Shop( $sth->fetchrow_hashref());
        $shop->setFieldNames( $sth->{"NAME"}  );
        my $il = new Anothark::ItemLoader( $class->getDbHandler() );
        $shop->setItems( $il->getShopItems( $shop_id ) );
    }
    else
    {
        $class->warning( "No record for $shop_id");
        $shop = new Anothark::Shop();
    }
    $sth->finish();

    return $shop; 
}

sub trading
{
    my $class = shift;
    my $char  = shift;
    my $shop  = shift;
    my $seid  = shift;
    my $money_unit = shift;
    my $num   = shift;

    my $item = $shop->getItems()->{$seid};
    my $price = $item->getPrice();
    my $total = $price * $num;
    my $status = "";
    my $lc_mu = lc($money_unit);
    # 持ち金確認
    $class->warning("Total: $total / Having:  $char->{$lc_mu} / Unit: $money_unit / Char: " . ref($char) );
    if ( $char->{$lc_mu} >= $total )
    {
        # 所持金十分
        my $s_io = $char->getStatusIo();
        $s_io->spendMoney( $total, $money_unit );
        $s_io->getItem( $item->getItemMasterId(), $num );
        $status = sprintf('%sを購入しました', $item->getItemLabel());
    }
    else
    {
        # 所持金不足
        $status = sprintf('お金が足りません');
    }
    return $status;
}

1;
