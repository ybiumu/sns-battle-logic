#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use PageUtil;
use AaTemplate;
use Anothark::Battle;
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





#$at->setBase("template.html");
$at->setBody("body_result.html");

#$pu->setSystemLog( "aa_calc.log" );
#$pu->setAccessLog( "aa_access.log" );

$at->setPageName("DEBUG:処理実行");
my $version = "0.1a20120328";


my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

$pu->output_log("Start que.");

our $out = $at->getOut();



$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();




# Init
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}




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
#    $battle->setCharacter();
#    my $me = new Anothark::Character();
    my $me = $at->getCharacterByUserId($out->{USER_ID});
#    $me->setId( $out->{USER_ID} );
    $me->setSide("p");
    $battle->appendCharacter( $me );

    my $enemy = new Anothark::Character();
    $enemy->setId("load_king");
    $enemy->setName("ﾛｰﾄﾞ･ｵｳﾞ･ｼﾞｪﾑｽﾄｰﾝ");
    $enemy->getHp()->setBothValue(999);
    $enemy->setCmd([
        [],
        new Anothark::Skill( 'ﾑｰﾝｽﾄｰﾝﾗｲﾄ' ),
        new Anothark::Skill( 'ｴﾒﾗﾙﾄﾞｽﾌﾟﾗｯｼｭ' ),
        new Anothark::Skill( 'ﾙﾋﾞｰｽﾍﾟｸﾄﾙ' ),
        new Anothark::Skill( 'ﾀﾞｲﾔﾓﾝﾄﾞｸﾗｯｼｭ' ),
        new Anothark::Skill( 'ﾒﾃｵﾆｯｸ･ｼﾞｪﾑｽﾄｰﾑ' ),
    ]);
    $enemy->setSide("e");
    $battle->appendCharacter( $enemy );

    $battle->doBattle();

    my $battle_html = $battle->getBattleText();









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






###################
### Post Result ###
###################
    $ins_pre = $battle->getResultText();


    $pu->output_log("SQL [$insert_prepost]");
    $pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid)));
    $affected = $result_sth->execute(($log_id,$seq_id, $ins_pre, $ins_post ,$nnid,'post',$carrier_id, $mob_uid));
    $pu->output_log("insert result[$affected]");
    $seq_id++ if ( $affected && $affected ne "0E0" );
    $pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );


    $result_sth->finish();
## Main


#my $get_result_sql = "
#    SELECT
#        REPLACE(REPLACE(r.result_text,'<_NAME_>',b.user_name),'<_SELF_CALL_>',g.self_call) AS result
#    FROM
#        t_user AS b
#        JOIN
#        t_user_status s USING( user_id )
#        JOIN
#        t_result_log r USING( user_id )
#        JOIN
#        t_result_master m USING(result_id)
#        JOIN
#        t_gender_map g USING( gender )
#    WHERE
#        b.carrier_id = ?
#        AND
#        b.uid = ?
#    ORDER BY r.result_log_id,r.sequence_id DESC LIMIT 1
#";
#
#my $sth  = $db->prepare($get_result_sql);
##my $sth  = $db->prepare("SELECT REPLACE(r.result_text,'<_NAME_>',b.user_name) AS result FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_result_log r USING( user_id ) JOIN  t_result_master m USING(result_id) WHERE b.carrier_id = ? AND b.uid = ? ORDER BY r.result_log_id DESC LIMIT 1");
#my $stat = $sth->execute(($carrier_id, $mob_uid));
#my $row  = $sth->fetchrow_hashref();
#
#
#
#
#
#
#if ( ! $sth->rows() > 0 )
#{
#    exit;
#}
#$sth->finish();




# change user_status for flag;
    my $up_sth = $db->prepare("UPDATE t_user AS u JOIN t_user_status AS s USING(user_id) JOIN  t_selection_que AS q  USING(user_id) JOIN t_selection AS sel USING(selection_id)  SET s.node_id = sel.next_node_id, s.next_queing_hour = date_format( CONCAT('1970-01-01 ',q.queing_hour,':00:00') + interval 8 hour, '\%H' )  WHERE u.carrier_id = ? AND u.uid = ? ");
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


    $db->disconnect();

    $pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
    print $c->redirect("recent_text.cgi?guid=ON");    

    $pu->output_log("End que.");

}




exit;

