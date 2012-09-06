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
$at->setBody("$t/body_mypage.html");

$pu->setSystemLog( "$base_dir/.htlog/aa_calc.log" );
$pu->setAccessLog( "$base_dir/.htlog/aa_access.log" );

$at->setPageName("マイページ");
my $version = "0.1a20120328";

my $mu = new MobileUtil();

my $content_type = $mu->getContentType();
my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();


# que exec
my $up_sth = $db->prepare("UPDATE t_user AS u JOIN t_user_status AS s USING(user_id) JOIN  t_selection_que AS q  USING(user_id) JOIN t_selection AS sel USING(selection_id)  SET s.node_id = sel.next_node_id, s.next_queing_hour = date_format( CONCAT('1970-01-01 ',q.queing_hour,':00:00') + interval 8 hour, '\%H' )  WHERE u.carrier_id = ? AND u.uid = ? ");
$pu->output_log($up_sth->execute(($carrier_id, $mob_uid)));
$up_sth->finish();


# save result.
my $ins_sth $db->prepare("INSERT INTO t_result_log(u.user_id,result_id) SELECT FROM t_user AS u JOIN t_user_status AS s USING(user_id) JOIN  t_selection_que AS q  USING(user_id) JOIN t_selection AS sel USING(selection_id) WHERE u.carrier_id = ? AND u.uid = ?");

## Main

my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp,n.node_name FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();


if ( ! $sth->rows() > 0 )
{
    $sth->finish();
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}
$sth->finish();

$out->{NAME} = sprintf("(%s)%s", $row->{user_id},$row->{user_name});
$out->{V_HP} =  $row->{hp};
$out->{V_MHP} = $row->{max_hp};
$out->{MSG}   = $row->{msg};
$out->{FACE}  = Avatar::Face::TYPE->{$row->{face_type}};
$out->{HAIR}  = Avatar::Hair::TYPE->{$row->{hair_type}};
$out->{PLACE} = $row->{node_name};
$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;

