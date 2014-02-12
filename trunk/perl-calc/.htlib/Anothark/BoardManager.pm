package Anothark::BoardManager;
#
# ˆ¤
#
$|=1;
use strict;
use Encode;
use Anothark::TextFilter;
use LoggingObjMethod;
use DBI qw( SQL_INTEGER );
use base qw( LoggingObjMethod );

use constant BOARD_TYPE_NAME => {
    "1" => "Ï²BBS",
    "2" => "Êß°Ã¨°BBS",
    "3" => "’nˆæBBS",
    "4" => "”„”ƒBBS",
};

my $status = undef;

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
my $board_id = undef;
my $max_row = undef;
##################
# Methods
##################
=pod
getOwnersBoard(type_id,owner_id)
writeBoard(board_id,user_id,message)
readBoard(board_id,page_id )
SELECT SQL_CALC_FOUND_ROWS last_update, user_name, message FROM t_boards JOIN t_user USING(user_id) WHERE board_id = ? LIMIT 10 OFFSET 1 + ( 10 * ? )
=cut

sub getOwnersBoard
{
    my $class = shift;
    my $type_id = shift;
    my $user_id = shift;
    my $target_user_id = shift;

    my $sql;
    my $board_id = undef;
    my @params;

    if ( $type_id == 1 )
    {
        $sql = "SELECT b.board_id FROM t_board_map AS b JOIN ( SELECT tu.user_id FROM  t_user AS tu LEFT JOIN t_follows AS f USING(user_id) WHERE tu.user_id = ? AND ( tu.user_id = ? OR tu.bbs_read = 2 OR ( tu.bbs_read = 1 AND  f.follow_user_id = ? ) ) ) AS u ON ( b.owner_id = u.user_id ) WHERE b.board_type_id = ? ";
        @params = ($target_user_id, $user_id, $user_id, $type_id);
    }
    elsif ( $type_id == 2 )
    {
        $sql = "SELECT b.board_id FROM t_board_map AS b JOIN ( SELECT tu.user_id FROM  t_user AS tu LEFT JOIN t_follows AS f USING(user_id) WHERE tu.user_id = ? AND ( f.follow_user_id = ? OR tu.user_id = ? )  ) AS u ON ( b.owner_id = u.user_id ) WHERE b.board_type_id = ? ";
        @params = ($target_user_id, $user_id, $user_id, $type_id);
    }
    elsif ( grep { $type_id == $_ } (3,4) )
    {
        $sql = "SELECT b.board_id FROM t_board_map AS b JOIN ( t_user_status AS u JOIN t_node_master n USING( node_id ) )  ON ( b.owner_id = n.parent_node_id ) WHERE u.user_id = ? AND b.board_type_id = ? ";
        @params = ($user_id, $type_id);
    }
    else
    {
        $class->fatal("Unknown type_id [$type_id]");
        return $board_id;
    }


    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute((@params));
    if ( $sth->rows > 0 )
    {
#        $shop_list = $sth->fetchall_hashref(("shop_id"));
        $board_id = $sth->fetchrow_hashref()->{board_id};
    }
    $sth->finish();

    return $board_id;
}

sub readBoard
{
    my $class = shift;
    my $board_id = shift;
    my $page_id = shift || 0;
    my $thread_id = shift || 0;

    if ( $thread_id )
    {
        $class->readBoardOne($board_id, $thread_id);
    }
    else
    {

        my $sql = "SELECT SQL_CALC_FOUND_ROWS b.thread_id, b.last_update, b.user_id, u.user_name, b.message FROM t_boards AS b JOIN t_user AS u USING(user_id) WHERE b.board_id = ? ORDER BY b.thread_id DESC LIMIT 10 OFFSET ?";


        my $sth  = $class->getDbHandler()->prepare($sql);
        $sth->bind_param(1, $board_id, { TYPE => SQL_INTEGER} );
        $sth->bind_param(2, (0 + 10 * $page_id), { TYPE => SQL_INTEGER} );
        my $stat = $sth->execute();
        my $sth_rows  = $class->getDbHandler()->prepare("SELECT FOUND_ROWS() FROM DUAL");
        $sth_rows->execute();
        my $row_size = $sth_rows->fetchrow_array();
        my $entries = $sth->fetchall_arrayref( +{} );
        $sth_rows->finish();
        $sth->finish();

        $class->setMaxRow( $row_size );

        return $entries;
    }
}


sub readMyBoardOne
{
    my $class    = shift;
    my $user_id  = shift;
    my $target_user_id  = shift;
    my $board_id = $class->getOwnersBoard(1,$user_id,$target_user_id);

    return $class->readBoardOne( $board_id );
#    my $page_id  = shift || 0;
#
#    my $sql = "SELECT b.last_update, u.user_name, b.message FROM t_boards AS b JOIN t_user AS u USING(user_id) WHERE b.board_id = ? ORDER BY b.thread_id DESC LIMIT 1";
#
#
#    my $sth  = $class->getDbHandler()->prepare($sql);
#    my $stat = $sth->execute(($board_id));
#    my $entries = $sth->fetchall_arrayref( +{} );
#    $sth->finish();
#
#    return $entries;

}



sub readBoardOne
{
    my $class    = shift;
    my $board_id  = shift;
    my $thread_id  = shift || 0;
    my @params;

    my $sql;
    if ( $thread_id )
    {
        $sql = "SELECT b.thread_id, b.last_update, u.user_name, b.message FROM t_boards AS b JOIN t_user AS u USING(user_id) WHERE b.board_id = ? AND b.thread_id = ? ORDER BY b.thread_id DESC LIMIT 1";
        @params = ($board_id,$thread_id);
    }
    else
    {
        $sql = "SELECT b.thread_id, b.last_update, u.user_name, b.message FROM t_boards AS b JOIN t_user AS u USING(user_id) WHERE b.board_id = ? ORDER BY b.thread_id DESC LIMIT 1";
        @params = ($board_id);
    }


    my $sth  = $class->getDbHandler()->prepare($sql);
    my $stat = $sth->execute((@params));
    my $entries = $sth->fetchall_arrayref( +{} );
    $sth->finish();

    return $entries;

}

sub writeBoard
{
    my $class = shift;
    my $board_id = shift;
    my $user_id  = shift;
    my $message  = shift;

    my $filter   = new Anothark::TextFilter();

    $message = $filter->optimize($message);
    if ( $filter->match($message) )
    {
        $class->setErrMsg("Fatal strings are included in message!");
    }
    else
    {

        my $sql = "INSERT INTO t_boards( board_id, user_id, message, segment ) VALUES ( ?, ?, ?, YEAR(now()) * 100 + MONTH(now()) )";
        my $sth  = $class->getDbHandler()->prepare($sql);
        my $stat = $sth->execute(($board_id, $user_id, $message));
        $sth->finish();

    }

    return $class->readBoard($board_id);

}


my $err_msg = undef;
sub setErrMsg
{
    my $class = shift;
    return $class->setAttribute( 'err_msg', shift );
}

sub getErrMsg
{
    return $_[0]->getAttribute( 'err_msg' );
}



sub setMaxRow
{
    my $class = shift;
    return $class->setAttribute( 'max_row', shift );
}

sub getMaxRow
{
    return $_[0]->getAttribute( 'max_row' );
}



sub setBoardId
{
    my $class = shift;
    return $class->setAttribute( 'board_id', shift );
}

sub getBoardId
{
    return $_[0]->getAttribute( 'board_id' );
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
