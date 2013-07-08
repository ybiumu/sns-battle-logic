#!/usr/bin/perl
#
# 愛
#

use lib qw( .htlib ../.htlib );
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


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";

my $c = new CGI();

# Init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


$at->setBody("body_result.html");
$at->setPageName("DEBUG:処理実行");
my $version = "0.1a20120328";


my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

$pu->output_log("Start que.");

our $out = $at->getOut();



$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();







############
### Main ###
############

my $select_result_summary = "
SELECT
    r.result_id AS result_id,
    r.enemy_group_id AS enemy_group_id,
    sel.next_node_id AS next_node_id
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_selection_que AS q USING(user_id)
    JOIN t_selection AS sel USING(selection_id)
    JOIN t_result_master AS r ON ( r.node_id = sel.next_node_id )
WHERE u.carrier_id = ? AND u.uid = ? ";

my $rs_sth = $db->prepare( $select_result_summary );
$pu->output_log($rs_sth->execute(($carrier_id, $mob_uid)));

my $rs_row  = $rs_sth->fetchrow_hashref();
if ( ! $rs_sth->rows() > 0 )
{
    exit;
}

my $rid  = $rs_row->{result_id};
my $egid = $rs_row->{enemy_group_id};
my $nnid = $rs_row->{next_node_id};
$rs_sth->finish();

$pu->output_log("result summary [$rid/$egid/$nnid]");

my $seq_id = 0;
# log_idの予約
my $bookin_log_id = "
INSERT INTO t_result_log (user_id, wday,hour, sequence_id )
SELECT
    u.user_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?
FROM
    t_user AS u
WHERE
    u.carrier_id = ? AND u.uid = ?
";
$pu->output_log("SQL [$bookin_log_id]");
my $booking_sth = $db->prepare( $bookin_log_id );
$pu->output_log(sprintf "Value [%s]",join("/",($seq_id,$carrier_id, $mob_uid)));
my $booking_result = $booking_sth->execute(($seq_id++, $carrier_id, $mob_uid));
$pu->output_log(sprintf("Booking result [%s]",$booking_result));
my $log_id = $db->{'mysql_insertid'};

$booking_sth->finish();

if (! $booking_result )
{

    $at->Error();
    $at->{out}->{RESULT} = "結果処理出来ません。<br />結果処理は1時間に1回です";
    $db->disconnect();

    $at->setup();
    $at->output();
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


    my $ins_pre = "";
    my $ins_post = "";
    my $insert_prepost = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    CONCAT(?,t.result_text,?) AS result_text
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.node_id = ? )
    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";

    my $result_sth = $db->prepare( $insert_prepost );
    my $affected = "";

    $pu->output_log("SQL [$insert_prepost]");
    $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'pre',$carrier_id, $mob_uid)));
    $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'pre',$carrier_id, $mob_uid));
    $pu->output_log("insert result[$affected]");
    $seq_id++ if ( $affected && $affected ne "0E0" );
    $pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );









##############
### Battle ###
##############
    my $battle = new Anothark::Battle( $pu );
    my $me = $at->getCharacterByUserId($out->{USER_ID});
    my $battle_html = Anothark::Battle::Exhibition::doExhibitionMatch( $battle, $me );









    my $insert_battle = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    ? AS result_text
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.node_id = ? )
    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";

    my $result_sth_b = $db->prepare( $insert_battle );
    my $affected_b = "";

    $pu->output_log("SQL [$insert_battle]");
    $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $battle_html, ,$nnid,'battle',$carrier_id, $mob_uid)));
    $affected_b = $result_sth_b->execute(($log_id,$seq_id, $battle_html ,$nnid,'battle',$carrier_id, $mob_uid));
    $pu->output_log("insert result[$affected_b]");
    $seq_id++ if ( $affected_b && $affected_b ne "0E0" );
    $pu->output_log("SQL error[" . $result_sth_b->errstr . "]") if ( $affected_b eq "" );





my $update_win_node_sql = "
UPDATE
    t_user AS u
    JOIN
    t_user_status AS s
    USING(user_id)
    JOIN
    t_selection_que AS q
    USING(user_id)
    JOIN
    t_selection AS sel
    USING(selection_id)
    LEFT JOIN
    t_node_master AS nm
    ON( sel.next_node_id = nm.node_id )
SET
    s.node_id = sel.next_node_id,
    s.last_link_node = CASE
                       WHEN nm.node_id IS NOT NULL AND nm.use_link = 1
                       THEN
                           sel.next_node_id
                       ELSE
                           s.last_link_node
                       END,
    s.next_queing_hour = date_format( CONCAT('1970-01-01 ',HOUR(now()),':00:00') + interval 8 hour, '\%H' )
WHERE
    u.carrier_id = ?
    AND
    u.uid = ? 
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
    u.carrier_id = ?
    AND
    u.uid = ? 
";


###################
### Post Result ###
###################
    if ($battle->isWin())
    {
        $ins_pre = $battle->getResultText();


        $pu->output_log("SQL [$insert_prepost]");
        $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid)));
        $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid));
        $pu->output_log("insert result[$affected]");
        $seq_id++ if ( $affected && $affected ne "0E0" );
        $pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );





# change user_status for flag;
        my $up_sth = $db->prepare($update_win_node_sql);
        $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
        $up_sth->finish();





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

#    $up_sth->prepare($flag_update);
#
#    $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
#    $up_sth->finish();
    }
    elsif( $battle->isDraw() )
    {
# change user_status for flag;
        my $up_sth = $db->prepare( $rollback_node_sql );
        $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
        $up_sth->finish();
    }
    else
    {
# change user_status for flag;
        my $up_sth = $db->prepare( $rollback_node_sql );
        $pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
        $up_sth->finish();
    }


    $result_sth->finish();
## Main





    $up_sth = $db->prepare("REPLACE INTO t_selection_que(user_id,selection_id,queing_hour,qued)  SELECT u.user_id, 0, s.next_queing_hour, 0 FROM t_user AS u JOIN t_user_status AS s USING(user_id) WHERE u.carrier_id = ? AND u.uid = ? ");
    $up_sth->execute($carrier_id, $mob_uid);
    $up_sth->finish();

    $db->disconnect();

    $pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
    print $c->redirect("recent_text.cgi?guid=ON");    

    $pu->output_log("End que.");

}




exit;

