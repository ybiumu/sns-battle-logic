package Anothark::Character::StatusIO;
#
# ˆ¤
#
$|=1;
use strict;

use LoggingObjMethod;
use base qw( LoggingObjMethod );
use Anothark::Item::UserItem;
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
my $user_id = undef;

sub setUserId
{
    my $class = shift;
    return $class->setAttribute( 'user_id', shift );
}

sub getUserId
{
    return $_[0]->getAttribute( 'user_id' );
}


sub spendMoney
{
    my $class = shift;
#    my $user_id    = shift;
    my $user_id = $class->getUserId();
    my $price      = shift;
    my $money_unit = lc(shift);

    $class->debug("Inner user_id[" . $class->getUserId() . "]");
    my $sql_tmp = "UPDATE t_user_money AS um SET um._MONEY_UNIT_ = um._MONEY_UNIT_ - ? WHERE um.user_id = ?";
    my $sql = $sql_tmp;
    $sql =~ s/_MONEY_UNIT_/$money_unit/g;

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($price,$user_id));
    $sth->finish();
}

sub getItem
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $item_master_id = shift;
    my $count   = shift || 1;

    $class->debug("Inner user_id[" . $class->getUserId() . "]");
# Get base data.
    my $get_item_base_sql = "SELECT * FROM t_item_master WHERE item_master_id = ?";
    my $sth_base  = $class->getDbHandler()->prepare($get_item_base_sql);
    $sth_base->execute( $item_master_id );
    my $item_base = new Anothark::Item($sth_base->fetchrow_hashref());
    $sth_base->finish();

# Can merge?
    my $get_item_mergable_sql = "SELECT i.*, m.* FROM t_user_item AS i JOIN t_item_master AS m  USING(item_master_id) WHERE i.user_id = ? AND i.delete_flag = 0 AND i.item_master_id = ? AND i.merged_number < m.merge_number ORDER BY item_id ";
    my $sth_mergable  = $class->getDbHandler()->prepare($get_item_mergable_sql);
    $sth_mergable->execute( $user_id, $item_master_id );

    my $update_record_sql = "UPDATE t_user_item SET merged_number = ?, delete_flag = ? WHERE user_id = ? AND item_id = ? AND delete_flag = 0;";
    my $sth_update_record  = $class->getDbHandler()->prepare($update_record_sql);
#    my $item_mergable = new Anothark::Item($sth_mergable->fetchrow_hashref());
    foreach my $item_mergable ( map { new Anothark::Item::UserItem($_); } @{$sth_mergable->fetchall_arrayref( +{} )} )
    {
        my $remain = $item_mergable->getMergeNumber() -  $item_mergable->getMergedNumber();
        if ( $count <= $remain )
        {
            # update count+mergednumber;
            $sth_update_record->execute( $item_mergable->getMergedNumber()+$count, 0, $user_id, $item_mergable->getItemId() );
            $count = 0;
        }
        else
        {
            # update by mergenumber
            $sth_update_record->execute( $item_mergable->getMergeNumber(), 0, $user_id, $item_mergable->getItemId() );
            $count -= $remain;
        }

        last if ( $count == 0 );
    }

    $sth_mergable->finish();
    $sth_update_record->finish();

# Insert remain.
    if ( $count )
    {
        my $sql = "
INSERT INTO t_user_item (user_id, item_master_id,merged_number)
SELECT
    ? AS user_id,
    item_master_id,
    ? AS merged_number
FROM
    t_item_master
WHERE
    item_master_id = ?
";

        my $sth  = $class->getDbHandler()->prepare($sql);
        while($count)
        {
            # INSERT 
            if ( $count < $item_base->getMergeNumber() )
            {
                $sth->execute($user_id,$count,$item_master_id);
                $count = 0;
            }
            else
            {
                $sth->execute($user_id, $item_base->getMergeNumber(), $item_master_id);
                $count -= $item_base->getMergeNumber();
            }
        }
        $sth->finish();
    }

## OLD VERSION
#    my $sql = "
#INSERT INTO t_user_item (user_id, item_master_id,merged_number)
#SELECT
#    ? AS user_id,
#    item_master_id,
#    ? AS merged_number
#FROM
#    t_item_master
#WHERE
#    item_master_id = ?
#";
#
#    my $sth  = $class->getDbHandler()->prepare($sql);
#    for ( my $i = 0 ; $i < $count ; $i++)
#    {
#        my $stat = $sth->execute(($user_id,$append, $item_id));
#    }
#    $sth->finish();

#    return $item; 
}

sub mergeItem
{
    my $class = shift;
    my $user_id = $class->getUserId();
    my @itemids = @_;
    $class->debug("Inner user_id[" . $class->getUserId() . "]");

    my $place_holder = join(",", map {"?"} @itemids);

    my $booking_sql = "UPDATE t_user_item AS i SET delete_flag = 3 WHERE user_id = ? AND delete_flag = 0 AND item_id IN ( _NUM_ARRAY_ )";
    $booking_sql =~ s/_NUM_ARRAY_/$place_holder/;

    my $sth_booking  = $class->getDbHandler()->prepare($booking_sql);
    my $stat = $sth_booking->execute(($user_id,@itemids));
    $sth_booking->finish();

# Booking
# merge
# insert


    my $get_desc_sql = "
SELECT
    i.item_master_id,
    GROUP_CONCAT(i.item_id) AS id_list,
    m.item_label,
    m.merge_number,
    FLOOR((sum(i.merged_number) ) / m.merge_number) AS mxnum ,
    (sum(i.merged_number) ) % m.merge_number AS remain_num
FROM
    t_user_item AS i
    JOIN
    t_item_master AS m
    USING(item_master_id)
WHERE
    user_id = ?
    AND
    delete_flag = 3
    AND
    item_id IN ( _NUM_ARRAY_ ) GROUP BY item_master_id;";
    $get_desc_sql =~ s/_NUM_ARRAY_/$place_holder/;

    my $sth_get_desc  = $class->getDbHandler()->prepare($get_desc_sql);
    $stat = $sth_get_desc->execute(($user_id,@itemids));

    my $entries = $sth_get_desc->fetchall_arrayref( +{} );

    $sth_get_desc->finish();

#INSERT INTO t_user_item ( user_id, item_master_id,merged_number ) VALUES (101,5,2),(101,14,3);
#    my $new_record_sql = "INSERT INTO t_user_item ( user_id, item_master_id,merged_number ) VALUES (?,?,?);";
    my $update_record_sql = "UPDATE t_user_item SET merged_number = ?, delete_flag = ? WHERE user_id = ? AND item_id = ? AND delete_flag = 3;";
    my $sth_update_record  = $class->getDbHandler()->prepare($update_record_sql);


    foreach my $item_type ( @{ $entries } )
    {
        my @itemids = split(",", $item_type->{id_list} );
        for ( my $i = 0; $item_type->{mxnum} > $i;$i++ )
        {
#            $sth_new_record->execute( $user_id,$item_type->{item_master_id},$item_type->{merge_number} );
            $sth_update_record->execute( $item_type->{merge_number}, 0, $user_id, shift(@itemids) );
        }

        if ( $item_type->{remain_num} )
        {
#            $sth_new_record->execute( $user_id,$item_type->{item_master_id},$item_type->{remain_num} );
            $sth_update_record->execute( $item_type->{remain_num}, 0, $user_id, shift(@itemids) );
#            $sth_new_record->execute( $user_id,$item_type->{item_master_id},$item_type->{remain_num} );
        }

        foreach my $missing ( @itemids )
        {
            $sth_update_record->execute( 0, 3, $user_id, $missing );
        }
    }
    $sth_update_record->finish();
}



sub sepItem
{
    my $class = shift;
    my $user_id = $class->getUserId();
    my $targets = shift;
    $class->debug("Inner user_id[" . $class->getUserId() . "]");
    my @itemids = keys %{$targets};

    my $place_holder = join(",", map {"?"} @itemids);

    my $booking_sql = "UPDATE t_user_item AS i SET delete_flag = 5 WHERE user_id = ? AND delete_flag = 0 AND item_id IN ( _NUM_ARRAY_ )";
    $booking_sql =~ s/_NUM_ARRAY_/$place_holder/;

    my $sth_booking  = $class->getDbHandler()->prepare($booking_sql);
    my $stat = $sth_booking->execute(($user_id,@itemids));
    $sth_booking->finish();

# Booking
# merge
# insert
# $class->getItem();

    my $get_desc_sql = "
SELECT
    i.*,
    m.*
FROM
    t_user_item AS i
    JOIN
    t_item_master AS m
    USING(item_master_id)
WHERE
    user_id = ?
    AND
    delete_flag = 5
    AND
    item_id IN ( _NUM_ARRAY_ );";
    $get_desc_sql =~ s/_NUM_ARRAY_/$place_holder/;

    my $sth_get_desc  = $class->getDbHandler()->prepare($get_desc_sql);
    $stat = $sth_get_desc->execute(($user_id,@itemids));

    my $entries = $sth_get_desc->fetchall_arrayref( +{} );

    $sth_get_desc->finish();

#INSERT INTO t_user_item ( user_id, item_master_id,merged_number ) VALUES (101,5,2),(101,14,3);
#    my $new_record_sql = "INSERT INTO t_user_item ( user_id, item_master_id,merged_number ) VALUES (?,?,?);";
    my $update_record_sql = "UPDATE t_user_item SET merged_number = ?, delete_flag = ? WHERE user_id = ? AND item_id = ? AND delete_flag = 5;";
    my $sth_update_record  = $class->getDbHandler()->prepare($update_record_sql);

    my $sql = "
INSERT INTO t_user_item (user_id, item_master_id,merged_number)
SELECT
    ? AS user_id,
    item_master_id,
    ? AS merged_number
FROM
    t_item_master
WHERE
    item_master_id = ?
";

    my $sth  = $class->getDbHandler()->prepare($sql);

    foreach my $user_item ( map { new Anothark::Item::UserItem( $_ ) }  @{ $entries } )
    {
        my $item_id = $user_item->getItemId();
        my $sep_num = $targets->{$item_id};
# check data size
        if ( $sep_num > 0 && $user_item->getMergedNumber() > $sep_num )
        {
# decrement
            $sth_update_record->execute( ( $user_item->getMergedNumber() - $sep_num ), 0, $user_id, $item_id );
            $sth->execute($user_id,$sep_num,$user_item->getItemMasterId());
        }
        else
        {
# Do not anything.
            $sth_update_record->execute( ( $user_item->getMergedNumber() ), 0, $user_id, $item_id );
        }
    }
    $sth_update_record->finish();
    $sth->finish();
}

sub rejectItem
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $item_id = shift;
    $class->debug("Inner user_id[" . $class->getUserId() . "]");

    my $sql = "UPDATE t_user_item SET delete_flag = 1 WHERE user_id = ? AND item_id = ?";

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($user_id,$item_id));
    $sth->finish();
}


sub sellItem
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $item_id = shift;
    $class->debug("Inner user_id[" . $class->getUserId() . "]");

    my $sql = "UPDATE t_user_money AS um JOIN t_user_item AS ui USING( user_id ) JOIN t_item_master AS im USING( item_master_id ) SET ui.delete_flag = 2, um.vel = um.vel + ( im.item_selling_price * ui.merged_number ) WHERE um.user_id = ? AND ui.item_id = ?";

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($user_id,$item_id));
    $sth->finish();
}




sub updateExp
{
    my $class = shift;
#    my $user_id = shift;
    my $user_id = $class->getUserId();
    my $exp_values = shift;
    $class->debug("Inner user_id[" . $class->getUserId() . "]");

    my $sql = "INSERT INTO t_user_exp(user_id, type_id, exp) VALUES (?,?,?) ON DUPLICATE KEY UPDATE exp = exp + VALUES(exp);";
#    my $sql = "UPDATE t_user_money AS um JOIN t_user_item AS ui USING( user_id ) JOIN t_item_master AS im USING( item_master_id ) SET ui.delete_flag = 2, um.vel = um.vel + im.item_selling_price WHERE um.user_id = ? AND ui.item_id = ?";

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat;
    foreach my $type_id ( sort keys %{$exp_values}  )
    {
        $stat = $sth->execute(($user_id, $type_id, $exp_values->{$type_id }));
    }
    $sth->finish();
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
