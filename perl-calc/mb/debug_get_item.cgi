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

my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";

# init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}

our $out = $at->getOut();




# depend
$at->setBody("body_debug_room.html");
$at->setPageName("ƒŠƒUƒ‹ƒg");
my $version = "0.1a20120328";


my $browser      = $mu->getBrowser();
my $carrier_id   = $mu->getCarrierId();




$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
my $mob_uid = $mu->get_muid();
my $c = new CGI();



## Main
my $sth  = $db->prepare("SELECT b.user_id AS user_id, b.user_name AS user_name, b.msg AS msg, b.face_type AS face_type, b.hair_type AS hair_type, s.a_max_hp AS max_hp, s.a_hp AS hp,n.node_name FROM t_user AS b JOIN t_user_status s USING( user_id ) JOIN t_node_master n USING(node_id) WHERE b.carrier_id = ? AND b.uid = ?");
my $stat = $sth->execute(($carrier_id, $mob_uid));
my $row  = $sth->fetchrow_hashref();

$pu->output_log(qq["CHECK: " ], sprintf("carrier: %s, uid: %s, row: %s",$carrier_id, $mob_uid, $sth->rows() ));

if ( $sth->rows() == 0 )
{
    $sth->finish();
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}
$sth->finish();

my $user_id = $row->{user_id};
my $num = $c->param("n") || 0;
my $item_id = $c->param("imi") || 0;

my $get_item_sql = "
INSERT INTO t_user_item (user_id, item_master_id)
SELECT
    ? AS user_id,
    item_master_id
FROM
    t_item_master
WHERE
    item_master_id = ?
";
my $get_sth  = $db->prepare($get_item_sql);
for ( my $i = 0 ; $i < $num ; $i++)
{
    my $get_stat = $get_sth->execute(($user_id, $item_id));
}



$get_sth->finish();

$db->disconnect();





$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();

$at->output();





exit;

