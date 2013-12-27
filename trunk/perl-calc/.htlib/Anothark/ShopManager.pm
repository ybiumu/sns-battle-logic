package Anothark::ShopManager;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use LoggingObjMethod;
use Anothark::ItemLoader;
use Anothark::Shop;
use base qw( LoggingObjMethod );

my $status = undef;

sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new();
    $self->setDbHandler($db_handle);
    bless $self, $class;
    return $self;
}

my $db_handler = undef;
sub setDbHandler
{
    my $class = shift;
    return $class->setAttribute( 'db_handler', shift );
}

sub getDbHandler
{
    return $_[0]->getAttribute( 'db_handler' );
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


1;
