package Anothark::FollowingManager;
#
# 愛
#
$|=1;
use strict;
use Encode;
use Anothark::BaseLoader;
use Anothark::Character::StatusIO;
use base qw( Anothark::BaseLoader );

=pod
    delete_flag
        0: follow
        1: block/cancel
        2: blacklist
=cut

my $sql_get_follow_request = "
SELECT
    main.user_id,
    main.follow_user_id,
    u.user_name
FROM
    (
        t_follows AS main
        LEFT JOIN
        t_follows AS rev
        ON (
            main.user_id = rev.follow_user_id
            AND main.follow_user_id = rev.user_id
            AND main.delete_flag = rev.delete_flag
        )
    )
    JOIN
    t_user AS u
    ON ( u.user_id = main.follow_user_id )
WHERE
    main.user_id = ?
    AND
    main.delete_flag = 0 
    AND
    rev.user_id IS NULL
ORDER BY
    main.follow_user_id
";

my $do_follow_sql = "
    INSERT INTO t_follows( follow_user_id, user_id ) VALUES ( ?, ? )
        ON DUPLICATE KEY UPDATE delete_flag = 0;
";

my $clear_follow_sql = "
    INSERT INTO t_follows( follow_user_id, user_id ) VALUES ( ?, ? )
        ON DUPLICATE KEY UPDATE delete_flag = 1;
";

my $blacklist_sql = "
    INSERT INTO t_follows( follow_user_id, user_id ) VALUES ( ?, ? )
        ON DUPLICATE KEY UPDATE delete_flag = 2;
";


sub new
{
    my $class = shift;
    my $db_handle = shift;
    my $self = $class->SUPER::new( $db_handle );
    bless $self, $class;


    my $sth  = $db_handle->prepare($sql_get_follow_request);
    $self->setSthRequest($sth);

    return $self;
}

sub checkFollowStatus
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    my $sql = "
        SELECT
            1 + IF(rev.user_id IS NULL,0,1) AS result
        FROM
            t_follows AS main
            LEFT JOIN
            t_follows AS rev
            ON (
                main.user_id = rev.follow_user_id
                AND main.follow_user_id = rev.user_id
                AND main.delete_flag = rev.delete_flag
            )
        WHERE
            main.user_id = ?
            AND
            main.follow_user_id = ? 
            AND
            main.delete_flag <> 1
    ";

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($src_user_id, $dst_user_id));
    my $row  = $sth->fetchrow_hashref();
    if ( $sth->rows() == 0 )
    {
        $class->notice("No relation between $src_user_id and $dst_user_id.");
        $sth->finish();
        return 0;
    }
    else
    {
        $sth->finish();
        return $row->{result};
    }
}

sub isFollowed
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    return $class->checkFollowStatus( $dst_user_id, $src_user_id );
}

sub isFollowing
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    return $class->checkFollowStatus( $src_user_id, $dst_user_id );
}

sub getFollowingList
{
}

sub getFollowRequest
{
    my $class = shift;
    my $src_user_id = shift;
#    my $dst_user_id = shift;

    my $sth  = $class->getSthRequest();
    my $stat = $sth->execute(($src_user_id));
    my $rows  = $sth->fetchall_arrayref( +{} );
    return $rows;
}

sub getFollowRequestNumber
{
    my $class = shift;
    my $src_user_id = shift;
#    my $dst_user_id = shift;

    my $sth  = $class->getSthRequest();
    my $stat = $sth->execute(($src_user_id));
    my $row  = $sth->fetchrow_hashref();
    return $sth->rows();
}

sub doFollowRequest
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    my $sql = $do_follow_sql;

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($src_user_id, $dst_user_id));
    if ( !$stat )
    {
        $class->notice("request error $src_user_id and $dst_user_id.");
        $sth->finish();
        return 0;
    }
    else
    {
        $sth->finish();
        return 1;
    }
}


sub acceptFollowRequest
{
    my $class = shift;
    return $class->doFollowRequest(@_);
}



sub clearFollowRequest
{
    my $class = shift;
    my $src_user_id = shift;
    my $dst_user_id = shift;
    my $sql = $clear_follow_sql;

    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute(($src_user_id, $dst_user_id));
    if ( !$stat )
    {
        $class->notice("request error $src_user_id and $dst_user_id.");
        $sth->finish();
        return 0;
    }
    else
    {
        $sth->finish();
        return 1;
    }
}


sub rejectFollowRequest
{
    my $class = shift;
    my $dst_user_id = shift;
    my $src_user_id = shift;
    return $class->clearFollowRequest( $dst_user_id, $src_user_id);
}



my $sth_request = undef;

sub setSthRequest
{
    my $class = shift;
    return $class->setAttribute( 'sth_request', shift );
}

sub getSthRequest
{
    return $_[0]->getAttribute( 'sth_request' );
}


1;
