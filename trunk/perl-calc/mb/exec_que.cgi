#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->setPageUtil($pu);

my $ad_str = "";

my $db = DbUtil::getDbHandler();

our $out = $at->setOut( {
    NAME  => "ゲスト",
    MSG   => "よろしくおねがいします",
    BRD   => "",
    PLACE => "彼の庭",
    GOLD  => 120327,
    FACE  => 0,
    HAIR  => 0,
    V_HP  => 100,
    V_MHP => 100,
    V_CON => "0&nbsp;&nbsp;",
    V_ATK => "89&nbsp;",
    V_MAG => "0&nbsp;&nbsp;",
    V_DEF => "60&nbsp;",
    V_AGL => "55&nbsp;",
    V_KHI => "100",
    V_SNC => "100",
    V_LUK => "100",
    V_HMT => "100",
    V_CHR => "100",
});




my $base_dir = "/home/users/2/ciao.jp-anothark/web";
my $dp = "$base_dir/data";
my $t  = "$dp/anothark";

$at->setBase("$t/template.html");
$at->setBody("$t/body_result.html");

$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );

$at->setPageName("リザルト");
my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();

$pu->output_log("Start que.");




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();



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
$pu->output_log($booking_sth->execute(($seq_id++, $carrier_id, $mob_uid)));
my $log_id = $db->{'mysql_insertid'};

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

my $insert_prepost = "
INSERT INTO t_result_log (result_log_id,user_id,result_id,wday,hour,sequence_id,result_text)
SELECT
    ?,
    u.user_id ,
    r.result_id,
    WEEKDAY(NOW()),
    HOUR(NOW()),
    ?,
    t.result_text
FROM
    t_user AS u
    JOIN t_user_status AS s USING(user_id)
    JOIN t_result_master AS r ON ( r.node_id = ? )
    JOIN t_result_text AS t ON ( r.result_id = t.result_id AND t.result_position = ? ) WHERE u.carrier_id = ? AND u.uid = ? ";

$pu->output_log("SQL [$insert_prepost]");
my $result_sth = $db->prepare( $insert_prepost );
$pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id,$nnid,'pre',$carrier_id, $mob_uid)));
my $affected = $result_sth->execute(($log_id,$seq_id,$nnid,'pre',$carrier_id, $mob_uid));
$pu->output_log("insert result[$affected]");
$seq_id++ if ( $affected && $affected ne "0E0" );
$pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );



my $battle_html = doBattle();





$pu->output_log("SQL [$insert_prepost]");
$pu->output_log(sprintf "Value [%s]",join("/",($log_id,$seq_id,$nnid,'post',$carrier_id, $mob_uid)));
$affected = $result_sth->execute(($log_id,$seq_id,$nnid,'post',$carrier_id, $mob_uid));
$pu->output_log("insert result[$affected]");
$seq_id++ if ( $affected && $affected ne "0E0" );
$pu->output_log("SQL error[" . $result_sth->errstr . "]") if ( $affected eq "" );
$result_sth->finish();

## Main

my $sth  = $db->prepare("SELECT REPLACE(r.result_text,'<_NAME_>',b.user_name) AS result FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_result_log r USING( user_id ) JOIN  t_result_master m USING(result_id) WHERE b.carrier_id = ? AND b.uid = ? ORDER BY r.result_log_id DESC LIMIT 1");
#my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp,n.node_name FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();






if ( ! $sth->rows() > 0 )
{
    exit;
}
$sth->finish();



# change user_status for flag;
my $up_sth = $db->prepare("UPDATE t_user AS u JOIN t_user_status AS s USING(user_id) JOIN  t_selection_que AS q  USING(user_id) JOIN t_selection AS sel USING(selection_id)  SET s.node_id = sel.next_node_id, s.next_queing_hour = date_format( CONCAT('1970-01-01 ',q.queing_hour,':00:00') + interval 8 hour, '\%H' )  WHERE u.carrier_id = ? AND u.uid = ? ");
$pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
$up_sth->finish();




$out->{RESULT} = $row->{result};
$out->{RESULT} =~ s/\n/<br \/>\n/g;
$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();

$pu->output_log("End que.");




exit;

sub doBattle
{
    return "UNDER CONSTRUCTION!";
}
