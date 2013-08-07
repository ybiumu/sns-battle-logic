#!/usr/bin/perl

#use lib qw( .htlib ../.htlib );
use lib qw( /home/users/2/ciao.jp-anothark/web/.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
use Anothark::Battle::Exhibition;
use Anothark::Character;
use Anothark::Skill;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);

$pu->setBoth(1);

my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";



my $hour = sprintf "%02s", (localtime())[2];
if ( scalar(@ARGV) && $ARGV[0] =~ /^([01][0-9]|2[0-3])$/  )
{
    $hour = sprintf "%02s", $ARGV[0]
}

$pu->notice("Start que at `$hour'.");




############
### Main ###
############

# 今の時間に処理するユーザーの検索
my $select_users = "SELECT user_id FROM t_selection_que WHERE queing_hour = ? AND qued = 0";
my $su_sth = $db->prepare( $select_users );
$pu->notice( "query status is " . $su_sth->execute(( $hour )) );

my $rs_row  = $su_sth->fetchall_arrayref();
if ( ! $su_sth->rows() > 0 )
{
    $su_sth->finish();
    $db->disconnect();
    $pu->notice(" QUEING: No target exists.");
    exit;
}
else
{
    $pu->notice(" QUEING: ". $su_sth->rows() ." targets exists.");
}

$su_sth->finish();


# loop before
# XXX REMEBER XXX
# append optimization for result!
my $select_result_summary = "
SELECT
    IFNULL(r.result_id, rc.result_id) AS result_id,
    IFNULL(r.enemy_group_id, rc.enemy_group_id) AS enemy_group_id,
    IFNULL(NULLIF(sel.next_node_id,0), s.node_id ) AS next_node_id
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    LEFT JOIN t_selection AS sel USING(selection_id)
    LEFT JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
    JOIN t_result_master AS rc ON ( rc.node_id = s.node_id )
WHERE u.user_id = ? ";


my $bookin_log_id = "
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

my $insert_prepost = "
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

my $flag_update = "
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





my $update_win_node_sql = "
UPDATE
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    LEFT JOIN t_selection AS sel USING(selection_id)
    LEFT JOIN t_node_master AS nm ON( sel.next_node_id = nm.node_id )
SET
    s.node_id = IFNULL(NULLIF(sel.next_node_id,0), s.node_id ),
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


my $rollback_node_sql = "
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




my $update_que_sql = "
REPLACE INTO
    t_selection_que(user_id,selection_id,queing_hour,qued)
SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.user_id = ? ";


my $insert_battle = "
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










my $booking_sth = $db->prepare( $bookin_log_id );
my $result_sth = $db->prepare( $insert_prepost );
my $rs_sth = $db->prepare( $select_result_summary );
my $up_win_sth = $db->prepare($update_win_node_sql);
my $up_rollback_sth = $db->prepare( $rollback_node_sql );
my $up_que_sth = $db->prepare( $update_que_sql );
my $result_sth_b = $db->prepare( $insert_battle );

#    $up_sth->prepare($flag_update);
#


# loop start
foreach my $user_id ( @{$rs_row} )
{

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

    $pu->notice(sprintf "Value [%s]",join("/",($seq_id,$user_id->[0])));
    my $booking_result = $booking_sth->execute(($seq_id, $user_id->[0]));
    $seq_id = 1;
    $pu->notice(sprintf("Booking result [%s]",$booking_result));
    my $log_id = $db->{'mysql_insertid'};

    if (! $booking_result )
    {
        $pu->warning(sprintf("Can't queing user_id[%s]",$user_id->[0]));
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










##############
### Battle ###
##############
        if ( $egid > 0 )
        {
            my $battle = new Anothark::Battle( $at );
            my $me = $at->getCharacterByUserId($user_id->[0]);
            my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me, $nnid );





            my $affected_b = "";
            $pu->notice("SQL [$insert_battle]");
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


                $pu->notice("SQL [$insert_prepost]");
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
            $pu->notice("SQL [$insert_prepost]");
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


$result_sth->finish();
$rs_sth->finish();
$up_que_sth->finish();
$up_win_sth->finish();
$up_rollback_sth->finish();
$booking_sth->finish();
#$up_sth->finish();

$db->disconnect();

exit;

