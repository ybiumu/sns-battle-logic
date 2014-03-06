#!/usr/bin/perl

use lib qw( .htlib ../.htlib );
use CGI;
use DbUtil;
use MobileUtil;
use GoogleAdSence;
use Avatar;
use PageUtil;
use AaTemplate;
use Anothark::BoardManager;

my $pu = new PageUtil();
my $at = new AaTemplate();
$at->warning("start mypage");
$at->setPageUtil($pu);


my $db = DbUtil::getDbHandler();
my $mu = new MobileUtil();
$mu->debug(" page muid " .$mu->get_muid() );

$at->setDbHandler($db);
$at->setMobileUtil($mu);

my $ad_str = "";


my $browser      = $mu->getBrowser();
#my $carrier_id   = $mu->getCarrierId();
$pu->setSelectedStr( $browser eq "P" ? ' selected="true" ' : ' selected' );
my $checked_str  = $browser eq "P" ? ' checked="true" '  : ' checked';
#my $mob_uid = $mu->get_muid();
my $c = new CGI();

# init check
my $result = $at->setupBaseData();

if ( ! $result )
{
    $db->disconnect();
    print $c->redirect("setup.cgi?guid=ON");    
    exit;
}


our $out = $at->getOut();
my $board = new Anothark::BoardManager($db);
my $my_user_id = $at->{out}->{USER_ID};


# depend
$at->setBody("body_mypage.html");
$at->setPageName("マイページ");

my $version = "0.1a20120328";




## Main

if ( $c->param("user_id") && $c->param("user_id") ne $at->{out}->{USER_ID} )
{

    # 他人のマイペ
    $result = $at->getBaseDataByUserId($c->param("user_id"));
    if ( ! $result )
    {

        $at->Critical();
#        $at->Error();
        $out->{RESULT} = "そのユーザーは存在しません";
    }
    else
    {
        $at->setBody("body_yourpage.html");
    }
}

my $entry =  $board->readMyBoardOne( $my_user_id, $out->{USER_ID})->[0];

if ( $entry )
{
    my $msg = $entry->{message};
    $msg =~ s/\n/<br \/>/g;
    $msg =~ s/ /&nbsp;/g;
#$msg =~ s/&gt;&gt;(\d+)/<a href="board.cgi?guid=ON&t=$board_type_id&oid=$target_user_id&tid=$1">&gt;&gt;$1<\/a>/g;
    $out->{BRD} .= sprintf
        "<br />%s<br />(%s)<br />%s",
        $entry->{user_name},
        $entry->{last_update},
        $msg;
}


$pu->output_log(qq["$ENV{REMOTE_ADDR}" "$ENV{HTTP_USER_AGENT}" ], '"'.join("&", ( map{ sprintf("%s=%s",$_,$c->param($_)) } ($c->param) ) ) .'"');




$at->setup();
$at->output();
$db->disconnect();
exit;

