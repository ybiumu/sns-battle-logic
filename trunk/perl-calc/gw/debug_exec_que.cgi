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
#use Anothark::Battle;
#use Anothark::Battle::Exhibition;
#use Anothark::Character;
#use Anothark::Skill;
#use Anothark::Item;
#use Anothark::Item::DropItem;

use Anothark::QueingBase;

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

# Ownerの場合とmemberの場合で分ける
#
my $select_user_id = " SELECT user_id FROM t_user AS u WHERE u.carrier_id = ? AND u.uid = ? ";

my $rs_sth = $db->prepare( $select_user_id );
$pu->output_log($rs_sth->execute(($carrier_id, $mob_uid)));

my $rs_row  = $rs_sth->fetchall_arrayref();
if ( ! $rs_sth->rows() == 1 )
{
    $rs_sth->finish();
    $db->disconnect();
    $pu->warning("1");
    $at->Error();
    $at->{out}->{RESULT} = "問題が発生しました。<br />管理者にお問い合わせ下さい";
    $db->disconnect();

    $at->setup();
    $at->output();
    exit;
}

$rs_sth->finish();




my $qb = new Anothark::QueingBase($at);
my $force = $c->param("f") || "";
if ( $force eq "1" )
{
    $qb->setForce("1");
}

$qb->openMainSth();
my $queing_status = $qb->doQueing($rs_row);
$qb->finishMainSth();

if ( $queing_status == 2 )
{

    $pu->warning("2");
    $at->Error();
    $at->{out}->{RESULT} = "結果処理出来ません。<br />結果処理は1時間に1回です";
    $db->disconnect();

    $at->setup();
    $at->output();
}
else
{
    $pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');
    print $c->redirect("recent_text.cgi?guid=ON");    

    $pu->output_log("End que.");
}


exit;


