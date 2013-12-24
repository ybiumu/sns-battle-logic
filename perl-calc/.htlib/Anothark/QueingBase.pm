package Anothark::QueingBase;
#
# 愛
#
$|=1;
use strict;

use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
use DbUtil;
use MobileUtil;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
use Anothark::Battle::Exhibition;
use Anothark::Character;
use Anothark::Skill;

use LoggingObjMethod;
use base qw( LoggingObjMethod );
sub new
{
    my $class   = shift;
    my $at = shift;
    my $self = $class->SUPER::new();
    bless $self, $class;
    $self->setAt($at);
    return $self;
}




my $force = 0;
sub setForce
{
    my $class = shift;
    return $class->setAttribute( 'force', shift );
}

sub getForce
{
    return $_[0]->getAttribute( 'force' );
}


my $at = undef;
sub setAt
{
    my $class = shift;
    return $class->setAttribute( 'at', shift );
}

sub getAt
{
    return $_[0]->getAttribute( 'at' );
}



# loop before
# XXX REMEBER XXX
# append optimization for result!
# 留まった場合のリザルトの取り出し方追加
# 選択をしなかった場合は留まるが、結合条件がなくなるのでLEFT JOIN
#
our $select_result_summary = "
SELECT
    IFNULL(r.result_id, rc.result_id) AS result_id,
    IFNULL(r.enemy_group_id, rc.enemy_group_id) AS enemy_group_id,
    IFNULL(NULLIF(sel.next_node_id,0), s.node_id ) AS next_node_id
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    LEFT JOIN t_selection AS sel USING(selection_id)
    LEFT JOIN (
        t_user_flagment AS f
        LEFT JOIN
        t_result_master AS r
        ON ( f.flag_id = r.flag_id )
    ) ON ( f.user_id = u.user_id AND r.node_id = sel.next_node_id )
    LEFT JOIN (
        t_user_flagment AS fc
        LEFT JOIN
        t_result_master AS rc 
        ON ( fc.flag_id = rc.flag_id )
    ) ON ( fc.user_id = u.user_id AND rc.node_id = s.node_id )
WHERE u.user_id = ?
ORDER BY r.priority DESC, r.result_id DESC,rc.priority DESC,rc.result_id DESC LIMIT 1"
;

#SELECT
#    IFNULL(r.result_id, rc.result_id) AS result_id,
#    IFNULL(r.enemy_group_id, rc.enemy_group_id) AS enemy_group_id,
#    IFNULL(NULLIF(sel.next_node_id,0), s.node_id ) AS next_node_id
#FROM
#    t_user AS u
#    JOIN t_user_status AS s USING(user_id)
#    JOIN t_selection_que AS q USING(user_id)
#    LEFT JOIN t_selection AS sel USING(selection_id)
#    LEFT JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
#    JOIN t_result_master AS rc ON ( rc.node_id = s.node_id )
#WHERE u.user_id = ? ";


our $bookin_log_id = "
INSERT INTO t_result_log (user_id, wday,hour, sequence_id, memo )
SELECT
    u.user_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    'for bokking batch'
FROM
    t_user AS u
WHERE
    u.user_id = ?
";

our $clear_current_result_sql = "
DELETE
    r
FROM
    t_result_log AS r
    JOIN
    t_user AS u
    USING(user_id)
WHERE
    u.user_id = ?
    AND
    r.wday = WEEKDAY(NOW())
    AND
    r.hour = HOUR(NOW())
";

our $insert_prepost = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text,memo)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    CONCAT(?,IFNULL(t.result_text,\"\"),?) AS result_text,
    'for prepost batch'
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.result_id = ? AND r.node_id = ? )
    LEFT JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? )
WHERE u.user_id = ? ";

our $flag_update = "
INSERT INTO t_user_flagment(user_id,flag_id,enable)
VALUES
    SELECT
        user_id,
        append_flag_id,
        1,
    FROM
        t_flag_append
        LEFT JOIN
        t_user_flagment AS u ON (append_flag_id = u.flag_id AND u.user_id = ? )
    WHERE
        node_id = ?
        AND
        event_id = ?
";




### BUGBUG
our $update_win_node_sql = "
UPDATE
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    LEFT JOIN t_selection AS sel ON( q.selection_id = sel.selection_id )
    LEFT JOIN t_node_master AS nm ON( sel.next_node_id = nm.node_id )
SET
    s.node_id = CASE WHEN nm.can_stay = 1 THEN IFNULL(NULLIF(sel.next_node_id,0), s.node_id ) ELSE s.node_id END,
    s.last_link_node = CASE
                       WHEN nm.node_id IS NOT NULL AND nm.use_link = 1
                       THEN
                           IFNULL(NULLIF(sel.next_node_id,0), s.node_id )
                       ELSE
                           s.last_link_node
                       END,
    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
WHERE
    u.user_id = ?
";


our $rollback_node_sql = "
UPDATE
    t_user AS u
    JOIN
    t_user_status AS s
    USING(user_id)
SET
    s.node_id = s.last_link_node,
    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
WHERE
    u.user_id = ?
";




our $update_que_sql = "
REPLACE INTO
    t_selection_que(user_id,selection_id,queing_hour,qued)
SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.user_id = ? ";


our $insert_battle = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text,memo)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    ? AS result_text,
    'for battle batch'
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.result_id = ? AND r.node_id = ? )
    LEFT JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.user_id = ?";

























our $booking_sth;
our $result_sth;
our $rs_sth;
our $up_win_sth;
our $up_rollback_sth;
our $up_que_sth;
our $result_sth_b;
our $clear_current_result_sth;

sub doQueing
{

    my $last_status = 0;
    my $class  = shift;
    my $at     = $class->getAt();
    my $pu     = $at->getPageUtil();
    my $db     = $at->getDbHandler();
    my $rs_row = shift;

    foreach my $user_id ( @{$rs_row} )
    {

        $last_status = 0;
        $pu->notice("Target user id[$user_id->[0]]");
        $pu->notice($rs_sth->execute(($user_id->[0])));
        my $rsum_row  = $rs_sth->fetchrow_hashref();
        if ( ! $rs_sth->rows() > 0 )
        {
            next;
        }

        my $rid  = $rsum_row->{result_id};
        my $egid = $rsum_row->{enemy_group_id};
        my $nnid = $rsum_row->{next_node_id};
        $pu->notice("result summary [$rid/$egid/$nnid]");


        my $seq_id = 0;
        my $ins_pre = "";
        my $ins_post = "";
# log_idの予約
        my $affected = "";

        # 強制フラグ
        if ( $class->getForce() )
        {
            $pu->notice("Force queing.");
            $pu->notice("Clear duplicace result.[$user_id->[0]]");
            my $clear_result = $clear_current_result_sth->execute( ($user_id->[0]) );
            $pu->notice("Clear result.[$clear_result]");
        }

        $pu->notice(sprintf "Value [%s]",join("/",($seq_id,$user_id->[0])));
        my $booking_result = $booking_sth->execute(($seq_id, $user_id->[0]));
        $seq_id = 1;
        $pu->notice(sprintf("Booking result [%s]",$booking_result));
        my $log_id = $db->{'mysql_insertid'};

        if (! $booking_result )
        {
            $pu->warning(sprintf("Can't queing user_id[%s]",$user_id->[0]));
            $last_status = 2;
            next;
        }
        else
        {

# 本当はnodeに紐付いたイベントも結合して、優先順位の高いイベントから処理するようにしないといけない
# insert result;
#my $insert_prepost = "
#INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,sequence_id,result_text)
#SELECT
#    ?,
#    u.user_id ,
#    r.result_id,
#    WEEKDAY(NOW()),
#    ?,
#    t.result_text
#FROM
#    t_user AS u
#    JOIN t_user_status AS s USING(user_id)
#    JOIN t_selection_que AS q USING(user_id)
#    JOIN t_selection AS sel USING(selection_id)
#    JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
#    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";


# next_node_idで発生するイベントの検索
#
# SELECT * FROM t_event_master JOIN t_flag_append USING(event_id) LEFT JOIN t_user_flagment AS u ON (append_flag_id = u.flag_id AND u.user_id = 1 ) WHERE node_id = 2 AND u.user_id IS NULL
#ORDER BY priority LIMIT 1;


            $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$rid,$nnid,'pre',$user_id->[0]));
            $pu->notice("insert result[$affected]");
#        $seq_id++ if ( $affected && $affected ne "0E0" );
            $seq_id = 2;
            $pu->error("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" || $affected eq "0E0");


            ## TODO flagment pre







##############
### Battle ###
##############
            if ( $egid > 0 )
            {
                my $battle = new Anothark::Battle( $at );
                my $me = $at->getPlayerByUserId($user_id->[0]);
                my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me, $nnid );





                my $affected_b = "";
                $pu->notice("SQL battle [$insert_battle]");
                $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $battle_html ,$rid ,$nnid,'battle',$user_id->[0])));
                $affected_b = $result_sth_b->execute(($log_id,$seq_id, $battle_html ,$rid,$nnid,'battle',$user_id->[0]));
                $pu->notice("insert result[$affected_b]");
#        $seq_id++ if ( $affected_b && $affected_b ne "0E0" );
                $seq_id = 3;
                $pu->error("SQL error[" . $result_sth_b->errstr . "]") if ( $affected_b eq "" || $affected eq "0E0" );






################################
### Post Result after battle ###
################################
                if ($battle->isWin())
                {
                    $ins_pre = $battle->getResultText();

                    my $drops   = $battle->checkDropItems();
                    my $chk_exp = $battle->checkExperiment();
                    my $party   = $battle->getPartyMember();


                    $ins_pre .= $chk_exp;
                    foreach my $items ( @{$drops} )
                    {
                        my $target = $party->[int(rand(scalar(@{$party})))];
#        $class->warning( sprintf( "[DROP R] %s", $items->getItemLabel()));
                        $ins_pre .= sprintf('<br />☆%sは%sを手に入れた!', $target->getName(),$items->getItemLabel());
                        $target->getStatusIo()->getItem( $target->getId(), $items->getItemMasterId() );
                    }
                    $ins_pre .= "<br /><br />" if(scalar(@{$drops}));

                    $pu->notice("SQL prepost [$insert_prepost]");
                    $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$user_id->[0])));
                    $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$user_id->[0]));
                    $pu->notice("insert result[$affected]");
#            $seq_id++ if ( $affected && $affected ne "0E0" );
                    $seq_id = 4;
                    $pu->error("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" || $affected eq "0E0" );





# change user_status for flag;
                    $pu->notice("Win status: " . $up_win_sth->execute(($user_id->[0])));
#       $pu->notice($up_sth->execute(($carrier_id, $mob_uid)));


                }
                elsif( $battle->isDraw() )
                {
# change user_status for flag;
                    $pu->notice("Draw status: " . $up_rollback_sth->execute(($user_id->[0])));
                }
                else
                {
# change user_status for flag;
                    $pu->notice("Other status: " .$up_rollback_sth->execute(($user_id->[0])));
                }


            }
            else
            {
                $pu->notice("SQL prepost [$insert_prepost]");
                $pu->notice(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$user_id->[0])));
                $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post,$rid ,$nnid,'post',$user_id->[0]));
                $pu->notice("insert result[$affected]");
#            $seq_id++ if ( $affected && $affected ne "0E0" );
                $seq_id = 3;
                $pu->error("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" || $affected eq "0E0" );
            }


            $pu->notice("Update next que status: " . $up_que_sth->execute($user_id->[0]));


            $pu->notice("End que.");
        }
    }
    return $last_status;
}


sub openMainSth
{
    my $class = shift;
    my $db    = $class->getAt()->getDbHandler();


    $result_sth = $db->prepare( $insert_prepost );
    $rs_sth = $db->prepare( $select_result_summary );
    $up_que_sth = $db->prepare( $update_que_sql );
    $up_win_sth = $db->prepare($update_win_node_sql);
    $up_rollback_sth = $db->prepare( $rollback_node_sql );
    $booking_sth = $db->prepare( $bookin_log_id );
    $result_sth_b = $db->prepare( $insert_battle );
    if ( $class->getForce() )
    {
        $clear_current_result_sth = $db->prepare($clear_current_result_sql);
    }
}

sub finishMainSth
{
    $result_sth->finish();
    $rs_sth->finish();
    $up_que_sth->finish();
    $up_win_sth->finish();
    $up_rollback_sth->finish();
    $booking_sth->finish();
    $result_sth_b->finish();
    if ( defined $clear_current_result_sth )
    {
        $clear_current_result_sth->finish();
    }
}


1;
