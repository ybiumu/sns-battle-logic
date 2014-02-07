package Anothark::Character::StatusIO;
#
# ˆ¤
#
$|=1;
use strict;

use LoggingObjMethod;
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
    my $item_id = shift;
    my $count   = shift || 1;

    $class->debug("Inner user_id[" . $class->getUserId() . "]");

    my $sql = "
INSERT INTO t_user_item (user_id, item_master_id)
SELECT
    ? AS user_id,
    item_master_id
FROM
    t_item_master
WHERE
    item_master_id = ?
";

    my $sth  = $class->getDbHandler()->prepare($sql);
    for ( my $i = 0 ; $i < $count ; $i++)
    {
        my $stat = $sth->execute(($user_id,$item_id));
    }
    $sth->finish();

#    return $item; 
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

    my $sql = "UPDATE t_user_money AS um JOIN t_user_item AS ui USING( user_id ) JOIN t_item_master AS im USING( item_master_id ) SET ui.delete_flag = 2, um.vel = um.vel + im.item_selling_price WHERE um.user_id = ? AND ui.item_id = ?";

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
